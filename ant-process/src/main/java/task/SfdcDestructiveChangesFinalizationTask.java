package task;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.tuple.Triple;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Taskdef;

import task.handler.ChecksumHandler;
import task.handler.DestructiveChangesHandler;
import task.handler.LogWrapper;

/**
 * SfdcDestructiveChangesFinalizationTask
 *
 * @author xlehmf
 */
public class SfdcDestructiveChangesFinalizationTask
  extends Taskdef implements SfdcTaskConstants
{

  private boolean dryRun;
  private String deployRoot;
  private String destructiveFile;
  private String checksums;

  private ChecksumHandler checksumHandler;
  private DestructiveChangesHandler destructiveHandler;

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

  @Override
  public void init()
    throws BuildException
  {
    super.init();
    
    checksumHandler = new ChecksumHandler();
    destructiveHandler = new DestructiveChangesHandler();
  }

  @Override
  public void execute()
  {
    validate();
    initialize();
    
    List<Triple<String, String, String>> updatedDestructiveChanges = new ArrayList<>(); 
    
    List<Triple<String, String, String>> destructiveChanges = destructiveHandler.readDestructiveChanges();
    for (Triple<String, String, String> destructiveChange : destructiveChanges) {
      Triple<String, String, String> updatedDestructiveChange = destructiveChange;
      if (StringUtils.isEmpty(destructiveChange.getRight())) {
        String timestamp = checksumHandler.getDestructiveTimestamp(destructiveChange);
        if (StringUtils.isNotEmpty(timestamp)) {
          updatedDestructiveChange = Triple.of(destructiveChange.getLeft(), destructiveChange.getMiddle(), timestamp);
        }
      }
      updatedDestructiveChanges.add(updatedDestructiveChange);
    }
    
    destructiveHandler.writeDestructiveChanges(updatedDestructiveChanges);
  }

  private void initialize()
  {
    LogWrapper logWrapper = new LogWrapper(this);

    checksumHandler.initialize(logWrapper, checksums, true, dryRun);
    destructiveHandler.initialize(logWrapper, deployRoot, destructiveFile);
  }

  private void validate()
  {
    // nothing to be validated here
  }
  
}
