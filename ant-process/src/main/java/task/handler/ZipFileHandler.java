/*
 * Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.LogLevel;

import task.handler.TransformationHandler.Operation;
import task.handler.configuration.DeploymentUnit;

/**
 * ZipFileHandler
 *
 * @author  XLEHMF
 */
public class ZipFileHandler
{

  public class InputStreamWrapper
    extends InputStream
  {

    private InputStream is;

    InputStreamWrapper(InputStream is)
    {
      this.is = is;
    }

    @Override
    public int available()
      throws IOException
    {
      return is.available();
    }

    @Override
    public void close()
      throws IOException
    {
      // just ignore close
      // is.close();
    }

    @Override
    public synchronized void mark(int readlimit)
    {
      is.mark(readlimit);
    }

    @Override
    public boolean markSupported()
    {
      return is.markSupported();
    }

    @Override
    public int read()
      throws IOException
    {
      return is.read();
    }

    @Override
    public int read(byte[] b, int off, int len)
      throws IOException
    {
      return is.read(b, off, len);
    }

    @Override
    public int read(byte[] b)
      throws IOException
    {
      return is.read(b);
    }

    @Override
    public synchronized void reset()
      throws IOException
    {
      is.reset();
    }

    @Override
    public long skip(long n)
      throws IOException
    {
      return is.skip(n);
    }
  }

  private static final int MAXIMUM_FILES_IN_REVIEW = 60;
  private static final String DIRECTORY_CLASSES = "classes";
  private static final String DIRECTORY_REVIEW = "review";
  private static final String ZIP_BASE_DIR = "unpackaged";
  private static final String FILE_NAME_PACKAGE_XML = ZIP_BASE_DIR + "/package.xml";
  private static final String FILE_NAME_DESTRUCTIVE_CHANGES_XML = ZIP_BASE_DIR + "/destructiveChanges.xml";
  
  private LogWrapper logWrapper;
  private boolean debug;
  private MetadataHandler metadataHandler;

  @SuppressWarnings("hiding")
  public void initialize(LogWrapper logWrapper, boolean debug, MetadataHandler metadataHandler)
  {
    this.logWrapper = logWrapper;
    this.debug = debug;
    this.metadataHandler = metadataHandler;

    validate();
  }

  private void validate()
  {
    if (null == logWrapper) {
      throw new BuildException("ZipFileHandler (logWrapper) is not initialized.");
    }
    if (null == metadataHandler) {
      throw new BuildException("ZipFileHandler (metadataHandler) is not initialized.");
    }
  }

  public void saveZipFile(String prefix, ByteArrayOutputStream zipFile)
  {
    // debugging
    if (debug) {
      String fileName = prefix + "-" + System.currentTimeMillis() + ".zip";

      logWrapper.log(String.format("Save ZIP file to %s.", fileName));

      File tmpDir = new File("tmp");
      tmpDir.mkdirs();
      File tmp = new File(tmpDir, fileName);

      try (FileOutputStream fos = new FileOutputStream(tmp)) {
        fos.write(zipFile.toByteArray());
      }
      catch (IOException e) {
        logWrapper.log(String.format("Error preparing ZIP for deployment: %s.", e.getMessage()),
                       e,
                       LogLevel.WARN.getLevel());
      }
    }
  }

  public ByteArrayOutputStream prepareZipFile(List<DeploymentInfo> deploymentInfos, TransformationHandler transformationHandler)
  {
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    
    int counter = 0;
    try (ZipOutputStream zos = new ZipOutputStream(baos)) {
      for (DeploymentInfo info : deploymentInfos) {
        DeploymentUnit du = info.getDeploymentUnit();

        String type = du.getTypeName();

        logWrapper.log(String.format("Handle type %s for ZIP file.", type));

        List<File> addedFiles = new ArrayList<>();
        Set<String> addedEntities = new HashSet<>();
        for (File file : info.getFileList()) {
          logWrapper.log(String.format("Add %s.", file.getName()));

          String zipEntryName = createZipEntryName(du, file);

          try (FileInputStream fis = new FileInputStream(file)) {
            ByteArrayOutputStream fileBaos = transformationHandler.transform(fis, file, Operation.DEPLOY);
            if (null != fileBaos) {
              zos.putNextEntry(new ZipEntry(zipEntryName));
              zos.write(fileBaos.toByteArray());
              zos.closeEntry();
              
              addedFiles.add(file);
              addedEntities.add(info.getDeploymentUnit().getEntityName(file));
              counter++;
            }
          }
          catch (Exception e) {
            throw new BuildException(String.format("Error reading metadata for type %s and file %s: %s",
                                                   type,
                                                   file.getName(),
                                                   e.getMessage()), e);
          }
        }
        
        info.getFileList().clear();
        info.getFileList().addAll(addedFiles);
        info.getEntityNames().clear();
        info.getEntityNames().addAll(addedEntities);
      }
      
      byte[] packageXml = metadataHandler.createPackageXml(deploymentInfos);
      metadataHandler.savePackageXml(MetadataHandler.PREFFIX_METADATA, packageXml);
      
      zos.putNextEntry(new ZipEntry(FILE_NAME_PACKAGE_XML));
      zos.write(packageXml);
      zos.closeEntry();
    }
    catch (IOException ioe) {
      throw new BuildException(String.format("Error preparing ZIP for deployment: %s.", ioe.getMessage()), ioe);
    }

    return (counter != 0) ? baos : null;
  }
  
  public ByteArrayOutputStream prepareDestructiveZipFile(String type, List<String> fullNames)
  {
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    
    try (ZipOutputStream zos = new ZipOutputStream(baos)) {
      logWrapper.log(String.format("Handle type %s for ZIP file containing destructive changes.", type));
      
      // package.xml
      byte[] packageXml = metadataHandler.createPackageXml(new ArrayList<DeploymentInfo>());
      // no need to save an empty package.xml
      
      zos.putNextEntry(new ZipEntry(FILE_NAME_PACKAGE_XML));
      zos.write(packageXml);
      zos.closeEntry();
      
      // destructiveChanges.xml
      Map<String, List<String>> destructiveChanges = new HashMap<>();
      destructiveChanges.put(type,  fullNames);
      
      byte[] destructiveChangesXml = metadataHandler.createPackageXml(destructiveChanges, false);
      metadataHandler.savePackageXml(MetadataHandler.PREFIX_DESTRUCTIVE_CHANGES, packageXml);

      zos.putNextEntry(new ZipEntry(FILE_NAME_DESTRUCTIVE_CHANGES_XML));
      zos.write(destructiveChangesXml);
      zos.closeEntry();
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error preparing ZIP for deployment: %s.", e.getMessage()), e);
    }

    return baos;
  }

  private String createZipEntryName(DeploymentUnit du, File file)
  {
    StringBuilder sb = new StringBuilder();

    File loopFile = file;
    String filePart = null;
    do {
      filePart = loopFile.getName();

      if (0 < sb.length()) {
        sb.insert(0, "/");
      }
      sb.insert(0, filePart);

      loopFile = loopFile.getParentFile();
    }
    while (null != loopFile && !filePart.equals(du.getSubDir()));

    sb.insert(0, "/");
    sb.insert(0, ZIP_BASE_DIR);

    return sb.toString();
  }

  public void extractZipFile(String retrieveRoot, ByteArrayOutputStream zipFile, TransformationHandler transformationHandler, ChecksumHandler checksumHandler)
  {
    logWrapper.log("Extract ZIP file.");

    ByteArrayInputStream bais = new ByteArrayInputStream(zipFile.toByteArray());

    try (ZipInputStream zis = new ZipInputStream(bais)) {

      ZipEntry entry = null;
      do {
        entry = zis.getNextEntry();
        if (null != entry) {
          String fileName = entry.getName();
          
          if (fileName.startsWith(ZIP_BASE_DIR)) {
            fileName = fileName.substring(1 + ZIP_BASE_DIR.length());
          }
          
          File file = handleZoning(retrieveRoot, fileName);
          
          InputStreamWrapper isw = new InputStreamWrapper(zis);

          ByteArrayOutputStream fileBaos = transformationHandler.transform(isw, file, Operation.RETRIEVE);
          if (null != fileBaos) {
            byte[] fileContent = fileBaos.toByteArray();
            
            checkProtectedZones(file, fileContent, checksumHandler);
            
            File parentFile = file.getParentFile();
            if (!parentFile.exists() && !parentFile.mkdirs()) {
              throw new BuildException(String.format("Error creating directories while extracting file: %s.", file.getName()));
            }
            
            try (FileOutputStream fos = new FileOutputStream(file)) {
              fos.write(fileContent);
            }
          }
        }
      }
      while (null != entry);

      logWrapper.log("Extracted ZIP file successfully.");
    }
    catch (IOException ioe) {
      throw new BuildException(String.format("Error handling ZIP file: %s.", ioe.getMessage()), ioe);
    }
  }

  private void checkProtectedZones(File file, byte[] fileContent, ChecksumHandler checksumHandler)
  {
    String subDirectory = getClassesSubDirectory(file);
    if (null != subDirectory && !DIRECTORY_REVIEW.equals(subDirectory)) {
      String checksumFromFile = checksumHandler.getChecksumFromFile(file);
      String checksumFromContent = checksumHandler.getChecksumFromContent(file.getName(), fileContent);
      if (!StringUtils.equals(checksumFromFile, checksumFromContent)) {
        throw new BuildException(String.format("Changes on files outside of the sub directory '%s' are not allowed.", DIRECTORY_REVIEW));
      }
    }
  }

  private String getClassesSubDirectory(File file)
  {
    if (DIRECTORY_CLASSES.equals(file.getParentFile().getParent())) {
      return file.getParent();
    }
    return null;
  }

  private File handleZoning(String retrieveRoot, String fileName)
  {
    File result = new File(retrieveRoot, fileName);
    
    // zoning is relevant for classes only 
    if (fileName.startsWith(DIRECTORY_CLASSES) && !result.exists()) {
      // check if file is somewhere available already
      File classesDir = result.getParentFile();
      if (classesDir.exists()) {
        File[] classesSubDirs = getSubDirectories(classesDir);
        if (null != classesSubDirs && 0 < classesSubDirs.length) {
          // look in sub dirs for the file
          int filesInReview = 0;
          for (File subDir : classesSubDirs) {
            if (isDir(subDir, DIRECTORY_REVIEW)) {
              filesInReview = countFiles(subDir);
              
              // allow only a certain number of files in sub directory review
              if (MAXIMUM_FILES_IN_REVIEW < filesInReview) {
                throw new BuildException(String.format("Only up to %d files are allowed in sub directory '%s'.", filesInReview, DIRECTORY_REVIEW));
              }
            }
            
            File suspectedFile = new File(subDir, result.getName());
            if (suspectedFile.exists()) {
              // found file
              return suspectedFile;
            }
          }
          
          // allow only a certain number of files in sub directory review
          if (MAXIMUM_FILES_IN_REVIEW < filesInReview + 1) {
            throw new BuildException(String.format("Only up to %d files are allowed in sub directory '%s'.", filesInReview, DIRECTORY_REVIEW));
          }
          
          // did not find the right sub directory -> assume it is a new file and put it into the "review" folder
          logWrapper.log(String.format("Did not find existing file. Put file %s into sub directory '%s'.", result.getName(), DIRECTORY_REVIEW));
          
          return new File(new File(classesDir, DIRECTORY_REVIEW), result.getName());
        } else {
          // no sub dirs and file does not exist in parent dir => no special handling
        }
      }
      // directory does not exist yet => no special handling
    }
    return result;
  }

  private int countFiles(File subDir)
  {
    File[] files = subDir.listFiles(new FileFilter() {
      
      @Override
      public boolean accept(File pathname)
      {
        return pathname.isFile();
      }
    });
    return null != files ? files.length : 0;
  }

  private boolean isDir(File subDir, String name)
  {
    return name.equals(subDir.getName());
  }

  private File[] getSubDirectories(File classesDir)
  {
    return classesDir.listFiles(new FileFilter() {
      
      @Override
      public boolean accept(File pathname)
      {
        return pathname.isDirectory();
      }
    });
  }

}
