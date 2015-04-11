/*
 * Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildEvent;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.BuildListener;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.LogLevel;

import task.handler.DestructiveChangesHandler.DestructiveChange;
import task.model.SfdcFeature;
import task.model.SfdcFeature.FeatureName;
import task.model.SfdcTypeSet;

import com.sforce.soap.enterprise.EnterpriseConnection;
import com.sforce.soap.enterprise.LoginResult;
import com.sforce.soap.metadata.AsyncResult;
import com.sforce.soap.metadata.DeleteResult;
import com.sforce.soap.metadata.DeployMessage;
import com.sforce.soap.metadata.DeployOptions;
import com.sforce.soap.metadata.DeployResult;
import com.sforce.soap.metadata.DescribeMetadataObject;
import com.sforce.soap.metadata.DescribeMetadataResult;
import com.sforce.soap.metadata.FileProperties;
import com.sforce.soap.metadata.ListMetadataQuery;
import com.sforce.soap.metadata.Metadata;
import com.sforce.soap.metadata.MetadataConnection;
import com.sforce.soap.metadata.Package;
import com.sforce.soap.metadata.PackageTypeMembers;
import com.sforce.soap.metadata.ReadResult;
import com.sforce.soap.metadata.RetrieveRequest;
import com.sforce.soap.metadata.RetrieveResult;
import com.sforce.soap.metadata.StaticResource;
import com.sforce.soap.metadata.StaticResourceCacheControl;
import com.sforce.soap.metadata.StatusCode;
import com.sforce.soap.metadata.UpsertResult;
import com.sforce.ws.ConnectionException;
import com.sforce.ws.ConnectorConfig;

/**
 * SfdcHandler
 *
 * @author  XLEHMF
 */
public class SfdcHandler
{

  interface ErrorHandler<T>
  {
    void evaluate(T status, String logInfo);
  }

  private static final String PROJECT_PROPERTY_SFDC_SESSION = "SFDC_SESSION";

  private class SfdcBuildListener
    implements BuildListener
  {

    @Override
    public void buildStarted(BuildEvent event)
    {
      // TODO we could move the login here
    }

    @Override
    public void buildFinished(BuildEvent event)
    {
      ConnectorConfig eConfig = createConnectorConfig();
      try {
        EnterpriseConnection eConnection = new EnterpriseConnection(eConfig);
        SfdcConnectionContext result = retrieveContext(eConnection);
        if (null != result) {
          result.getEConnection().logout();
        }
      }
      catch (ConnectionException e) {
        // e.printStackTrace();

        throw new BuildException(String.format("Error logging out at SFDC: %s.", e.getMessage()), e);
      }
    }

    @Override
    public void targetStarted(BuildEvent event)
    {
      // nothing to do
    }

    @Override
    public void targetFinished(BuildEvent event)
    {
      // nothing to do
    }

    @Override
    public void taskStarted(BuildEvent event)
    {
      // nothing to do
    }

    @Override
    public void taskFinished(BuildEvent event)
    {
      // nothing to do
    }

    @Override
    public void messageLogged(BuildEvent event)
    {
      // nothing to do
    }

  }

  private final static double VERSION = 32.0d;
  private final Set<String> noChildHandling = new HashSet<>(Arrays.asList("CustomObject", "Workflow"));
  private final Map<String, String> folderReplacements = new HashMap<>();
  private final Set<String> bulkifyableTypes = new HashSet<>(Arrays.asList("ApexTrigger", "ApexClass"));

  private Task task;
  private int maxPoll;
  private boolean dryRun;
  private String serverurl;
  private String username;
  private String password;
  private boolean useProxy;
  private String proxyHost;
  private int proxyPort;
  private Map<String, SfdcFeature> features;

  public SfdcHandler()
  {
    folderReplacements.put("Document", "DocumentFolder");
    folderReplacements.put("EmailTemplate", "EmailFolder");
    folderReplacements.put("Dashboard", "DashboardFolder");
    folderReplacements.put("Report", "ReportFolder");
  }

  @SuppressWarnings("hiding")
  public void initialize(Task task,
                         int maxPoll,
                         boolean dryRun,
                         String serverurl,
                         String username,
                         String password,
                         boolean useProxy,
                         String proxyHost,
                         int proxyPort,
                         Map<String, SfdcFeature> features)
  {
    this.task = task;
    this.maxPoll = maxPoll;
    this.dryRun = dryRun;
    this.serverurl = serverurl;
    this.username = username;
    this.password = password;
    this.useProxy = useProxy;
    this.proxyHost = proxyHost;
    this.proxyPort = proxyPort;
    this.features = (null != features) ? features : new HashMap<String, SfdcFeature>();

    validate();

    // do not register a second time to omit double logouts
    boolean alreadyRegistered = false;
    for (BuildListener bl : task.getProject().getBuildListeners()) {
      if (SfdcBuildListener.class.getSimpleName().equals(bl.getClass().getSimpleName())) {
        alreadyRegistered = true;
      }
    }
    if (!alreadyRegistered) {
      task.getProject().addBuildListener(new SfdcBuildListener());
    }
  }

  private void validate()
  {
    if (null == task || null == serverurl || null == username || null == password) {
      throw new BuildException("SfdcHandler is not properly initialized.");
    }
  }

  /**
   * This method does the actual deployment of the given ZIP file.
   * 
   * @param zipFile The ZIP file to deploy.
   * @param infos The list of deployment infos being deployed. Will be used for logging purposes only.
   */
  public void deployTypes(ByteArrayOutputStream zipFile, List<DeploymentInfo> infos)
  {
    List<String> types = new ArrayList<>();
    for (DeploymentInfo info : infos) {
      types.add(info.getDeploymentUnit().getTypeName());
    }
    String typeNames = StringUtils.join(types, ",");

    deployTypes(zipFile, typeNames, new ErrorHandler<DeployResult>() {

      @Override
      public void evaluate(DeployResult status, String logInfo)
      {
        task.log("Deployment failed. Component errors:", LogLevel.ERR.getLevel());
        for (DeployMessage dm : status.getDetails().getComponentFailures()) {
          task.log(String.format("Name: %s Type: %s Line: %d Column: %d Problem: %s",
                                 dm.getFullName(),
                                 dm.getComponentType(),
                                 dm.getLineNumber(),
                                 dm.getColumnNumber(),
                                 dm.getProblem()),
                   LogLevel.ERR.getLevel());
        }

        throw new BuildException(String.format("Deployment of %s not successful.", logInfo));        
      }
      
    });
  }

  private void deployTypes(ByteArrayOutputStream zipFile, String logInfo, ErrorHandler<DeployResult> errorHandler)
  {
    if (dryRun) {
      return;
    }

    try {
      SfdcConnectionContext context = login();

      task.log(String.format("Start deployment of ZIP."));

      DeployOptions options = new DeployOptions();
      options.setPerformRetrieve(false);
      options.setRollbackOnError(true);

      AsyncResult ar = context.getMConnection().deploy(zipFile.toByteArray(), options);

      int count = 0;
      DeployResult status = null;
      do {

        task.log(String.format("Wait for job %s to finish...", ar.getId()));

        try {
          Thread.sleep(3000);
        }
        catch (InterruptedException e) {
          task.log(String.format("Got interrupted while sleeping for deployment result: %s.", e.getMessage()));
        }
        status = context.getMConnection().checkDeployStatus(ar.getId(), true);

        count++;
      }
      while (!status.isDone() && count < maxPoll);

      if (status.isDone()) {
        if (status.isSuccess()) {
          task.log(String.format("Deployment of %s successful.", logInfo));
        }
        else {
          errorHandler.evaluate(status, logInfo);
        }
      }
      else {
        throw new BuildException(String.format("Deployment of %s not successful.", logInfo));
      }
    }
    catch (ConnectionException e) {
      throw new BuildException(String.format("Error connecting to SFDC: %s.", e.getMessage()), e);
    }
  }

  private SfdcConnectionContext login()
    throws ConnectionException
  {
    ConnectorConfig eConfig = createConnectorConfig();
    EnterpriseConnection eConnection = new EnterpriseConnection(eConfig);

    SfdcConnectionContext result = retrieveContext(eConnection);
    if (null == result) {
      LoginResult loginResult = login(eConnection, eConfig);
      MetadataConnection mConnection = createMetadataConnection(loginResult);

      result = new SfdcConnectionContext(eConnection, mConnection);
    }
    return result;
  }

  private SfdcConnectionContext retrieveContext(EnterpriseConnection eConnection)
    throws ConnectionException
  {
    String session = task.getProject().getProperty(PROJECT_PROPERTY_SFDC_SESSION);
    if (StringUtils.isNotEmpty(session)) {

      String[] tokens = session.split("\\|");
      if (null != tokens && 3 == tokens.length) {
        String serviceEndpointUrl = tokens[0];
        String metadataServerUrl = tokens[1];
        String sessionId = tokens[2];

        eConnection.setSessionHeader(sessionId);
        eConnection.getConfig().setServiceEndpoint(serviceEndpointUrl);

        LoginResult loginResult = new LoginResult();
        loginResult.setMetadataServerUrl(metadataServerUrl);
        loginResult.setSessionId(sessionId);

        MetadataConnection mConnection = createMetadataConnection(loginResult);

        return new SfdcConnectionContext(eConnection, mConnection);
      }
    }
    return null;
  }

  private ConnectorConfig createConnectorConfig()
  {
    ConnectorConfig eConfig = new ConnectorConfig();
    eConfig.setAuthEndpoint(serverurl + "/services/Soap/c/32.0");
    eConfig.setServiceEndpoint(eConfig.getAuthEndpoint());
    eConfig.setUsername(username);
    eConfig.setPassword(password);
    if (useProxy) {
      eConfig.setProxy(proxyHost, proxyPort);
    }
    eConfig.setManualLogin(true);

    return eConfig;
  }

  private LoginResult login(EnterpriseConnection eConnection, ConnectorConfig eConfig)
    throws ConnectionException
  {
    LoginResult loginResult = eConnection.login(eConfig.getUsername(), eConfig.getPassword());
    eConfig.setServiceEndpoint(loginResult.getServerUrl());

    eConnection.setSessionHeader(loginResult.getSessionId());

    String sessionInfo =
        String.format("%s|%s|%s",
                      loginResult.getServerUrl(),
                      loginResult.getMetadataServerUrl(),
                      loginResult.getSessionId());
    task.getProject().setProperty(PROJECT_PROPERTY_SFDC_SESSION, sessionInfo);

    return loginResult;
  }

  private MetadataConnection createMetadataConnection(LoginResult loginResult)
    throws ConnectionException
  {
    ConnectorConfig mConfig = new ConnectorConfig();
    mConfig.setServiceEndpoint(loginResult.getMetadataServerUrl());
    mConfig.setSessionId(loginResult.getSessionId());
    if (useProxy) {
      mConfig.setProxy(proxyHost, proxyPort);
    }

    return new MetadataConnection(mConfig);
  }

  public ByteArrayOutputStream retrieveMetadata(Map<String, List<String>> metadata)
  {
    ByteArrayOutputStream result = null;

    try {
      SfdcConnectionContext context = login();

      List<PackageTypeMembers> types = new ArrayList<>();
      for (Map.Entry<String, List<String>> entry : metadata.entrySet()) {
        PackageTypeMembers type = new PackageTypeMembers();
        type.setName(entry.getKey());
        type.setMembers(entry.getValue().toArray(new String[entry.getValue().size()]));
        types.add(type);
      }

      Package unpackaged = new Package();
      unpackaged.setTypes(types.toArray(new PackageTypeMembers[types.size()]));

      RetrieveRequest retrieveRequest = new RetrieveRequest();
      retrieveRequest.setApiVersion(VERSION);
      retrieveRequest.setUnpackaged(unpackaged);

      AsyncResult ar = context.getMConnection().retrieve(retrieveRequest);

      int count = 0;
      RetrieveResult status = null;
      do {

        task.log(String.format("Wait for job %s to finish...", ar.getId()));

        try {
          Thread.sleep(3000);
        }
        catch (InterruptedException e) {
          task.log(String.format("Got interrupted while sleeping for retrieval result: %s.", e.getMessage()));
        }
        status = context.getMConnection().checkRetrieveStatus(ar.getId());

        count++;
      }
      while (!status.isDone() && count < maxPoll);

      if (status.isDone()) {
        if (status.isSuccess()) {

          Set<String> keys = metadata.keySet();
          task.log(String.format("Retrieval of %s successful.",
                                 StringUtils.join(keys.toArray(new String[keys.size()]), ",")));

          try {
            result = new ByteArrayOutputStream();
            result.write(status.getZipFile());
            result.close();
          }
          catch (IOException e) {
            throw new BuildException(String.format("Error processing result: %s.", e.getMessage()), e);
          }
        }
        else {
          task.log(String.format("Error %s: %s.",
                                 null != status.getErrorStatusCode()
                                                                    ? status.getErrorStatusCode().toString()
                                                                    : "<null>",
                                 status.getErrorMessage()), LogLevel.ERR.getLevel());

          throw new BuildException(String.format("Deployment of %s not successful.",
                                                 Arrays.toString(types.toArray(new String[0]))));
        }
      }

      return result;
    }
    catch (ConnectionException e) {
      throw new BuildException(String.format("Error connecting to SFDC: %s.", e.getMessage()), e);
    }
  }

  public Map<String, Map<String, Long>> getUpdateStamps(List<SfdcTypeSet> typeSets)
  {
    Map<String, Map<String, Long>> result = new HashMap<>();

    task.log("Compile metadata list.");

    Map<String, SfdcTypeSet> objects = new HashMap<>();
    for (SfdcTypeSet typeSet : typeSets) {
      objects.put(typeSet.getName(), typeSet);
    }

    try {
      SfdcConnectionContext context = login();

      List<DescribeMetadataObject> dmos = new ArrayList<>();

      DescribeMetadataResult describeMetadata = context.getMConnection().describeMetadata(VERSION);
      for (DescribeMetadataObject object : describeMetadata.getMetadataObjects()) {
        // only consider specified objects
        if (objects.containsKey(object.getXmlName())) {
          dmos.add(object);
        }
      }

      List<ListMetadataQuery> queries = compileQueries(dmos);
      Map<String, List<FileProperties>> filePropertiesMap = new HashMap<>();
      filePropertiesMap = listMetadata(context.getMConnection(), queries, filePropertiesMap);

      for (Map.Entry<String, List<FileProperties>> entry : filePropertiesMap.entrySet()) {
        Map<String, Long> entryMap = new HashMap<>();
        for (FileProperties properties : entry.getValue()) {
          entryMap.put(properties.getFullName(), properties.getLastModifiedDate().getTimeInMillis());
        }

        // workaround for CustomObject PersonAccount
        if (features.containsKey(FeatureName.INLCUDE_PERSONACCOUNT.name())) {
          if ("CustomObject".equals(entry.getKey()) && !entryMap.containsKey("PersonAccount")) {
            entryMap.put("PersonAccount", 0L);
          }
        }
        // exclude Checksums from being retrieved
        SfdcFeature feature = features.get(FeatureName.EXCLUDE_CHECKSUMS.name());
        if (null != feature) {
          if ("StaticResource".equals(entry.getKey()) && entryMap.containsKey(feature.getParam())) {

            entryMap.remove(feature.getParam());
          }
        }

        result.put(entry.getKey(), entryMap);
      }

      return result;
    }
    catch (ConnectionException e) {
      throw new BuildException(String.format("Error Connecting to SFDC: %s.", e.getMessage()), e);
    }
  }

  private List<ListMetadataQuery> compileQueries(List<DescribeMetadataObject> dmos)
  {
    List<ListMetadataQuery> queries = new ArrayList<>();

    for (DescribeMetadataObject dmo : dmos) {

      final String name = dmo.getXmlName();

      if (0 < dmo.getChildXmlNames().length && !noChildHandling.contains(name)) {
        for (String child : dmo.getChildXmlNames()) {
          ListMetadataQuery query = new ListMetadataQuery();
          query.setType(child);
          queries.add(query);
        }
      }
      else {
        if (dmo.isInFolder()) {
          // folder objects
          ListMetadataQuery query = new ListMetadataQuery();
          query.setType(folderReplacements.get(dmo.getXmlName()));
          queries.add(query);
        }
        else {
          // regular metadata category
          ListMetadataQuery query = new ListMetadataQuery();
          query.setType(name);
          queries.add(query);
        }
      }
    }
    return queries;
  }

  private Map<String, List<FileProperties>> listMetadata(final MetadataConnection mConnection,
                                                         final List<ListMetadataQuery> queries,
                                                         Map<String, List<FileProperties>> filePropertiesMap)
    throws ConnectionException
  {
    ChunkedExecutor<ListMetadataQuery, Map<String, List<FileProperties>>, ConnectionException> ce =
        new ChunkedExecutor<ListMetadataQuery, Map<String, List<FileProperties>>, ConnectionException>() {

          @Override
          public Map<String, List<FileProperties>> chunky(List<ListMetadataQuery> chunk,
                                                          Map<String, List<FileProperties>> result)
            throws ConnectionException
          {
            List<String> names = new ArrayList<>();
            for (ListMetadataQuery query : chunk) {
              names.add(query.getType());
            }
            task.log(String.format("Query: %s", StringUtils.join(names, ",")));

            FileProperties[] metadata =
                mConnection.listMetadata(chunk.toArray(new ListMetadataQuery[chunk.size()]), VERSION);
            for (FileProperties props : metadata) {
              String type = props.getType();

              if (folderReplacements.containsValue(type)) {
                type = reverseFolderMapping(type);

                ListMetadataQuery folderQuery = new ListMetadataQuery();
                folderQuery.setType(type);
                folderQuery.setFolder(props.getFullName());
                queries.add(folderQuery);
              }

              List<FileProperties> list = result.get(type);
              if (null == list) {
                list = new ArrayList<>();
                result.put(type, list);
              }

              list.add(props);
            }

            return result;
          }
        };
    return ce.execute(queries, 3, filePropertiesMap);
  }

  private String reverseFolderMapping(String type)
  {
    for (Map.Entry<String, String> entry : folderReplacements.entrySet()) {
      if (type.equals(entry.getValue())) {
        return entry.getKey();
      }
    }
    return null;
  }

  public Map<String, String> retrieveChecksums(String sfdcName)
  {
    Map<String, String> result = new HashMap<>();

    try {
      SfdcConnectionContext context = login();

      ReadResult readResult = context.getMConnection().readMetadata("StaticResource", new String[]{ sfdcName });

      Metadata[] mdInfo = readResult.getRecords();

      if (0 == mdInfo.length || null == mdInfo[0]) {
        task.log("Did not find checksums in SFDC.", LogLevel.WARN.getLevel());
      }
      else {
        task.log("Retrieved checksum from SFDC.");

        StaticResource checksums = (StaticResource)mdInfo[0];
        String content = new String(checksums.getContent(), "UTF-8");

        try (StringReader sr = new StringReader(content); BufferedReader br = new BufferedReader(sr)) {
          String line = null;
          do {
            line = br.readLine();
            if (null != line) {
              String[] tokens = line.split(":");
              if (2 == tokens.length) {
                result.put(tokens[0], tokens[1]);
              }
            }
          }
          while (line != null);
        }
      }
    }
    catch (IOException | ConnectionException e) {

      e.printStackTrace();

      throw new BuildException(String.format("Error retrieving checksums from SFDC: %s.", e.getMessage()), e);
    }

    return result;
  }

  // TODO think about zipping checksums before deploying
  public void deployChecksums(Map<String, String> checksumMap, String sfdcName)
  {
    if (dryRun) {
      return;
    }

    try {
      SfdcConnectionContext context = login();

      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      for (Map.Entry<String, String> entry : checksumMap.entrySet()) {
        baos.write(String.format("%s:%s\n", entry.getKey(), entry.getValue()).getBytes("UTF-8"));
      }
      byte[] content = baos.toByteArray();

      StaticResource sr = new StaticResource();
      sr.setCacheControl(StaticResourceCacheControl.Private);
      sr.setContent(content);
      sr.setContentType("text/plain");
      sr.setFullName(sfdcName);
      sr.setDescription("Checksums of all deployed metadata.");

      UpsertResult[] results = context.getMConnection().upsertMetadata(new Metadata[]{ sr });
      for (UpsertResult ur : results) {
        if (ur.isSuccess()) {
          if (ur.isCreated()) {
            task.log("Inserted checksums in SFDC.");
          }
          else {
            task.log("Updated checksums in SFDC.");
          }
        }
        else {
          for (com.sforce.soap.metadata.Error e : ur.getErrors()) {
            task.log(String.format("Error %s upserting checksum in SFDC: %s.",
                                   e.getStatusCode().toString(),
                                   e.getMessage()));
          }

          throw new BuildException("Error upserting checksums in SFDC.");
        }
      }
    }
    catch (IOException | ConnectionException e) {
      throw new BuildException(String.format("Error upserting checksums from SFDC: %s.", e.getMessage()), e);
    }
  }

  public Map<String, List<String>> buildEntityList(Map<String, Map<String, Long>> metadataUpdatestamps)
  {
    Map<String, List<String>> result = new HashMap<>();

    for (Map.Entry<String, Map<String, Long>> entry : metadataUpdatestamps.entrySet()) {
      List<String> entries = new ArrayList<>();
      for (Map.Entry<String, Long> entityEntry : entry.getValue().entrySet()) {
        entries.add(entityEntry.getKey());
      }
      result.put(entry.getKey(), entries);
    }
    return result;
  }

  public void deleteMetadata(List<DestructiveChange> destructiveChanges,
                             boolean persistedOnly,
                             ZipFileHandler zipFileHandler)
  {
    String type = null;
    List<String> fullNames = new ArrayList<>();
    for (DestructiveChange destructiveChange : destructiveChanges) {
      if (persistedOnly) {
        if (StringUtils.isEmpty(destructiveChange.getTimestamp())) {
          throw new BuildException(String.format("Cannot deploy destructive change %s for type %s as it is not persistet yet. Deploy to your development sandbox first.",
                                                 destructiveChange.getFullName(),
                                                 destructiveChange.getType()));
        }
      }
      if (null == type) {
        type = destructiveChange.getType();
      }
      else if (!type.equals(destructiveChange.getType())) {
        throw new BuildException(String.format(""));
      }
      fullNames.add(destructiveChange.getFullName());
    }

    if (dryRun) {
      return;
    }

    task.log(String.format("Deploy destructive change(s) %s for type %s.", fullNames, type));

    if (bulkifyableTypes.contains(type)) {
      deployBulkifyableDestructiveChange(zipFileHandler, type, fullNames);
    }
    else {
      if (1 != fullNames.size()) {
        throw new BuildException(String.format("Can only deploy several destructive changes at once of certain types: %s.",
                                               StringUtils.join(bulkifyableTypes, ",")));
      }
      deploySingleDestructiveChange(type, fullNames.get(0));
    }
  }

  private void deploySingleDestructiveChange(String type, String fullName)
  {
    try {
      SfdcConnectionContext context = login();

      DeleteResult[] results = context.getMConnection().deleteMetadata(type, new String[]{ fullName });
      for (DeleteResult dr : results) {
        if (dr.isSuccess()) {
          task.log("Successfully removed metadata in SFDC.");
        }
        else {
          for (com.sforce.soap.metadata.Error e : dr.getErrors()) {
            if (StatusCode.INVALID_CROSS_REFERENCE_KEY.equals(e.getStatusCode())) {
              task.log(String.format("%s for type %s was deleted already.", fullName, type));
              break;
            }
            else {
              task.log(String.format("Error %s removing metadata in SFDC: %s.",
                                     e.getStatusCode().toString(),
                                     e.getMessage()));
              throw new BuildException("Error removing metadata in SFDC.");
            }
          }
        }
      }
    }
    catch (ConnectionException e) {
      throw new BuildException(String.format("Error removing metadata in SFDC: %s.", e.getMessage()), e);
    }
  }

  private void deployBulkifyableDestructiveChange(ZipFileHandler zipFileHandler, String type, List<String> fullNames)
  {
    final String noErrorProblemPattern = "No " + type + " named: .* found";
    
    ByteArrayOutputStream zipFile = zipFileHandler.prepareDestructiveZipFile(type, fullNames);
    deployTypes(zipFile, "destrutive changes", new ErrorHandler<DeployResult>() {

      @Override
      public void evaluate(DeployResult status, String logInfo)
      {
        boolean errorOccured = false;
        
        for (DeployMessage dm : status.getDetails().getComponentFailures()) {
          if (dm.getProblem().matches(noErrorProblemPattern)) {
            // we tried to delete something which is gone already -> ignore
          } else {
            if (!errorOccured) {
              task.log("Deployment failed. Component errors:", LogLevel.ERR.getLevel());
              errorOccured = true;
            }
            task.log(String.format("Name: %s Type: %s Line: %d Column: %d Problem: %s",
                                   dm.getFullName(),
                                   dm.getComponentType(),
                                   dm.getLineNumber(),
                                   dm.getColumnNumber(),
                                   dm.getProblem()),
                     LogLevel.ERR.getLevel());
          }
        }
        if (errorOccured) {
          throw new BuildException(String.format("Deployment of %s not successful.", logInfo));
        }
      }
      
    });
  }

  /**
   * This method extracts a list of destructive changes which can be handled as a group.
   * Currently ApexTriggers and ApexClasses are handled as a group only.
   */
  public List<DestructiveChange> extractNextChanges(List<DestructiveChange> destructiveChanges)
  {
    List<DestructiveChange> result = new ArrayList<>();

    Iterator<DestructiveChange> itrDC = destructiveChanges.iterator();
    while (itrDC.hasNext()) {
      DestructiveChange dc = itrDC.next();
      if (result.isEmpty()) {
        result.add(dc);
        itrDC.remove();
      }
      else {
        DestructiveChange lastElement = result.get(result.size() - 1);
        if (bulkifyableTypes.contains(lastElement.getType()) && StringUtils.equals(lastElement.getType(), dc.getType())) {
          result.add(dc);
          itrDC.remove();
          continue;
        }
        break;
      }
    }

    return result;
  }
}
