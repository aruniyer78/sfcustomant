package task.handler.configuration;

import java.io.File;
import java.io.FileFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.sforce.soap.metadata.Metadata;

/**
 * DeploymentUnitWithContent
 *
 * @author  xlehmf
 */
public class DeploymentUnitWithContent
  extends DeploymentUnit
{

  public DeploymentUnitWithContent(Class<? extends Metadata> type, String subDir, String extension)
  {
    super(type, subDir, extension);
  }

  /**
   * Extract the full name from the file. This method returns the same value for the meta file and the entity file.
   */
  @Override
  public String getEntityName(File file)
  {
    String name = file.getName();
    if (name.endsWith("-meta.xml")) {
      name = StringUtils.removeEnd(name, "-meta.xml");
    }
    return name.substring(0, name.lastIndexOf("."));
  }

  @Override
  public List<File> getFiles(File baseDir)
  {
    File dir = new File(baseDir, getSubDir());
    
    File[] mainFiles = dir.listFiles(new FileFilter() {
      
      @Override
      public boolean accept(File pathname)
      {
        return pathname.isFile() && (pathname.getName().endsWith("." + getExtension()) || pathname.getName().endsWith("-meta.xml"));
      }
    });
    
    return null != mainFiles ? Arrays.asList(mainFiles) : new ArrayList<File>();
  }

}
