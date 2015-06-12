/*
 * Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.ByteBuffer;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.codec.DecoderException;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.codec.binary.Hex;
import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;

import task.handler.DestructiveChangesHandler.DestructiveChange;
import task.handler.configuration.DeploymentUnit;

/**
 * ChecksumHandler
 *
 * @author  XLEHMF
 */
public class ChecksumHandler
{

  private static final String PREFIX_UPDATESTAMP_DESTRUCTIVE_CHANGE = "DestructiveChange";
  private static final String KEY_UPDATESTAMP_GIT_VERSION = "GitVersion";

  private Map<String, String> updateStamps;
  private LogWrapper logWrapper;
  private String fileName;
  private boolean loadFile;
  private boolean dryRun;

  private byte[] calculateChecksum(File file)
  {
    try (InputStream fis = new FileInputStream(file)) {

      MessageDigest digest = MessageDigest.getInstance("MD5");
      byte[] buffer = new byte[1024];
      int numRead;
      do {
        numRead = fis.read(buffer);
        if (numRead > 0) {
          digest.update(buffer, 0, numRead);
        }
      }
      while (numRead != -1);

      return digest.digest();
    }
    catch (IOException | NoSuchAlgorithmException e) {
      throw new BuildException(String.format("Error creating checksum for binary file %s: %s.",
                                             file.getName(),
                                             e.getMessage()), e);
    }
  }

  public String getChecksumFromFile(File file)
  {
    byte[] checksum = calculateChecksum(file);

    return Base64.encodeBase64String(checksum);
  }

  public String getChecksumFromContent(String name, byte[] content)
  {
    try {
      MessageDigest digest = MessageDigest.getInstance("MD5");
      digest.update(content);
      byte[] checksum = digest.digest();

      return Base64.encodeBase64String(checksum);
    }
    catch (NoSuchAlgorithmException e) {
      throw new BuildException(String.format("Error creating checksum for content of file %s: %s.",
                                             name,
                                             e.getMessage()), e);
    }
  }

  public boolean isUpdateRequired(DeploymentUnit du, File file)
  {
    String newChecksum = getChecksumFromFile(file);

    String key = getKey(du, file);

    String oldChecksum = updateStamps.get(key);

    return !StringUtils.equals(newChecksum, oldChecksum);
  }

  public Map<String, String> getChecksums()
  {
    return updateStamps;
  }

  /**
   * This method replaces the checksums in the internal cache and saves them in the given file.
   *   
   * @param checksums The checksums to use for replacement.
   */
  public void replaceChecksums(Map<String, String> checksums)
  {
    updateStamps.clear();
    updateStamps.putAll(checksums);

    writeUpdateStampes();
  }

  @SuppressWarnings("hiding")
  public void initialize(LogWrapper logWrapper, String fileName, boolean loadFile, boolean dryRun)
  {
    this.logWrapper = logWrapper;
    this.fileName = fileName;
    this.loadFile = loadFile;
    this.dryRun = dryRun;

    validate();
    initialize();
  }

  private void validate()
  {
    if (null == logWrapper) {
      throw new BuildException("ChecksumHandler (logWrapper) not properly initialized.");
    }
    if (null == fileName) {
      throw new BuildException("ChecksumHandler (fileName) not properly initialized.");
    }
  }

  private void initialize()
  {
    updateStamps = new HashMap<>();

    if (loadFile) {
      File file = new File(fileName);
      if (file.exists()) {
        try (FileReader fr = new FileReader(file); BufferedReader br = new BufferedReader(fr)) {
          String line = null;
          do {
            line = br.readLine();
            if (null != line) {
              int version = determineVersion(line);
              switch (version) {
                case 1 :
                  decodeVersion1(line);
                  break;
                default :
                  decodeVersion0(line);
                  break;
              }
            }
          }
          while (null != line);

          br.close();
        }
        catch (IOException e) {
          updateStamps.clear();

          logWrapper.log(String.format("Error reading update stamps: %s. Continue without update timestamps.",
                                       e.getMessage()));
        }
      }
      else {
        logWrapper.log("Did not find update timestamps. Continue without update timestamps.");
      }
    }
  }

  private String encodeVersion1(Map.Entry<String, String> entry)
    throws UnsupportedEncodingException
  {
    return String.format("1:%s:%s", URLEncoder.encode(entry.getKey(), "UTF-8"), entry.getValue());
  }

  private void decodeVersion1(String line)
    throws UnsupportedEncodingException
  {
    String[] tokens1 = line.split(":");
    if (3 == tokens1.length) {
      String type = URLDecoder.decode(tokens1[1], "UTF-8");
      String value = tokens1[2];

      updateStamps.put(type, value);
    }
  }

  private void decodeVersion0(String line)
    throws UnsupportedEncodingException
  {
    String[] tokens1 = line.split(":");
    if (3 == tokens1.length) {
      String type = URLDecoder.decode(tokens1[1], "UTF-8");
      String value = tokens1[2];

      try {
        byte[] bytes = Hex.decodeHex(value.toCharArray());
        String base64 = Base64.encodeBase64String(bytes);
        updateStamps.put(type, base64);
      }
      catch (DecoderException e) {
        // just ignore
      }
    }
  }

  private int determineVersion(String line)
  {
    if (line.startsWith("1:")) {
      return 1;
    }
    return 0;
  }

  private void writeUpdateStampes()
  {
    if (dryRun) {
      return;
    }

    try (FileWriter fw = new FileWriter(fileName); BufferedWriter bw = new BufferedWriter(fw)) {

      for (Map.Entry<String, String> entry : updateStamps.entrySet()) {
        String line = encodeVersion1(entry);

        bw.write(line);
        bw.newLine();
      }

      bw.close();
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error saving update stamps: %s.", e.getMessage()), e);
    }
  }

  private String getKey(DeploymentUnit du, File file)
  {
    return getKey(du.getTypeName(), file.getName());
  }

  private String getKey(String category, String entityName)
  {
    return category + "/" + entityName;
  }

  public void updateTimestamp(List<DeploymentInfo> deploymentInfos)
  {
    for (DeploymentInfo info : deploymentInfos) {
      if (!info.getTypeSet().isSuppressChecksumUpdate()) {
        for (File file : info.getFileList()) {
          updateTimestamp(info.getDeploymentUnit(), file);
        }
      }
    }
    writeUpdateStampes();
  }

  private void updateTimestamp(DeploymentUnit du, File file)
  {
    String value = getChecksumFromFile(file);

    String key = getKey(du, file);

    updateStamps.put(key, value);
  }

  public List<DestructiveChange> filterDestructiveFiles(List<DestructiveChange> destructiveChanges)
  {
    List<DestructiveChange> filteredDestructiveChanges = new ArrayList<>();

    for (DestructiveChange destructiveChange : destructiveChanges) {
      String key = getDestructiveKey(destructiveChange);
      if (!updateStamps.containsKey(key)) {
        filteredDestructiveChanges.add(destructiveChange);
      }
    }

    return filteredDestructiveChanges;
  }

  private String getDestructiveKey(DestructiveChange destructiveChange)
  {
    return PREFIX_UPDATESTAMP_DESTRUCTIVE_CHANGE + "/" + destructiveChange.getType() + "/"
           + destructiveChange.getFullName();
  }

  public void updateDestructiveTimestamps(List<DestructiveChange> destructiveChanges)
  {
    for (DestructiveChange destructiveChange : destructiveChanges) {
      String key = getDestructiveKey(destructiveChange);

      byte[] bytes = ByteBuffer.allocate(8).putLong(System.currentTimeMillis()).array();
      String value = Base64.encodeBase64String(bytes);

      updateStamps.put(key, value);

      destructiveChange.setTimestamp(value);
    }
    writeUpdateStampes();
  }

  public String getDestructiveTimestamp(DestructiveChange destructiveChange)
  {
    String key = getDestructiveKey(destructiveChange);

    return updateStamps.get(key);
  }

  public void updateGitVersionTimestamp(String version)
  {
    updateStamps.put(KEY_UPDATESTAMP_GIT_VERSION, version);
  }

  public void validateGitVersion(String gitVersion)
  {
    String deployedGitVersion = updateStamps.get(KEY_UPDATESTAMP_GIT_VERSION);

    if (!StringUtils.equals(deployedGitVersion, gitVersion)) {
      logWrapper.log(String.format("The Git version %s does not match the deployed version %s.",
                                   gitVersion,
                                   deployedGitVersion));

      throw new BuildException(String.format("The version of the deployed metadata and the local metadata version do not match. Please deploy the metadata first."));
    }

    logWrapper.log(String.format("Git version matches the deployed version %s.", gitVersion));
  }
}
