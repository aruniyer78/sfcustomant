/*
 *  Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.File;
import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;

import com.salesforce.dataloader.exception.ProcessInitializationException;
import com.salesforce.dataloader.process.ProcessRunner;
import com.salesforce.dataloader.security.EncryptionUtil;

/**
 * DeploymentHandler
 *
 * @author  XLEHMF
 */
public class DataLoaderHandler
{

  private LogWrapper logWrapper;
  private String serverurl;
  private String username;
  private String password;
  private boolean useProxy;
  private String proxyHost;
  private int proxyPort;
  private boolean debug;
  private String dataRoot;
  private String configId;
  private String logDir;
  
  @SuppressWarnings("hiding")
  public void initialize(LogWrapper logWrapper,
                         String serverurl,
                         String username,
                         String password,
                         boolean useProxy,
                         String proxyHost,
                         int proxyPort,
                         String dataRoot,
                         String configId,
                         String logDir,
                         boolean debug)
  {
    this.logWrapper = logWrapper;
    this.serverurl = serverurl;
    this.username = username;
    this.logDir = logDir;
    
    try {
      this.password = new EncryptionUtil().encryptString(password);
    }
    catch (GeneralSecurityException e) {
      e.printStackTrace();
      
      throw new BuildException(String.format("Error encrypting password: %s.", e.getMessage()), e);
    }
    
    this.useProxy = useProxy;
    this.proxyHost = proxyHost;
    this.proxyPort = proxyPort;
    this.debug = debug;
    this.dataRoot = dataRoot;
    this.configId = configId;
    
    validate();
  }

  private void validate()
  {
    if (null == logWrapper) {
      throw new BuildException("DataLoaderHandler (log wrapper) is not properly initialized.");
    }
    if (null == serverurl) {
      throw new BuildException("DataLoaderHandler (server URL) is not properly initialized.");
    }
    if (null == username) {
      throw new BuildException("DataLoaderHandler (userName) is not properly initialized.");
    }
    if (null == password) {
      throw new BuildException("DataLoaderHandler (password) is not properly initialized.");
    }
    if (useProxy && (null == proxyHost || 0 == proxyPort)) {
      throw new BuildException("DataLoaderHandler (proxy settings) is not properly initialized.");
    }
  }

  public void load()
  {
    File logFile = new File(logDir, configId + ".log");
    // overrideMap.put("process.outputError" value="c:\dataloader\errorInsertArtist.csv"/>
    File errorFile = new File(logDir, "errorInsert" + StringUtils.capitalize(configId) + ".csv");
    // overrideMap.put("process.outputSuccess" value="c:\dataloader\successInsertArtist.csv"/>
    File successFile = new File(logDir, "successInsert" + StringUtils.capitalize(configId) + ".csv");
    
    File configRoot = new File(dataRoot, configId);
    File mappingFile = new File(configRoot, configId + ".sdl");
    // overrideMap.put("dataAccess.name" value="c:\dataloader\Artists_1_100.csv" />
    File dataFile = new File(configRoot, configId + ".csv");
    
    Map<String, String> overrideMap = new HashMap<>();
    overrideMap.put("sfdc.debugMessages", Boolean.toString(debug));
    overrideMap.put("sfdc.debugMessagesFile", logFile.getAbsolutePath());
    overrideMap.put("sfdc.endpoint", serverurl);
    overrideMap.put("sfdc.username", username);
    overrideMap.put("sfdc.password", password);
    overrideMap.put("sfdc.timeoutSecs", "540");
    overrideMap.put("sfdc.loadBatchSize", "200");
    overrideMap.put("sfdc.entity", configId);
    if (useProxy) {
      overrideMap.put("sfdc.proxyHost", proxyHost);
      overrideMap.put("sfdc.proxyPort", Integer.toString(proxyPort));
    }
    overrideMap.put("process.operation", "insert");
    overrideMap.put("process.mappingFile", mappingFile.getAbsolutePath());
    overrideMap.put("process.outputError", errorFile.getAbsolutePath());
    overrideMap.put("process.outputSuccess", successFile.getAbsolutePath());
    overrideMap.put("dataAccess.name", dataFile.getAbsolutePath());
    overrideMap.put("dataAccess.type", "csvRead");
    overrideMap.put("process.initialLastRunDate", "2007-06-06T00:00:00.000-0800");
    
    try {
      System.setProperty("salesforce.config.dir", configRoot.getAbsolutePath());
      
      ProcessRunner pr = ProcessRunner.getInstance(configId);
      pr.setName(configId);
      pr.getConfigOverrideMap().putAll(overrideMap);
      pr.run();
    }
    catch (ProcessInitializationException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
      
      throw new BuildException(String.format("Error executing data loader: %s", e.getMessage()), e);
    }
  }

  
  
}