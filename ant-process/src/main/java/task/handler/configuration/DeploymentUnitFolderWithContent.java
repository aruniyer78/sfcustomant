package task.handler.configuration;

import java.io.File;
import java.io.FileFilter;

import org.apache.commons.lang3.StringUtils;

import com.sforce.soap.metadata.Metadata;

/**
 * DeploymentUnitFolderWithContent
 *
 * Assumptions:
 * -there is a meta file for the folder itself
 * -all documents must be within folders
 * -each document has a meta file
 * 
 * @author  xlehmf
 */
public class DeploymentUnitFolderWithContent extends DeploymentUnitFolder {
  
  public DeploymentUnitFolderWithContent(Class<? extends Metadata> type, String subDir, String extension) {
    super(type, subDir, extension, false);
  }
  
  public DeploymentUnitFolderWithContent(Class<? extends Metadata> type, String subDir, String extension, boolean includeDefaultFolder) {
    super(type, subDir, extension, includeDefaultFolder);
  }

  /**
   * Extract the full name from the file. This method returns the same value for the meta file and the entity file.
   */
  @Override
  public String getEntityName(File file)
  {
    String name = file.getName();
    
    String parent = file.getParentFile().getName();
    if (name.endsWith("-meta.xml") && getSubDir().equals(parent)) {
      // meta file for folder
      return StringUtils.removeEnd(name, "-meta.xml");
    } else {
      // entity file
      if (name.endsWith("-meta.xml")) {
        name = StringUtils.remove(name, "-meta.xml");
      }
      if (null != getExtension()) {
        name = StringUtils.removeEnd(name, "." + getExtension());
      }
      return file.getParentFile().getName() + "/" + name;
    }
  }

  @Override
  protected File[] handleSubFolder(File subFolder)
  {
    File[] subFiles = subFolder.listFiles(new FileFilter() {

      @Override
      public boolean accept(File pathname)
      {
        return pathname.isFile();
      }
      
    });
    return (null != subFiles) ? subFiles : new File[0];
  }
}
