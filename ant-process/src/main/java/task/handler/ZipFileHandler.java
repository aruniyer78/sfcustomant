/*
 * Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

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

  private static final String ZIP_BASE_DIR = "unpackaged";
  private static final String FILE_NAME_PACKAGE_XML = ZIP_BASE_DIR + "/package.xml";
  
  private LogWrapper logWrapper;
  private boolean debug;
  private TransformationHandler transformationHandler;
  private MetadataHandler metadataHandler;

  @SuppressWarnings("hiding")
  public void initialize(LogWrapper logWrapper, boolean debug, TransformationHandler transformationHandler, MetadataHandler metadataHandler)
  {
    this.logWrapper = logWrapper;
    this.debug = debug;
    this.transformationHandler = transformationHandler;
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
    if (null == transformationHandler) {
      throw new BuildException("ZipFileHandler (transformationHandler) is not initialized.");
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

  public ByteArrayOutputStream prepareZipFile(List<DeploymentInfo> deploymentInfos)
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
      metadataHandler.savePackageXml(packageXml);
      
      zos.putNextEntry(new ZipEntry(FILE_NAME_PACKAGE_XML));
      zos.write(packageXml);
      zos.closeEntry();
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error preparing ZIP for deployment: %s.", e.getMessage()), e);
    }

    return (counter != 0) ? baos : null;
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

  public void extractZipFile(String retrieveRoot, ByteArrayOutputStream zipFile)
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
          
          File file = new File(retrieveRoot, fileName);
          
          InputStreamWrapper isw = new InputStreamWrapper(zis);

          ByteArrayOutputStream fileBaos = transformationHandler.transform(isw, file, Operation.RETRIEVE);
          if (null != fileBaos) {
            File parentFile = file.getParentFile();
            if (!parentFile.exists() && !parentFile.mkdirs()) {
              throw new BuildException(String.format("Error creating directories while extracting file: %s.", fileName));
            }
            
            try (FileOutputStream fos = new FileOutputStream(file)) {
              fos.write(fileBaos.toByteArray());
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

}
