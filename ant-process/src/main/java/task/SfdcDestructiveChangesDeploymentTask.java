package task;

import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.tuple.Triple;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Taskdef;

import task.handler.ChecksumHandler;
import task.handler.DestructiveChangesHandler;
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

  private ChecksumHandler checksumHandler;
  private SfdcHandler sfdcHandler;
  private DestructiveChangesHandler destructiveHandler;

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

  @Override
  public void init()
    throws BuildException
  {
    super.init();
    
    checksumHandler = new ChecksumHandler();
    sfdcHandler = new SfdcHandler();
    destructiveHandler = new DestructiveChangesHandler();
  }

  @Override
  public void execute()
  {
    validate();
    initialize();
    
    List<Triple<String, String, String>> destructiveChanges = destructiveHandler.readDestructiveChanges();
    List<Triple<String, String, String>> filteredDestructiveChanges = checksumHandler.filterDestructiveFiles(destructiveChanges);
    for (Triple<String, String, String> filteredDestructiveChange : filteredDestructiveChanges) {
      try {
        sfdcHandler.deleteMetadata(filteredDestructiveChange, persistedOnly);
        checksumHandler.updateDestructiveTimestamp(filteredDestructiveChange);
      } catch (BuildException e) {
        // only set a property to prevent other deploy steps from being executed
        getProject().setProperty(PROPERTY_FAILED_DEPLOY_STEP, getTaskName());
      }
    }
  }

  private void initialize()
  {
    LogWrapper logWrapper = new LogWrapper(this);

    checksumHandler.initialize(logWrapper, checksums, true, dryRun);
    sfdcHandler.initialize(this, maxPoll, dryRun, serverurl, username, password, useProxy, proxyHost, proxyPort, null);
    destructiveHandler.initialize(logWrapper, deployRoot, destructiveFile);
  }

  private void validate()
  {
    String step = getProject().getProperty(PROPERTY_FAILED_DEPLOY_STEP);
    if (StringUtils.isNotEmpty(step)) {
      log(String.format("A previous build step (%s) failed, therefore destructive changes are not deployed.", step));
      return;
    }
  }
  
}
