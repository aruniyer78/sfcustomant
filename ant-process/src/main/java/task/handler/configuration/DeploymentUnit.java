package task.handler.configuration;

import java.io.File;
import java.io.FileFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.sforce.soap.metadata.Metadata;

/**
 * DeploymentUnit
 *
 * @author  xlehmf
 */
public class DeploymentUnit {
  private Class<? extends Metadata> type;
  private List<Class<? extends Metadata>> children;
  private String subDir;
  private String extension;
  
  public DeploymentUnit(Class<? extends Metadata> type, List<Class<? extends Metadata>> children, String subDir, String extension) {
    this.type = type;
    this.children = children;
    this.subDir = subDir;
    this.extension = extension;
  }
  
  public DeploymentUnit(Class<? extends Metadata> type, String subDir, String extension) {
    this(type, null, subDir, extension);
  }
  
  public DeploymentUnit(Class<? extends Metadata> type, String subDir) {
    this(type, subDir, StringUtils.uncapitalize(type.getSimpleName()));
  }
  
  public DeploymentUnit(Class<? extends Metadata> type) {
    this(type, StringUtils.uncapitalize(type.getSimpleName()), StringUtils.uncapitalize(type.getSimpleName()));
  }
  
  public DeploymentUnit(Class<? extends Metadata> type, List<Class<? extends Metadata>> children) {
    this(type, children, StringUtils.uncapitalize(type.getSimpleName()), StringUtils.uncapitalize(type.getSimpleName()));
  }

  public String getTypeName()
  {
    return type.getSimpleName();
  }
  
  public List<String> getChildNames()
  {
    List<String> result = new ArrayList<>();
    if (null != children) {
      for (Class<? extends Metadata> clazz: children) {
        result.add(clazz.getSimpleName());
      }
    }
    return result;
  }
  
  public boolean isChild(String nameOfChild)
  {
    if (null != children) {
      for (Class<? extends Metadata> clazz: children) {
        if (clazz.getSimpleName().equals(nameOfChild)) {
          return true;
        }
      }
    }
    return false;
  }

  public String getSubDir()
  {
    return subDir;
  }

  public String getExtension()
  {
    return extension;
  }

  /**
   * Extract the entity name from the file. This method returns the same value for the meta file and the entity file.
   */
  public String getEntityName(File file)
  {
    String name = file.getName();
    return name.substring(0, name.lastIndexOf("."));
  }

  /**
   * Gets a list of files to include in the ZIP file for the deployment.
   */
  public List<File> getFiles(File baseDir)
  {
    File dir = new File(baseDir, subDir);
    
    File[] mainFiles = dir.listFiles(new FileFilter() {
      
      @Override
      public boolean accept(File pathname)
      {
        return pathname.isFile() && pathname.getName().endsWith("." + extension);
      }
    });
    
    return null != mainFiles ? Arrays.asList(mainFiles) : new ArrayList<File>();
  }
  
  /**
   * Get the entity name from the entry in the metadata.
   */
  public String getEntityName(String metadataEntry)
  {
    return metadataEntry;
  }
}
