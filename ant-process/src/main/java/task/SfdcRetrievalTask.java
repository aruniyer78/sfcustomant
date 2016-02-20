package task;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Taskdef;
import org.apache.tools.ant.types.LogLevel;

import task.handler.ChecksumHandler;
import task.handler.LogWrapper;
import task.handler.MetadataHandler;
import task.handler.SfdcHandler;
import task.handler.TransformationHandler;
import task.handler.ZipFileHandler;
import task.model.SfdcFeature;
import task.model.SfdcTypeSet;
import task.model.SfdcTypeSets;

/**
 * SfdcRetrievalTask
 *
 * @author  xlehmf
 */
public class SfdcRetrievalTask
  extends Taskdef
{

  private String username;
  private String password;
  private String serverurl;
  private int maxPoll;
  private boolean useProxy;
  private String proxyHost;
  private int proxyPort;
  private String retrieveRoot;
  private boolean debug;
  private boolean dryRun;
  private List<SfdcTypeSet> typeSets;
  private boolean cleanupOther;
  private String transformationsRoot;
  private Map<String, SfdcFeature> features;

  private SfdcHandler sfdcHandler;
  private MetadataHandler metadataHandler;
  private ZipFileHandler zipFileHandler;
  private TransformationHandler transformationHandler;
  private ChecksumHandler checksumHandler;

  public void setUsername(String username)
  {
    this.username = username;
  }

  public void setPassword(String password)
  {
    this.password = password;
  }

  public void setServerurl(String serverurl)
  {
    this.serverurl = serverurl;
  }

  public void setMaxPoll(int maxPoll)
  {
    this.maxPoll = maxPoll;
  }

  public void setUseProxy(boolean useProxy)
  {
    this.useProxy = useProxy;
  }

  public void setProxyHost(String proxyHost)
  {
    this.proxyHost = proxyHost;
  }

  public void setProxyPort(int proxyPort)
  {
    this.proxyPort = proxyPort;
  }

  public void setRetrieveRoot(String retrieveRoot)
  {
    this.retrieveRoot = retrieveRoot;
  }

  public void setDebug(boolean debug)
  {
    this.debug = debug;
  }

  public void setDryRun(boolean dryRun)
  {
    this.dryRun = dryRun;
  }

  public void setCleanupOther(boolean cleanupOther)
  {
    this.cleanupOther = cleanupOther;
  }

  public void setTransformationsRoot(String transformationsRoot)
  {
    this.transformationsRoot = transformationsRoot;
  }
  
  public void addConfigured(SfdcTypeSets typeSetNames)
  {
    typeSetNames.validateSettings();

    String names = typeSetNames.getNames();
    String[] tokens = names.split(",");
    for (String token : tokens) {
      String trimmed = StringUtils.trimToEmpty(token);
      if (StringUtils.isNotEmpty(trimmed)) {
        SfdcTypeSet typeSet = new SfdcTypeSet();
        typeSet.setName(trimmed);

        typeSets.add(typeSet);
      }
    }
  }

  public void addConfigured(SfdcFeature feature)
  {
    feature.validateSettings();

    features.put(feature.getFeature().name(), feature);
  }

  @Override
  public void init()
  {
    super.init();

    typeSets = new ArrayList<>();
    features = new HashMap<>();
    
    sfdcHandler = new SfdcHandler();
    metadataHandler = new MetadataHandler();
    zipFileHandler = new ZipFileHandler();
    transformationHandler = new TransformationHandler();
    checksumHandler = new ChecksumHandler();

    cleanupOther = true;
  }

  @Override
  public void execute()
  {
    validate();
    initialize();

    Map<String, Map<String, Long>> metadataUpdatestamps = sfdcHandler.getUpdateStamps(typeSets);

    Map<String, List<String>> metadata = sfdcHandler.buildEntityList(metadataUpdatestamps);
    
    byte[] packageXml = metadataHandler.createPackageXml(metadata, true);
    metadataHandler.savePackageXml(MetadataHandler.PREFFIX_METADATA, packageXml);

    ByteArrayOutputStream zipFile = sfdcHandler.retrieveMetadata(metadata);
    zipFileHandler.saveZipFile("retrieve", null, zipFile);
    zipFileHandler.extractZipFile(retrieveRoot, zipFile, transformationHandler, checksumHandler);

    metadataHandler.removeNotContainedMetadata(metadata, typeSets, cleanupOther, transformationHandler);
  }

  private void initialize()
  {
    LogWrapper logWrapper = new LogWrapper(this);

    checksumHandler.initialize(logWrapper, "DUMMY", false, dryRun);
    transformationHandler.initialize(logWrapper, username, transformationsRoot, TransformationHandler.DEFAULT_TRANSFORMATIONS_FILE_NAME, retrieveRoot);

    metadataHandler.initialize(logWrapper, retrieveRoot, debug);
    zipFileHandler.initialize(logWrapper, debug, metadataHandler);
    
    sfdcHandler.initialize(this,
                           maxPoll,
                           dryRun,
                           false,
                           serverurl,
                           username,
                           password,
                           useProxy,
                           proxyHost,
                           proxyPort,
                           features);
  }

  private void validate()
  {
    if (null == retrieveRoot) {
      throw new BuildException("The property retrieveRoot must be specified.");
    }

    Set<String> typeNames = new HashSet<>();
    for (SfdcTypeSet typeSet : typeSets) {
      typeNames.add(typeSet.getName());
    }
    String[] relatedTypes =
        new String[]{
            "CustomApplication",
            "ApexClass",
            "CustomPermission",
            "ExternalDataSource",
            "CustomObject",
            "ApexPage",
            "CustomTab" };
    if (typeNames.contains("PermissionSet")) {
      for (String relatedType : relatedTypes) {
        checkSfdcTypeSet(typeNames, "PermissionSet", relatedType);
      }
    }
    if (typeNames.contains("Profile")) {
      for (String relatedType : relatedTypes) {
        checkSfdcTypeSet(typeNames, "Profile", relatedType);
      }
    }

    metadataHandler.validateTypeSetsByName(typeSets);
  }

  private void checkSfdcTypeSet(Set<String> typeNames, String parentType, String relatedType)
  {
    if (!typeNames.contains(relatedType)) {
      log(String.format("Adding %s for type set %s.", relatedType, parentType), LogLevel.WARN.getLevel());
      SfdcTypeSet sts = new SfdcTypeSet();
      sts.setName(relatedType);
      typeSets.add(sts);

      typeNames.add(relatedType);
    }
  }

}
