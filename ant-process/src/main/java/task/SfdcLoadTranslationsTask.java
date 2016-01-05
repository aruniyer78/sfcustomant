package task;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Taskdef;

import task.handler.DataLoaderHandler;
import task.handler.LogWrapper;

/**
 * SfdcDataLoaderTask
 *
 * @author  xlehmf
 */
public class SfdcLoadTranslationsTask
  extends Taskdef
{

  private String username;
  private String password;
  private String serverurl;
//  private int maxPoll;
  private boolean useProxy;
  private String proxyHost;
  private int proxyPort;
  private String dataRoot;
  private boolean debug;
//  private String transformationsRoot;
  private String configId;
  private String logDir;

//  private UpdateStampHandler updateStampHandler;
//  private SfdcHandler sfdcHandler;
//  private MetadataHandler metadataHandler;
  private DataLoaderHandler dataLoaderHandler;
//  private TransformationHandler transformationHandler;

  public void setUsername(String username)
  {
    this.username = username;
  }

  public void setPassword(String password)
  {
    this.password = password;
  }

  public void setServerurl(String serverurl)
  {
    this.serverurl = serverurl;
  }

//  public void setMaxPoll(int maxPoll)
//  {
//    this.maxPoll = maxPoll;
//  }

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

  public void setDataRoot(String dataRoot)
  {
    this.dataRoot = dataRoot;
  }

  public void setDebug(boolean debug)
  {
    this.debug = debug;
  }

//  public void setTransformationsRoot(String transformationsRoot)
//  {
//    this.transformationsRoot = transformationsRoot;
//  }
  
  public void setConfigId(String configId)
  {
    this.configId = configId;
  }

  public void setLogDir(String logDir)
  {
    this.logDir = logDir;
  }
  
  @Override
  public void init()
  {
    super.init();
    
//    updateStampHandler = new UpdateStampHandler();
    dataLoaderHandler = new DataLoaderHandler();
//    sfdcHandler = new SfdcHandler();
//    metadataHandler = new MetadataHandler();
//    transformationHandler = new TransformationHandler();
  }

  @Override
  public void execute()
  {
    validate();
    initialize();
    
    dataLoaderHandler.load();
//    Map<String, List<String>> metadata2Update = null;
//    if (full) {
//      metadata2Update = sfdcHandler.extractMetadata(objects);
//    } else {
//      Map<String, Long> metadataUpdatestamps = sfdcHandler.getUpdateStamps(objects);
//      Map<String, UpdateStampHandler.Action> differences = updateStampHandler.calculateDifferences(metadataUpdatestamps);
//  
//      metadata2Update = metadataHandler.collectMetadataToUpdate(differences);
//      metadataHandler.removeMetadataToDelete(differences);
//      
//      // TODO create destructive changes
//    }
//    
//    byte[] packageXml = metadataHandler.createPackageXml(metadata2Update);
//    metadataHandler.savePackageXml(packageXml);
//    ByteArrayOutputStream zipFile = sfdcHandler.retrieveMetadata(metadata2Update);
    
  }

  private void initialize()
  {
    LogWrapper logWrapper = new LogWrapper(this);

//    updateStampHandler.initialize(logWrapper, username, timestamps, !full);
    dataLoaderHandler.initialize(logWrapper, serverurl, username, password, useProxy, proxyHost, proxyPort, dataRoot, configId, logDir, debug);    
    
//    transformationHandler.initialize(logWrapper, username, transformationsRoot, retrieveRoot);
//    
//    sfdcHandler.initialize(logWrapper, maxPoll, dryRun, serverurl, username, password, useProxy, proxyHost, proxyPort, updateStampHandler);
//    metadataHandler.initialize(logWrapper, retrieveRoot, debug, updateStampHandler);
//    zipFileHandler.initialize(logWrapper, debug, transformationHandler);
  }

  private void validate()
  {
    // TODO validate settings
    if (null == dataRoot) {
      throw new BuildException("The property dataRoot must be specified.");
    }
    if (null == configId) {
      throw new BuildException("The property configId must be specified.");
    }
    if (null == logDir) {
      throw new BuildException("The property logDir must be specified.");
    }
  }
  
}
