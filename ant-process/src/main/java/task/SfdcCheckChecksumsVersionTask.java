package task;

import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Taskdef;

import task.handler.ChecksumHandler;
import task.handler.LogWrapper;
import task.handler.SfdcHandler;

/**
 * SfdcCheckChecksumsVersionTask
 *
 * @author  xlehmf
 */
public class SfdcCheckChecksumsVersionTask
  extends Taskdef
{

  private String username;
  private String password;
  private String serverurl;
  private int maxPoll;
  private boolean useProxy;
  private String proxyHost;
  private int proxyPort;
  private String sfdcName;
  private String checksums;
  private String gitVersion;
  private boolean dryRun;

  private ChecksumHandler checksumHandler;
  private SfdcHandler sfdcHandler;

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

  public void setSfdcName(String sfdcName)
  {
    this.sfdcName = sfdcName;
  }
  
  public void setDryRun(boolean dryRun)
  {
    this.dryRun = dryRun;
  }
  
  public void setGitVersion(String gitVersion)
  {
    this.gitVersion = gitVersion;
  }

  public void setChecksums(String checksums)
  {
    this.checksums = checksums;
  }

  @Override
  public void init()
    throws BuildException
  {
    super.init();
    
    checksumHandler = new ChecksumHandler();
    sfdcHandler = new SfdcHandler();
  }

  @Override
  public void execute()
  {
    validate();
    initialize();
    
    Map<String, String> checksumMap = sfdcHandler.retrieveChecksums(sfdcName);
    checksumHandler.replaceChecksums(checksumMap);
    checksumHandler.validateGitVersion(gitVersion);
  }

  private void initialize()
  {
    LogWrapper logWrapper = new LogWrapper(this);

    checksumHandler.initialize(logWrapper, checksums, false, dryRun);
    sfdcHandler.initialize(this, maxPoll, false, serverurl, username, password, useProxy, proxyHost, proxyPort, null);
  }

  private void validate()
  {
    if (StringUtils.isBlank(sfdcName)) {
      throw new BuildException("The property sfdcName must be specified.");
    }
    if (StringUtils.isBlank(gitVersion)) {
      throw new BuildException("The property gitVersion must be specified.");
    }
  }
  
}
