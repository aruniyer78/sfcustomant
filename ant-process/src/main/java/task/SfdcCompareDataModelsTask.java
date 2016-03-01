package task;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Taskdef;

import task.handler.SfdcHandler;
import task.model.SfdcExclude;
import task.model.SfdcOrgDescriptor;

import com.sforce.soap.enterprise.DescribeSObjectResult;
import com.sforce.soap.enterprise.Field;

/**
 * SfdcCompareDataModelsTask
 *
 * @author  xlehmf
 */
public class SfdcCompareDataModelsTask
  extends Taskdef
{

  private boolean useProxy;
  private String proxyHost;
  private int proxyPort;
  private boolean debug;

  private SfdcOrgDescriptor masterOrg;
  private List<SfdcOrgDescriptor> slaveOrgs;
  
  public void setDebug(boolean debug)
  {
    this.debug = debug;
  }
  
  public void setUseProxy(boolean useProxy)
  {
    this.useProxy = useProxy;
  }

  public void setProxyHost(String proxyHost)
  {
    this.proxyHost = proxyHost;
  }

  public void setProxyPort(int proxyPort)
  {
    this.proxyPort = proxyPort;
  }

  public void addConfigured(SfdcOrgDescriptor orgDescriptor)
  {
    orgDescriptor.validateSettings();
    
    if (SfdcOrgDescriptor.TYPEDEF_NAME_MASTER.equals(orgDescriptor.getTaskName())) {
      if (null == masterOrg) {
        masterOrg = orgDescriptor;
      }
      else {
        throw new BuildException("There can only be one master organisation!");
      }
    } else if (SfdcOrgDescriptor.TYPEDEF_NAME_SLAVE.equals(orgDescriptor.getTaskName())) {
        slaveOrgs.add(orgDescriptor);
    } else {
      throw new BuildException(String.format("Unknown organisation type: %s!", orgDescriptor.getTaskName()));
    }
  }

  @Override
  public void init()
  {
    super.init();

    slaveOrgs = new ArrayList<>();
  }

  @Override
  public void execute()
  {
    validate();
    initialize();

    SfdcHandler sfdcHandler = new SfdcHandler();
    sfdcHandler.initialize(this,
                           0,
                           false,
                           false,
                           masterOrg.getUrl(),
                           masterOrg.getUser(),
                           masterOrg.getPassword(),
                           useProxy,
                           proxyHost,
                           proxyPort,
                           null);

    List<DescribeSObjectResult> masterSObjects = applyFilter(sfdcHandler.describeSObjects(masterOrg.getOrg()), masterOrg.getExcludes());

    sfdcHandler.discardContext();

    boolean status = true;
    for (SfdcOrgDescriptor slaveOrg : slaveOrgs) {
      sfdcHandler = new SfdcHandler();
      sfdcHandler.initialize(this,
                             0,
                             false,
                             false,
                             slaveOrg.getUrl(),
                             slaveOrg.getUser(),
                             slaveOrg.getPassword(),
                             useProxy,
                             proxyHost,
                             proxyPort,
                             null);

      List<DescribeSObjectResult> slaveSObjects = applyFilter(sfdcHandler.describeSObjects(slaveOrg.getOrg()), slaveOrg.getExcludes());

      sfdcHandler.discardContext();

      if (!compareOrgs(masterOrg.getOrg(), masterSObjects, slaveOrg.getOrg(), slaveSObjects)) {
        status = false;
      }
    }
    
    if (!status) {
      throw new BuildException("There are some discrepencies in the data models. Please check the log for further details.");
    }
  }

  private List<DescribeSObjectResult> applyFilter(List<DescribeSObjectResult> describeSObjects,
                                                 List<SfdcExclude> excludes)
  {
    List<DescribeSObjectResult> filteredList = new ArrayList<>();
    
    // can easily written in Java8
    // describeSObjects.stream().filter(result -> excludes.anyMatch(exclude -> exclude.match(result.getName())));
    for (DescribeSObjectResult result : describeSObjects) {
      boolean match = false;
      for (SfdcExclude exclude : excludes) {
        if (result.getName().matches(exclude.getName())) {
          
          if (debug) {
            log(String.format("%s was filtered out.", result.getName(), exclude.getName()));
          }
          
          match = true;
          break;
        }
      }
      if (!match) {
        filteredList.add(result);
      }
    }
    
    return filteredList;
  }

  private boolean compareOrgs(String masterName,
                           List<DescribeSObjectResult> masterSObjects,
                           String slaveName,
                           List<DescribeSObjectResult> slaveSObjects)
  {
    boolean result = true;
    
    Map<String, DescribeSObjectResult> masterMap = createObjectMap(masterSObjects);
    Map<String, DescribeSObjectResult> slaveMap = createObjectMap(slaveSObjects);

    for (String name : masterMap.keySet()) {
      DescribeSObjectResult masterDSOR = masterMap.get(name);
      DescribeSObjectResult slaveDSOR = slaveMap.remove(name);

      if (null != slaveDSOR) {
        Map<String, String> masterFieldMap = createFieldMap(masterDSOR);
        Map<String, String> slaveFieldMap = createFieldMap(slaveDSOR);

        for (String field : masterFieldMap.keySet()) {
          String masterInfo = masterFieldMap.get(field);
          String slaveInfo = slaveFieldMap.remove(field);

          if (null != slaveInfo) {
            if (!masterInfo.equals(slaveInfo)) {
              log(String.format("The field %s of object %s is different in %s and %s:",
                                field,
                                name,
                                masterName,
                                slaveName));
              log(String.format("%s (%s)", masterInfo, masterName));
              log(String.format("%s (%s)", slaveInfo, slaveName));
              result = false;
            }
          }
          else {
            log(String.format("The field %s of object %s in missing in %s.", field, name, slaveName));
            result = false;
          }
        }

        for (String field : slaveFieldMap.keySet()) {
          log(String.format("The field %s of object %s in missing in %s.", field, name, masterName));
          result = false;
        }
      }
      else {
        log(String.format("The object %s is missing in %s.", name, slaveName));
        result = false;
      }
    }

    for (String name : slaveMap.keySet()) {
      log(String.format("The object %s is missing in %s.", name, masterName));
      result = false;
    }
    
    return result;
  }

  private Map<String, String> createFieldMap(DescribeSObjectResult dsor)
  {
    Map<String, String> result = new HashMap<>();

    for (Field field : dsor.getFields()) {
      result.put(field.getName(),
                 String.format("Type: %s Length: %d Digits: %d, Auto: %b Calculated: %b ExternalId: %b",
                               field.getType().name(),
                               field.getLength(),
                               field.getDigits(),
                               field.getAutoNumber(),
                               field.getCalculated(),
                               field.getExternalId()));
    }

    return result;
  }

  private Map<String, DescribeSObjectResult> createObjectMap(List<DescribeSObjectResult> sObjects)
  {
    Map<String, DescribeSObjectResult> result = new HashMap<>();

    for (DescribeSObjectResult dsor : sObjects) {
      result.put(dsor.getName(), dsor);
    }

    return result;
  }

  private void initialize()
  {
    // nothing to do here
  }

  private void validate()
  {
    if (null == masterOrg) {
      throw new BuildException("The master organistation must be specified.");
    }
    if (slaveOrgs.isEmpty()) {
      throw new BuildException("At least one slave organisation must be specified.");
    }
  }

}
