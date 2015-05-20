package task;

import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Taskdef;

import task.handler.ChecksumHandler;
import task.handler.DestructiveChangesHandler;
import task.handler.MetadataHandler;
import task.handler.ZipFileHandler;
import task.handler.DestructiveChangesHandler.DestructiveChange;
import task.handler.DestructiveChangesHandler.DestructiveChange.MODE;
import task.handler.LogWrapper;
import task.handler.SfdcHandler;

/**
 * SfdcDestructiveChangesDeploymentTask
 *
 * @author xlehmf
 */
public class SfdcDestructiveChangesDeploymentTask
  extends Taskdef implements SfdcTaskConstants
{

  private boolean dryRun;
  private boolean debug;
  private String username;
  private String password;
  private String serverurl;
  private int maxPoll;
  private boolean useProxy;
  private String proxyHost;
  private int proxyPort;
  private String deployRoot;
  private String destructiveFile;
  private String checksums;
  private boolean persistedOnly;
  private MODE mode;

  private ChecksumHandler checksumHandler;
  private SfdcHandler sfdcHandler;
  private DestructiveChangesHandler destructiveHandler;
  private ZipFileHandler zipFileHandler;
  private MetadataHandler metadataHandler;

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

  public void setMaxPoll(int maxPoll)
  {
    this.maxPoll = maxPoll;
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

  public void setDeployRoot(String deployRoot)
  {
    this.deployRoot = deployRoot;
  }

  public void setDryRun(boolean dryRun)
  {
    this.dryRun = dryRun;
  }

  public void setDestructiveFile(String destructiveFile)
  {
    this.destructiveFile = destructiveFile;
  }

  public void setChecksums(String checksums)
  {
    this.checksums = checksums;
  }

  public void setPersistedOnly(boolean persistedOnly)
  {
    this.persistedOnly = persistedOnly;
  }

  public void setDebug(boolean debug)
  {
    this.debug = debug;
  }

  public void setMode(String mode)
  {
    try {
      this.mode = MODE.valueOf(StringUtils.upperCase(mode));
    } catch (IllegalArgumentException | NullPointerException e) {
      throw new BuildException("The mode must be either 'pre' or 'post'.");
    }
  }

  @Override
  public void init()
    throws BuildException
  {
    super.init();
    
    checksumHandler = new ChecksumHandler();
    sfdcHandler = new SfdcHandler();
    destructiveHandler = new DestructiveChangesHandler();
    metadataHandler = new MetadataHandler();
    zipFileHandler = new ZipFileHandler();
  }

  @Override
  public void execute()
  {
    if (!validate()) {
      return;
    }
    initialize();
    
    List<DestructiveChange> destructiveChanges = destructiveHandler.readDestructiveChanges(mode);
    List<DestructiveChange> filteredDestructiveChanges = checksumHandler.filterDestructiveFiles(destructiveChanges);
    while (!filteredDestructiveChanges.isEmpty()) {
      List<DestructiveChange> bunchOfChanges = sfdcHandler.extractNextChanges(filteredDestructiveChanges);
      try {
        sfdcHandler.deleteMetadata(bunchOfChanges, persistedOnly, zipFileHandler);
        checksumHandler.updateDestructiveTimestamps(bunchOfChanges);
      } catch (BuildException e) {
        log(String.format("Error deploying destructive change(s): %s.", e.getMessage()));

        // only set a property to prevent other deploy steps from being executed
        getProject().setProperty(PROPERTY_FAILED_DEPLOY_STEP, getOwningTarget().getName());
        
        break;
      }
    }
  }

  private void initialize()
  {
    LogWrapper logWrapper = new LogWrapper(this);

    checksumHandler.initialize(logWrapper, checksums, true, dryRun);
    sfdcHandler.initialize(this, maxPoll, dryRun, false, serverurl, username, password, useProxy, proxyHost, proxyPort, null);
    destructiveHandler.initialize(logWrapper, deployRoot, destructiveFile);
    metadataHandler.initialize(logWrapper, deployRoot, debug);
    zipFileHandler.initialize(logWrapper, debug, metadataHandler);
  }

  private boolean validate()
  {
    String step = getProject().getProperty(PROPERTY_FAILED_DEPLOY_STEP);
    if (StringUtils.isNotEmpty(step)) {
      log(String.format("A previous build step (%s) failed, therefore destructive changes are not deployed.", step));
      return false;
    }
    
    return true;
  }
  
}
