package task.handler.configuration;

import java.io.File;
import java.io.FileFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.sforce.soap.metadata.Metadata;

/**
 * DeploymentUnitFolder
 *
 * @author  xlehmf
 */
public class DeploymentUnitFolder extends DeploymentUnit {
  
  protected static final String DEFAULT_FOLDER = "unfiled$public";
  
  private boolean includeDefaultFolder;
  
  public DeploymentUnitFolder(Class<? extends Metadata> type, String subDir, String extension) {
    super(type, subDir, extension);
  }

  public DeploymentUnitFolder(Class<? extends Metadata> type, String subDir, String extension, boolean includeDefaultFolder) {
    super(type, subDir, extension);
    
    this.includeDefaultFolder = includeDefaultFolder;
  }
  
  public boolean isIncludeDefaultFolder()
  {
    return includeDefaultFolder;
  }

  /**
   * Extract the full name from the file. This method returns the same value for the meta file and the entity file.
   */
  @Override
  public String getEntityName(File file)
  {
    String name = file.getName();
    
    if (name.endsWith("-meta.xml")) {
      // meta file for folder
      return StringUtils.removeEnd(name, "-meta.xml");
    } else if (name.endsWith(getExtension())) {
      // entity file
      return file.getParentFile().getName() + "/" + name.substring(0, name.lastIndexOf("."));
    }
    
    return null;
  }

  @Override
  public List<File> getFiles(File baseDir)
  {
    List<File> result = new ArrayList<>();
    
    File subDir = new File(baseDir, getSubDir());
    
    File[] files = subDir.listFiles(new FileFilter() {

      @Override
      public boolean accept(File pathname)
      {
        // meta file of folder
        return pathname.isFile() && pathname.getName().endsWith("-meta.xml");
      }
      
    });
    
    if (null != files) {
      for (File file : files) {
        // meta file
        result.add(file);
  
        // meta file describes a subfolder
        File subFolder = new File(subDir, StringUtils.removeEnd(file.getName(), "-meta.xml"));
        File[] subFiles = handleSubFolder(subFolder);
        
        result.addAll(Arrays.asList(subFiles));
      }
    }
    
    if (isIncludeDefaultFolder()) {
      result.addAll(Arrays.asList(handleSubFolder(new File(subDir, DEFAULT_FOLDER))));
    }
    
    return result;
  }

  protected File[] handleSubFolder(File subFolder)
  {
    File[] subFiles = subFolder.listFiles(new FileFilter() {

      @Override
      public boolean accept(File pathname)
      {
        return pathname.isFile() && pathname.getName().endsWith("." + getExtension());
      }
      
    });
    return (null != subFiles) ? subFiles : new File[0];
  }

}
