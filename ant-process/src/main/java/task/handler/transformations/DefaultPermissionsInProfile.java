package task.handler.transformations;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import task.handler.LogWrapper;

/**
 * DefaultPermissionsInProfile - default permissions in profiles if not specified.
 *
 * @author  xlehmf
 */
@XmlRootElement(name="defaultpermissions")
public class DefaultPermissionsInProfile extends Transformation {
  
  private String permissions;
  private Set<String> names;
  
  public String getPermissions()
  {
    return permissions;
  }

  public void setPermissions(String permissions)
  {
    this.permissions = permissions;
  }

  @Override
  public void validate()
  {
    // do not call validate from parent class!
    
    if (StringUtils.isEmpty(permissions)) {
      throw new BuildException("The permissions of the transformation defaultpermissions must be set.");
    }
    
    names = new HashSet<>();
    for (String name : StringUtils.split(permissions, ",")) {
      names.add(name.trim());
    }
    
    if (0 == names.size()) {
      throw new BuildException("The permissions of the transformation defaultpermissions must have at least one value.");
    }
  }

  @Override
  public String getFilename()
  {
    return "profiles/*.profile";
  }

  @Override
  public boolean isDeploy()
  {
    return true;
  }

  @Override
  public boolean isRetrieve()
  {
    return false;
  }

  @Override
  public Result applyForDeploy(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    Result r = new Result();
    
    XPath xPath = XPathFactory.newInstance().newXPath();

    try {
      Set<String> permissionNames = new HashSet<>(names);
      
      NodeList nodes = (NodeList)xPath.evaluate("/Profile/userPermissions/name/text()", document.getDocumentElement(), XPathConstants.NODESET);
      for (int i = 0; i < nodes.getLength(); ++i) {
        Node n = nodes.item(i);

        if (!permissionNames.remove(n.getTextContent())) {
          logWrapper.log(String.format("Unknown user permission %s. Please add to list of user permissions to default.", n.getTextContent()), 1);
        }
      }
      
      if (!permissionNames.isEmpty()) {
        // add missing user permissions
        NodeList lastNodes = (NodeList)xPath.evaluate("/Profile", document.getDocumentElement(), XPathConstants.NODESET);
        if (1 != lastNodes.getLength()) {
          throw new BuildException("Did not find the profile element in metadata.");
        }
        
        Element profile = (Element)lastNodes.item(0);
        for (String permissionName : permissionNames) {
          Element userPermission = document.createElement("userPermissions");
          
          Element enabled = document.createElement("enabled");
          enabled.setTextContent("false");
          
          Element name = document.createElement("name");
          name.setTextContent(permissionName);
          
          userPermission.appendChild(enabled);
          userPermission.appendChild(name);
          
          profile.appendChild(userPermission);
          
          r.applied();
        }
      }
    }
    catch (XPathExpressionException e) {
      throw new BuildException(String.format("Error reading transformations.xml: %s.", e.getMessage()), e);
    }
    
    return r;
  }

  @Override
  public Result applyForRetrieve(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    return new Result();
  }

}
