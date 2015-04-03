/*
 * Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.LogLevel;

import task.handler.configuration.DeploymentConfiguration;
import task.handler.configuration.DeploymentUnit;
import task.model.SfdcExclude;
import task.model.SfdcInclude;
import task.model.SfdcTypeSet;

/**
 * MetadataHandler
 *
 * @author  XLEHMF
 */
public class MetadataHandler
{

  private static final String PACKAGE_XML_FILE_EXTENSION = ".xml";
  
  private LogWrapper logWrapper;
  private String metadataRoot;
  private boolean debug;

  @SuppressWarnings("hiding")
  public void initialize(LogWrapper logWrapper, String metadataRoot, boolean debug)
  {
    this.logWrapper = logWrapper;
    this.metadataRoot = metadataRoot;
    this.debug = debug;
    
    validate();
  }

  private void validate()
  {
    if (null == logWrapper) {
      throw new BuildException("MetadataHandler (logWrapper) not properly initialized.");
    }
    if (null == metadataRoot) {
      throw new BuildException("MetadataHandler (metadataRoot) not properly initialized.");
    }
  }

  public List<DeploymentInfo> compileDeploymentInfos(List<SfdcTypeSet> typeSets, ChecksumHandler checksumHandler)
  {
    List<DeploymentUnit> duList = new DeploymentConfiguration().getConfigurations();

    List<DeploymentInfo> deploymentInfos = new ArrayList<>();
    for (SfdcTypeSet typeSet : typeSets) {
      DeploymentUnit du = findDeploymentUnitBySubDir(duList, typeSet.getName());

      List<File> fileList = compileFileList(du, typeSet, checksumHandler);
      if (fileList.isEmpty()) {
        continue;
      }

      List<String> entityNames = compileEntityNames(du, fileList);

      deploymentInfos.add(new DeploymentInfo(du, fileList, entityNames));
    }

    return deploymentInfos;
  }

  private DeploymentUnit findDeploymentUnitBySubDir(List<DeploymentUnit> duList, String subDir)
  {
    for (DeploymentUnit du : duList) {
      if (subDir.equals(du.getSubDir())) {
        return du;
      }
    }

    throw new BuildException(String.format("Could not find deployment unit for directory %s.", subDir));
  }
  
  private DeploymentUnit findDeploymentUnitByName(List<DeploymentUnit> duList, String objectName, boolean includeChildren)
  {
    for (DeploymentUnit du : duList) {
      if (du.getTypeName().equals(objectName) || (includeChildren && du.isChild(objectName))) {
        return du;
      }
    }

    throw new BuildException(String.format("Could not find deployment unit for object name %s.", objectName));
  }

  private List<File> compileFileList(DeploymentUnit du, SfdcTypeSet typeSet, ChecksumHandler checksumHandler)
  {
    String type = du.getTypeName();

    logWrapper.log(String.format("Collect files to deploy for type %s.", type));

    File baseDir = new File(metadataRoot);

    List<File> fileList = du.getFiles(baseDir);

    // process includes
    List<File> filteredFileList = new ArrayList<>();
    if (typeSet.getIncludes().isEmpty()) {
      filteredFileList.addAll(fileList);
    }
    else {
      for (SfdcInclude include : typeSet.getIncludes()) {
        for (File file : fileList) {
          String fileName = StringUtils.substringBefore(file.getName(), ".");
          if (fileName.matches(include.getName())) {
            filteredFileList.add(file);
          }
        }
      }
    }

    // process excludes
    if (!typeSet.getExcludes().isEmpty()) {
      for (SfdcExclude exclude : typeSet.getExcludes()) {
        Iterator<File> fileItr = filteredFileList.iterator();
        while (fileItr.hasNext()) {
          File file = fileItr.next();
          String fileName = StringUtils.substringBefore(file.getName(), ".");
          if (fileName.matches(exclude.getName())) {
            fileItr.remove();
          }
        }
      }
    }

    // check timestamps
    Set<String> entitiesToUpdate = new HashSet<>();
    for (File file : filteredFileList) {
      if (checksumHandler.isUpdateRequired(du, file)) {
        entitiesToUpdate.add(du.getEntityName(file));
      }
    }
    Iterator<File> fileItr = filteredFileList.iterator();
    while (fileItr.hasNext()) {
      File file = fileItr.next();
      String entityName = du.getEntityName(file);
      if (!entitiesToUpdate.contains(entityName)) {
        fileItr.remove();
      }
    }

    if (filteredFileList.isEmpty()) {
      logWrapper.log(String.format("Nothing to include for %s.", type));
    }

    return filteredFileList;
  }

  private List<String> compileEntityNames(DeploymentUnit du, List<File> fileList)
  {
    // we need the list to keep the order of the files
    Set<String> entitySet = new HashSet<>();
    List<String> entityNames = new ArrayList<>();
    for (File file : fileList) {
      String entityName = du.getEntityName(file);

      if (null == entityName) {
        throw new BuildException(String.format("Error getting entity name for file %s.", file.getName()));
      }

      if (!entitySet.contains(entityName)) {
        entitySet.add(entityName);
        entityNames.add(entityName);
      }
    }

    return entityNames;
  }

  public byte[] createPackageXml(List<DeploymentInfo> deploymentInfos)
  {
    try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
      writeHeader(baos);

      for (DeploymentInfo info : deploymentInfos) {
        DeploymentUnit du = info.getDeploymentUnit();

        String type = du.getTypeName();

        writeEntity(baos, type, info.getEntityNames());
      }
      writeFooter(baos);
      
      return baos.toByteArray();
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error creating package.xml: %s.", e.getMessage()), e);
    }
  }
  
  public byte[] createPackageXml(Map<String, List<String>> metadata)
  {
    try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
      writeHeader(baos);
      
      for (Map.Entry<String, List<String>> entry : metadata.entrySet()) {
        List<String> fullNames = entry.getValue();
        if (!fullNames.isEmpty()) {
          Collections.sort(fullNames);
        
          String type = entry.getKey();
          
          writeEntity(baos, type, fullNames);
        }
      }
      writeFooter(baos);
      
      return baos.toByteArray();
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error creating package.xml: %s.", e.getMessage()), e);
    }
  }
  
  public void savePackageXml(byte[] packageXml)
  {
    if (debug) {
      String fileName = "metadata-" + System.currentTimeMillis() + PACKAGE_XML_FILE_EXTENSION;
      
      logWrapper.log(String.format("Save metadata."));
  
      File tmpDir = new File("tmp");
      tmpDir.mkdirs();
      File metadataXml = new File(tmpDir, fileName);
      
      try (FileOutputStream fos = new FileOutputStream(metadataXml)) {
        fos.write(packageXml);
        fos.close();
      }
      catch (IOException e) {
        logWrapper.log(String.format("Error preparing metadata.xml for retrieval: %s.", e.getMessage()), e, LogLevel.WARN.getLevel());
      }
    }
  }

  private void writeEntity(OutputStream os, String type, List<String> entityNames)
    throws IOException, UnsupportedEncodingException
  {
    os.write("  <types>\n".getBytes("UTF-8"));
    for (String entityName : entityNames) {
      os.write(("    <members>" + entityName + "</members>\n").getBytes("UTF-8"));
    }
    os.write(("    <name>" + type + "</name>\n").getBytes("UTF-8"));
    os.write("  </types>\n".getBytes("UTF-8"));
  }

  private void writeFooter(OutputStream os)
    throws IOException, UnsupportedEncodingException
  {
    os.write("  <version>32.0</version>\n".getBytes("UTF-8"));
    os.write("</Package>\n".getBytes("UTF-8"));
  }

  private void writeHeader(OutputStream os)
    throws IOException, UnsupportedEncodingException
  {
    os.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n".getBytes("UTF-8"));
    os.write("<Package xmlns=\"http://soap.sforce.com/2006/04/metadata\">\n".getBytes("UTF-8"));
  }

  private Set<String> collectObjectsFromTypeSets(List<SfdcTypeSet> typeSets)
  {
    Set<String> objects = new HashSet<>();
    for (SfdcTypeSet typeSet : typeSets) {
      objects.add(typeSet.getName());
    }
    return objects;
  }

  /**
   * @param metadata
   * @param typeSets
   * @param cleanupOther If set to <code>true</code>, all other metadata are cleaned up including other metadata types.
   */
  public void removeNotcontainedMetadata(final Map<String, List<String>> metadata, final List<SfdcTypeSet> typeSets, final boolean cleanupOther)
  {
    // delete everything which was not retrieved
    final Set<String> filesToKeep = new HashSet<>(Arrays.asList("package.xml", ".gitattributes"));
    final List<DeploymentUnit> configurations = new DeploymentConfiguration().getConfigurations();
    final Set<String> objects = collectObjectsFromTypeSets(typeSets);
    
    // TODO remove
//    for (String key : metadata.keySet()) {
//      logWrapper.log(String.format("%s: [%s]", key, StringUtils.join(metadata.get(key), ",")));
//    }
    
    // iterate over base directory and delete everything not in metadata
    File baseDir = new File(metadataRoot);
    File[] dirs = baseDir.listFiles(new FileFilter() {
      
      @Override
      public boolean accept(File pathname)
      {
        if (pathname.isDirectory()) {
          DeploymentUnit du = findDeploymentUnitBySubDir(configurations, pathname.getName());
          if (null == du) {
            // no deployment unit found for directory -> delete
            deleteDirectory(pathname);
            
            return false;
          } else if (!typeOrChildrenInObjects(metadata.keySet(), du)) {
            // deployment unit was not part of the current retrieval job
            if (cleanupOther || typeOrChildrenInObjects(objects, du)) {
              // either cleanup all other directories or the directory was part of the current retrieval job
              deleteDirectory(pathname);
              
              return false;
            }
          }
          // cleanup directory if it was part of the current retrieval job
          return typeOrChildrenInObjects(objects, du);
        } else if (pathname.isFile()) {
          if (!filesToKeep.contains(pathname.getName())) {
            logWrapper.log(String.format("Delete file: %s.", pathname.getName()));
            
            pathname.delete();
          }
          return false;
        }
        return true;
      }
    });
    
    // TODO remove
//    for (String key : metadata.keySet()) {
//      logWrapper.log(String.format("%s: [%s]", key, StringUtils.join(metadata.get(key), ",")));
//    }
    
    for (File dir : dirs) {
      DeploymentUnit du = findDeploymentUnitBySubDir(configurations, dir.getName());
      
      // TODO remove
//      logWrapper.log(String.format("%s - %s", du.getSubDir(), du.getTypeName()));
      
      Set<String> metaEntities = getEntitiesFromMetadata(metadata, du);
      
//      logWrapper.log(String.format("metas: %s", StringUtils.substring(StringUtils.join(metaEntities, ","), 0,  50)));
      
      List<File> files = du.getFiles(baseDir);
      for (File file : files) {
        String name = du.getEntityName(file);
        if (!metaEntities.contains(name)) {
          logWrapper.log(String.format("Delete file: %s (entity %s).", file.getName(), name));
          
          file.delete();
        }
      }
    }
  }

  private void deleteDirectory(File pathname)
  {
    try {
      logWrapper.log(String.format("Delete directory: %s.", pathname.getName()));
      
      FileUtils.deleteDirectory(pathname);
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error deleting directory: %s.", e.getMessage()), e);
    }
  }
  
  private Set<String> getEntitiesFromMetadata(final Map<String, List<String>> metadata, DeploymentUnit du)
  {
    Set<String> metas = new HashSet<>();
    
    List<String> any = new ArrayList<>(du.getChildNames());
    any.add(du.getTypeName());
    
    for (String name : any) {
      if (metadata.keySet().contains(name)) {
        metas.addAll(metadata.get(name));
      }
    }
    
    Set<String> entities = new HashSet<>();
    for (String meta : metas) {
      entities.add(du.getEntityName(meta));
    }
    
    return entities;
  }

  private boolean typeOrChildrenInObjects(Set<String> objects, DeploymentUnit du)
  {
    List<String> any = new ArrayList<>(du.getChildNames());
    any.add(du.getTypeName());
    
    for (String name : any) {
      if (objects.contains(name)) {
        return true;
      }
    }
    return false;
  }

  public void validateTypeSetsByName(List<SfdcTypeSet> typeSets)
  {
    List<DeploymentUnit> configurations = new DeploymentConfiguration().getConfigurations();
    
    for (SfdcTypeSet typeSet : typeSets) {
      findDeploymentUnitByName(configurations, typeSet.getName(), true);
    }
  }
  
}
