/*
 * Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import task.handler.transformations.ChangeAttribute;
import task.handler.transformations.ChangeText;
import task.handler.transformations.Transformation;
import task.handler.transformations.Transformation.Result;
import task.handler.transformations.Transformations;

/**
 * TransformationHandler
 *
 * @author  XLEHMF
 */
public class TransformationHandler
{

  public static interface TransformationFilter
  {
    boolean check(Transformation t);
  }

  public enum Operation { DEPLOY, RETRIEVE }
  
  private LogWrapper logWrapper;
  private String userName;
  private String transformationsRoot;
  private String deployRoot;
  // private boolean debug;

  private List<Transformation> transformations;
  private Map<String, String> tokenMappings;

  @SuppressWarnings("hiding")
  public void initialize(LogWrapper logWrapper, String userName, String transformationsRoot, String deployRoot)
  {
    this.logWrapper = logWrapper;
    this.userName = userName;
    this.transformationsRoot = transformationsRoot;
    this.deployRoot = deployRoot;
    //    this.debug = debug;

    validate();
    initialize();
  }

  private void initialize()
  {
    String environment = getEnvironmentMapping();
    tokenMappings = readEnvironmentConfiguration(environment);

    // global
    transformations = readTransformations(null);
    // add environment-specific transformations
    transformations.addAll(readTransformations(environment));

    checkTransformationConfiguration();
  }

  private void checkTransformationConfiguration()
  {
    Set<String> tokens = new HashSet<>();
    for (Transformation transformation : transformations) {
      transformation.validate();

      if (transformation instanceof ChangeText) {
        ChangeText changeText = (ChangeText)transformation;
        if (null != changeText.getToken()) {
          tokens.add(changeText.getToken().getText());
        }
      }
      else if (transformation instanceof ChangeAttribute) {
        ChangeAttribute changeAttribute = (ChangeAttribute)transformation;
        tokens.add(changeAttribute.getToken().getText());
      }
    }

    if (tokenMappings.size() != tokens.size()) {
      throw new BuildException(String.format("The number of tokens %d does not equal the number of token transformations %d.",
                                             tokenMappings.size(),
                                             tokens.size()));
    }
  }

  private Map<String, String> readEnvironmentConfiguration(String environment)
  {
    File envDir = new File(transformationsRoot, environment);
    File tokenFile = new File(envDir, "token.properties");

    try (FileInputStream fis = new FileInputStream(tokenFile);
        InputStreamReader isr = new InputStreamReader(fis, "UTF-8")) {
      Properties properties = new Properties();
      properties.load(isr);

      Map<String, String> result = new HashMap<>();
      for (String key : properties.stringPropertyNames()) {
        String value = properties.getProperty(key);

        result.put(key, value);
      }

      return result;
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error reading file token.properties for environmet %s: %s.",
                                             environment,
                                             e.getMessage()), e);
    }
  }

  private String getEnvironmentMapping()
  {
    File file = new File(transformationsRoot, "environment.mappings");

    try (FileInputStream fis = new FileInputStream(file); InputStreamReader isr = new InputStreamReader(fis, "UTF-8")) {
      Properties properties = new Properties();
      properties.load(isr);

      String result = null;
      for (String key : properties.stringPropertyNames()) {
        String value = properties.getProperty(key);
        String[] tokens = StringUtils.split(value, ",");
        if (ArrayUtils.contains(tokens, userName)) {
          result = key;
          break;
        }
      }

      if (null == result) {
        throw new BuildException(String.format("Environment for user %s not found. Please check file environment.mappings.",
                                               userName));
      }

      return result;
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error reading environment mappings: %s.", e.getMessage()), e);
    }
  }

  private List<Transformation> readTransformations(String environment)
  {
    List<Transformation> result = new ArrayList<>();

    File basePath =
        StringUtils.isNotEmpty(environment)
                                           ? new File(transformationsRoot, environment)
                                           : new File(transformationsRoot);

    File transConfigFile = new File(basePath, "transformations.xml");
    if (!transConfigFile.exists()) {
      return result;
    }

    try (FileReader fileReader = new FileReader(transConfigFile)) {
      JAXBContext context = JAXBContext.newInstance(Transformations.class);
      Unmarshaller um = context.createUnmarshaller();
      Transformations ts = (Transformations)um.unmarshal(fileReader);

      if (null != ts && null != ts.getTransformations()) {
        for (Transformation t : ts.getTransformations()) {
          normalizeFile(t);
          result.add(t);
        }
      }

      return result;
    }
    catch (JAXBException | IOException e) {
      throw new BuildException(String.format("Error reading transformations.xml in %s: %s.",
                                             basePath.getName(),
                                             e.getMessage()), e);
    }
  }

  private void normalizeFile(Transformation transformation)
  {
    transformation.setFilename(transformation.getFilename().replaceAll("\\\\", "/"));
  }

  private void validate()
  {
    if (null == logWrapper) {
      throw new BuildException("TransformationHandler (logWrapper) not properly initialized.");
    }
    if (null == transformationsRoot) {
      throw new BuildException("TransformationHandler (transformationsRoot) not properly initialized.");
    }
    if (null == deployRoot) {
      throw new BuildException("TransformationHandler (deployRoot) not properly initialized.");
    }
    if (null == userName) {
      throw new BuildException("TransformationHandler (userName) not properly initialized.");
    }
  }

  public boolean evaluateFilter(File file, TransformationFilter filter) {
    List<Transformation> fileTransformations = getTransformationsForFile(file);
    for (Transformation t : fileTransformations) {
      if (filter.check(t)) {
        return true;
      }
    }
    return false;
  }
  
  public ByteArrayOutputStream transform(InputStream is, File file, Operation operation)
  {
    List<Transformation> fileTransformations = getTransformationsForFile(file);
    if (fileTransformations.isEmpty()) {
      return copyFile(is, file.getName());
    }
    else {
      return applyTransformations(file.getName(), is, fileTransformations, operation);
    }
  }

  private ByteArrayOutputStream applyTransformations(String fileName,
                                                     InputStream is,
                                                     List<Transformation> fileTransformations,
                                                     Operation operation)
  {
    try {
      DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
      //      TODO dbf.setNamespaceAware(true);
      DocumentBuilder b = dbf.newDocumentBuilder();

      Document doc = b.parse(is);

      boolean applied = true;
      for (Transformation transformation : fileTransformations) {
        Result r = null;
        if (Operation.DEPLOY.equals(operation) && transformation.isDeploy()) {
          r = transformation.applyForDeploy(logWrapper, doc, tokenMappings);
          
        }
        else if (Operation.RETRIEVE.equals(operation) && transformation.isRetrieve()) {
          r = transformation.applyForRetrieve(logWrapper, doc, tokenMappings);
        }
        if (null != r && r.isSkipped()) {
          return null;
        }
        if (null != r && r.isApplied()) {
          applied = true;
        }
      }

      if (applied) {
        Transformer transformer = TransformerFactory.newInstance().newTransformer();
        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
        transformer.setOutputProperty(OutputKeys.METHOD, "xml");
        transformer.setOutputProperty(OutputKeys.VERSION, "1.0");
        transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
        transformer.setOutputProperty(OutputKeys.STANDALONE, "yes");
        transformer.setOutputProperty("{http://xml.apache.org/xalan}indent-amount", "4");
  
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        StreamResult result = new StreamResult(baos);
        DOMSource source = new DOMSource(doc);
  
        transformer.transform(source, result);
  
        return baos;
      }
      return copyFile(is, fileName);
    }
    catch (ParserConfigurationException | SAXException | IOException | TransformerException e) {
      throw new BuildException(String.format("Error reading file %s: %s.", fileName, e.getMessage()), e);
    }
  }

  private List<Transformation> getTransformationsForFile(File file)
  {
    String fileName = file.getAbsolutePath().replaceAll("\\\\", "/");

    List<Transformation> result = new ArrayList<>();
    for (Transformation transformation : transformations) {
      String fileNamePattern = transformToPattern(transformation.getFilename());
      if (fileName.matches(fileNamePattern)) {
        result.add(transformation);
      }
    }

    if (!result.isEmpty()) {
      logWrapper.log(String.format("Found %d transformations for %s.", result.size(), file.getName()));
    }

    // TODO validate only one rename file for each file
    // TODO validate only one skip file for each file

    return result;
  }

  private String transformToPattern(String fileName)
  {
    StringBuffer sb = new StringBuffer();

    // . -> \\., * -> .*, ? -> .
    for (char c : fileName.toCharArray()) {
      switch (c) {
        case '*' :
          sb.append(".*");
          break;
        case '?' :
          sb.append(".");
          break;
        case '.' :
          sb.append("\\.");
          break;
        default :
          sb.append(c);
      }
    }

    if (!sb.toString().startsWith(".*")) {
      sb.insert(0, ".*");
    }

    return sb.toString();
  }

  private ByteArrayOutputStream copyFile(InputStream is, String fileName)
  {
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    
    byte[] buffer = new byte[2048];

    try {
      int read = 0;
      do {
        read = is.read(buffer);
        if (0 < read) {
          baos.write(buffer, 0, read);
        }
      }
      while (-1 != read);
    } catch (IOException e) {
      throw new BuildException(String.format("Error copying file %s: %s.", fileName, e.getMessage()), e);
    }
    
    return baos;
  }

}
