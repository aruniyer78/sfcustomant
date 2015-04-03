/*
 * Daimler CRM - Extension Platform
 */
package backup;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;

import com.sforce.soap.enterprise.EnterpriseConnection;
import com.sforce.soap.enterprise.LoginResult;
import com.sforce.soap.metadata.DescribeMetadataObject;
import com.sforce.soap.metadata.DescribeMetadataResult;
import com.sforce.soap.metadata.FileProperties;
import com.sforce.soap.metadata.ListMetadataQuery;
import com.sforce.soap.metadata.MetadataConnection;
import com.sforce.ws.ConnectionException;
import com.sforce.ws.ConnectorConfig;

/**
 * 
 * @author  xlehmf
 */
public class SfdcMetadataCreator
{

  private static List<String> excludes = new ArrayList<>();
  private static Set<String> noChildHandling = new HashSet<>();

  private final static double VERSION = 33.0d;

  private static void setup()
  {
    excludes.add("InstalledPackage/sf_chttr_apps");
    excludes.add("InstalledPackage/sf_com_apps");
    excludes.add("InstalledPackage/EasyDescribe");
    excludes.add("Document/EasyDescribe.*");
    excludes.add("StaticResource/EasyDescribe.*");
    excludes.add("CustomTab/EasyDescribe.*");
    excludes.add("CustomApplication/EasyDescribe.*");
    excludes.add("ApexComponent/EasyDescribe.*");
    excludes.add("ApexPage/EasyDescribe.*");
    excludes.add("ApexClass/EasyDescribe.*");

    noChildHandling.add("CustomObject");
  }

  public static void main(String[] args)
    throws ConnectionException
  {
    boolean useProxy = true;
    boolean isPackageXml = false;

    setup();

    ConnectorConfig eConfig = new ConnectorConfig();
    // CN PROD, DEV OKoeth, DEV 58demo 
        eConfig.setAuthEndpoint("https://login.salesforce.com/services/Soap/c/32.0");
    // AU SIT, FULL
//    eConfig.setAuthEndpoint("https://test.salesforce.com/services/Soap/c/32.0");
    eConfig.setServiceEndpoint(eConfig.getAuthEndpoint());
    // CN PROD
    //    eConfig.setUsername("falk.lehmann.bp@nttdata.com.production");
    //    eConfig.setPassword("fl3salesforce#4g8KRqiprwTZAg1t2HqXxUPVk");
    // AU SIT
    //    eConfig.setUsername("falk.lehmann.bp@nttdata.com.mbaup.sit");
    //    eConfig.setPassword("fl3salesforce#2");
    // AU FULL
//    eConfig.setUsername("falk.lehmann.bp@nttdata.com.mbaup.full");
//    eConfig.setPassword("fl3salesforce#4GHv9ipc43LgkyzpwJeVj9SgHc");
    // DEV OKoeth
    //    eConfig.setUsername("oliver.koeth@nttdata.com.market");
    //    eConfig.setPassword("China@2016lBMaoIRWVYtCSVKUqlE1b68bC");
    // DEV 58demo
    eConfig.setUsername("falk.lehmann@58demo.org");
    eConfig.setPassword("fl3salesforce1h0UA9mk93KBigN4YHJJrzjsD9");

    if (useProxy) {
      eConfig.setProxy("141.77.17.155", 8080);
    }
    eConfig.setManualLogin(true);

    EnterpriseConnection eConnection = new EnterpriseConnection(eConfig);
    LoginResult loginResult = eConnection.login(eConfig.getUsername(), eConfig.getPassword());
    eConfig.setServiceEndpoint(loginResult.getServerUrl());

    eConnection.setSessionHeader(loginResult.getSessionId());

    ConnectorConfig mConfig = new ConnectorConfig();
    mConfig.setServiceEndpoint(loginResult.getMetadataServerUrl());
    mConfig.setSessionId(loginResult.getSessionId());
    if (useProxy) {
      mConfig.setProxy("141.77.17.155", 8080);
    }

    final MetadataConnection mConnection = new MetadataConnection(mConfig);

    System.out.println("Retrieving metadata...");

    String filename = isPackageXml ? "metadata.xml" : "metadata.csv";
    try (FileWriter fw = new FileWriter(filename); BufferedWriter bw = new BufferedWriter(fw);) {

      writeHeader(bw, isPackageXml);

      Set<String> special = new HashSet<>();
      //      special.add("CustomObject");
      //      special.add("EmailTemplate");
      //      special.add("Report");
      //      special.add("Dashboard");
      //      special.add("Document");

      DescribeMetadataResult describeMetadata = mConnection.describeMetadata(VERSION);
      for (DescribeMetadataObject object : describeMetadata.getMetadataObjects()) {

        if (!special.isEmpty() && !special.contains(object.getXmlName())) {
          continue;
        }

        System.out.println(String.format("Type: %s", object.getXmlName()));
        if (0 < object.getChildXmlNames().length) {
          System.out.println(String.format("Type: %s Children: %s",
                                           object.getXmlName(),
                                           StringUtils.join(object.getChildXmlNames(), ", ")));
        }

        Map<String, List<FileProperties>> filePropertiesMap = listMetadata(mConnection, object);

        Map<String, List<String>> fullNameMap = filterOutExcludes(filePropertiesMap);

        writeTypes(bw, fullNameMap, isPackageXml);
      }

      writeFooter(bw, isPackageXml);
    }
    catch (IOException e) {
      System.err.println(String.format("Error creating metadata.xml: %s", e.getMessage()));
      e.printStackTrace(System.err);
    }

    eConnection.logout();
  }

  private static void writeTypes(BufferedWriter bw, Map<String, List<String>> fullNameMap, boolean isPackageXml)
    throws IOException
  {
    for (Map.Entry<String, List<String>> entry : fullNameMap.entrySet()) {
      String typeName = entry.getKey();
      List<String> fullNames = entry.getValue();
      if (!fullNames.isEmpty()) {
        StringBuilder sb = new StringBuilder();
        for (String fullName : fullNames) {
          if (0 < sb.length()) {
            sb.append(", ");
          }
          sb.append(fullName);
        }
        System.out.println(String.format("List for: %s Objects: %s", typeName, sb.toString()));

        Collections.sort(fullNames);
        if (isPackageXml) {
          bw.write("    <types>");
          bw.newLine();

          for (String fullName : fullNames) {
            bw.write("        <members>" + fullName + "</members>");
            bw.newLine();
          }

          bw.write("        <name>" + typeName + "</name>");
          bw.newLine();
          bw.write("    </types>");
          bw.newLine();
        }
        else {
          for (String fullName : fullNames) {
            bw.write(typeName + ";" + fullName);
            bw.newLine();
          }
        }
      }
    }
  }

  private static void writeFooter(BufferedWriter bw, boolean isPackageXml)
    throws IOException
  {
    if (isPackageXml) {
      bw.write("    <version>32.0</version>");
      bw.newLine();
      bw.write("</Package>");
      bw.newLine();
    }
  }

  private static void writeHeader(BufferedWriter bw, boolean isPackageXml)
    throws IOException
  {
    if (isPackageXml) {
      bw.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
      bw.newLine();
      bw.write("<Package xmlns=\"http://soap.sforce.com/2006/04/metadata\">");
      bw.newLine();
    }
    else {
      bw.write("Category;Item");
      bw.newLine();
    }
  }

  private static Map<String, List<FileProperties>> listMetadata(final MetadataConnection mConnection,
                                                                DescribeMetadataObject object)
    throws ConnectionException
  {
    final String name = object.getXmlName();

    Map<String, List<FileProperties>> filePropertiesMap = new HashMap<>();
    if (0 < object.getChildXmlNames().length && !noChildHandling.contains(name)) {
      //          
      //          ChunkedExecutor<String, Map<String, List<FileProperties>>, ConnectionException> childCE =
      //              new ChunkedExecutor<String, Map<String, List<FileProperties>>, ConnectionException>() {
      //
      //                @Override
      //                public Map<String, List<FileProperties>> chunky(List<String> chunk, Map<String, List<FileProperties>> map)
      //                  throws ConnectionException
      //                {
      //                  List<ListMetadataQuery> queries = new ArrayList<>();
      //                  for (String child : chunk) {
      //                    ListMetadataQuery query = new ListMetadataQuery();
      //                    query.setType(child);
      //                    queries.add(query);
      //                  }
      //                  map.put(child, Arrays.asList(mConnection.listMetadata(queries, VERSION)))
      //                  return null;
      //                }
      //            
      //          };
      //          childCE.execute(Arrays.asList(object.getChildXmlNames()),
      //                                                       3,
      //                                                       filePropertiesMap);
      ListMetadataQuery query = new ListMetadataQuery();
      query.setType(name);
      filePropertiesMap.put(name, Arrays.asList(mConnection.listMetadata(new ListMetadataQuery[]{ query }, VERSION)));
      for (String child : object.getChildXmlNames()) {
        ListMetadataQuery query2 = new ListMetadataQuery();
        query2.setType(child);
        filePropertiesMap.put(child,
                              Arrays.asList(mConnection.listMetadata(new ListMetadataQuery[]{ query2 }, VERSION)));
      }
    }
    else {
      if (object.isInFolder()) {

        Map<String, String> replacements = new HashMap<>();
        replacements.put("Document", "DocumentFolder");
        replacements.put("EmailTemplate", "EmailFolder");
        replacements.put("Dashboard", "DashboardFolder");
        replacements.put("Report", "ReportFolder");

        ListMetadataQuery query = new ListMetadataQuery();
        query.setType(replacements.get(object.getXmlName()));
        FileProperties[] folderFileProperties = mConnection.listMetadata(new ListMetadataQuery[]{ query }, VERSION);

        ChunkedExecutor<FileProperties, List<FileProperties>, ConnectionException> folderCE =
            new ChunkedExecutor<FileProperties, List<FileProperties>, ConnectionException>() {

              @Override
              public List<FileProperties> chunky(List<FileProperties> chunk, List<FileProperties> result)
                throws ConnectionException
              {
                List<ListMetadataQuery> queries = new ArrayList<>();
                for (FileProperties fileProperties : chunk) {
                  ListMetadataQuery q = new ListMetadataQuery();
                  q.setType(name);
                  q.setFolder(fileProperties.getFullName());
                  queries.add(q);
                }
                result.addAll(Arrays.asList(mConnection.listMetadata(queries.toArray(new ListMetadataQuery[queries.size()]),
                                                                     VERSION)));

                return result;
              }
            };
        List<FileProperties> fileList =
            folderCE.execute(Arrays.asList(folderFileProperties), 3, new ArrayList<FileProperties>());

        // add the folders itself
        fileList.addAll(0, Arrays.asList(folderFileProperties));

        filePropertiesMap.put(name, fileList);
      }
      else {
        ListMetadataQuery query = new ListMetadataQuery();
        query.setType(name);
        filePropertiesMap.put(name, Arrays.asList(mConnection.listMetadata(new ListMetadataQuery[]{ query }, VERSION)));
      }
    }
    return filePropertiesMap;
  }

  private static Map<String, List<String>> filterOutExcludes(Map<String, List<FileProperties>> filePropertiesMap)
  {
    Map<String, List<String>> result = new HashMap<>();

    for (Map.Entry<String, List<FileProperties>> entry : filePropertiesMap.entrySet()) {
      String name = entry.getKey();

      List<String> fullNames = new ArrayList<>();
      for (FileProperties properties : entry.getValue()) {
        boolean toExclude = false;
        String qualifiedName = String.format("%s/%s", name, properties.getFullName());
        for (String exclude : excludes) {
          if (qualifiedName.matches(exclude)) {
            toExclude = true;
            break;
          }
        }
        if (toExclude) {
          System.out.println(String.format("Filtered out: %s Objects: %s", name, properties.getFullName()));
        }
        else {
          fullNames.add(properties.getFullName());
        }
      }

      if (!fullNames.isEmpty()) {
        result.put(name, fullNames);
      }

    }
    return result;
  }

}
