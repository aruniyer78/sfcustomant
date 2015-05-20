package task.handler.configuration;

import java.io.File;
import java.io.FileFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.sforce.soap.metadata.Metadata;

/**
 * DeploymentUnitWithContentAndZoning
 * 
 * The only difference to the normal deployment unit with content is,
 * that this one collects all files from all direct sub directories.
 *
 * @author  xlehmf
 */
public class DeploymentUnitWithContentAndZoning
  extends DeploymentUnitWithContent
{

  public DeploymentUnitWithContentAndZoning(Class<? extends Metadata> type, String subDir, String extension)
  {
    super(type, subDir, extension);
  }

  @Override
  public List<File> getFiles(File baseDir)
  {
    List<File> result = new ArrayList<>();
    
    final List<File> dirs = new ArrayList<>();
    dirs.add(new File(baseDir, getSubDir()));
    
    while (!dirs.isEmpty()) {
      File dir = dirs.remove(0);
      
      File[] mainFiles = dir.listFiles(new FileFilter() {
      
        @Override
        public boolean accept(File pathname)
        {
          if (pathname.isDirectory()) {
            dirs.add(pathname);
          }
          return pathname.isFile() && (pathname.getName().endsWith("." + getExtension()) || pathname.getName().endsWith("-meta.xml"));
        }
      });
      
      if (null != mainFiles) {
        result.addAll(Arrays.asList(mainFiles));
      }
    }
    
    return result;
  }

}
