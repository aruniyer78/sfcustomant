package task;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Taskdef;

import task.handler.DeploymentInfo;
import task.handler.LogWrapper;
import task.handler.MetadataHandler;
import task.handler.SfdcHandler;
import task.handler.ZipFileHandler;

/**
 * SfdcRunAllTestsTask
 *
 * @author  xlehmf
 */
public class SfdcRunAllTestsTask
  extends Taskdef
  implements SfdcTaskConstants
{

  private String username;
  private String password;
  private String serverurl;
  private int maxPoll;
  private boolean useProxy;
  private String proxyHost;
  private int proxyPort;
  private boolean debug;
  private boolean dryRun;
  private String deployRoot;

  private ZipFileHandler zipFileHandler;
  private SfdcHandler sfdcHandler;
  private MetadataHandler metadataHandler;

  public SfdcRunAllTestsTask()
  {
  }

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

  public void setDebug(boolean debug)
  {
    this.debug = debug;
  }

  public void setDryRun(boolean dryRun)
  {
    this.dryRun = dryRun;
  }

  public void setDeployRoot(String deployRoot)
  {
    this.deployRoot = deployRoot;
  }

  @Override
  public void init()
    throws BuildException
  {
    super.init();

    metadataHandler = new MetadataHandler();
    zipFileHandler = new ZipFileHandler();
    sfdcHandler = new SfdcHandler();
  }

  @Override
  public void execute()
  {
    if (!validate()) {
      return;
    }
    initialize();

    List<DeploymentInfo> deploymentInfos = new ArrayList<>();
    ByteArrayOutputStream zipFile = zipFileHandler.prepareEmptyZipFile();
    sfdcHandler.deployTypes(zipFile, deploymentInfos);
  }

  private void initialize()
  {
    LogWrapper logWrapper = new LogWrapper(this);

    metadataHandler.initialize(logWrapper, deployRoot, debug);
    zipFileHandler.initialize(logWrapper, debug, metadataHandler);
    sfdcHandler.initialize(this,
                           maxPoll,
                           dryRun,
                           true,
                           serverurl,
                           username,
                           password,
                           useProxy,
                           proxyHost,
                           proxyPort,
                           null);
  }

  private boolean validate()
  {
    String step = getProject().getProperty(PROPERTY_FAILED_DEPLOY_STEP);
    if (StringUtils.isNotEmpty(step)) {
      log(String.format("A previous build step (%s) failed, therefore tests have not been executed.", step));
      return false;
    }

    return true;
  }

}
