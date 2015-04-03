/*
 * Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.output.FileWriterWithEncoding;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.tuple.Triple;
import org.apache.tools.ant.BuildException;

/**
 * DestructiveChangesHandler
 *
 * @author  XLEHMF
 */
public class DestructiveChangesHandler
{

  private LogWrapper logWrapper;
  private String destructiveRoot;
  private String destructiveFile;

  @SuppressWarnings("hiding")
  public void initialize(LogWrapper logWrapper, String destructiveRoot, String destructiveFile)
  {
    this.logWrapper = logWrapper;
    this.destructiveRoot = destructiveRoot;
    this.destructiveFile = destructiveFile;

    validate();
  }

  private void validate()
  {
    if (null == logWrapper) {
      throw new BuildException("DestructiveChangesHandler (logWrapper) not properly initialized.");
    }
    if (null == destructiveRoot) {
      throw new BuildException("DestructiveChangesHandler (destructiveRoot) not properly initialized.");
    }
    if (null == destructiveFile) {
      throw new BuildException("DestructiveChangesHandler (destructiveFile) not properly initialized.");
    }
  }

  public List<Triple<String, String, String>> readDestructiveChanges()
  {
    List<Triple<String, String, String>> result = new ArrayList<>();
    
    File file = new File(destructiveRoot, destructiveFile);

    try (FileInputStream fis = new FileInputStream(file); InputStreamReader isr = new InputStreamReader(fis, "UTF-8"); BufferedReader br = new BufferedReader(isr)) {
      String line = null;
      do {
        line = br.readLine();
        if (StringUtils.isNotEmpty(line)) {
          String trimmed = line.trim();
          if (!StringUtils.startsWith(trimmed, "#")) {
            String[] tokens = trimmed.split(":");
            if (2 == tokens.length) {
              result.add(Triple.of(tokens[0], tokens[1], (String)null));
            } else if (3 == tokens.length) {
              result.add(Triple.of(tokens[0], tokens[1], tokens[2]));
            } else {
              throw new BuildException(String.format("Error reading destructive changes. File format error. The format is <type>:<name>[:<code>]."));
            }
          }
        }
      } while (line != null);
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error reading destructive changes: %s.", e.getMessage()), e);
    }

    return result;
  }

  public void writeDestructiveChanges(List<Triple<String, String, String>> destructiveChanges)
  {
    File file = new File(destructiveRoot, destructiveFile);

    List<String> comments = new ArrayList<>();
    
    try (FileInputStream fis = new FileInputStream(file); InputStreamReader isr = new InputStreamReader(fis, "UTF-8"); BufferedReader br = new BufferedReader(isr)) {
      String line = null;
      do {
        line = br.readLine();
        if (StringUtils.isNotEmpty(line)) {
          String trimmed = line.trim();
          if (StringUtils.startsWith(trimmed, "#")) {
            comments.add(trimmed);
          }
        }
      } while (line != null);
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error reading destructive changes: %s.", e.getMessage()), e);
    }
    
    try (FileWriterWithEncoding fw = new FileWriterWithEncoding(file, "UTF-8"); BufferedWriter bw = new BufferedWriter(fw)) {
      for (String line : comments) {
        bw.write(line);
        bw.newLine();
      }
      for (Triple<String, String, String> triple : destructiveChanges) {
        if (null != triple.getRight()) {
          bw.write(String.format("%s:%s:%s", triple.getLeft(), triple.getMiddle(), triple.getRight()));
        } else {
          bw.write(String.format("%s:%s", triple.getLeft(), triple.getMiddle()));
        }
        bw.newLine();
      }
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error writing destructive changes: %s.", e.getMessage()), e);
    }
  }

}
