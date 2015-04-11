package task.handler.transformations;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
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
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import task.handler.LogWrapper;

/**
 * RemoveDuplicateElement
 *
 * @author  xlehmf
 */
@XmlRootElement(name="removeduplicateelement")
public class RemoveDuplicateElement extends Transformation {
  
  private String xpath;
  private int distance;
  
  public String getXpath()
  {
    return xpath;
  }

  public void setXpath(String xpath)
  {
    this.xpath = xpath;
  }

  public int getDistance()
  {
    return distance;
  }

  public void setDistance(int distance)
  {
    this.distance = distance;
  }

  @Override
  public void validate()
  {
    super.validate();
    
    if (StringUtils.isEmpty(xpath)) {
      throw new BuildException("The xpath of the transformation removeduplicateelement must be set.");
    }
    if (1 > distance) {
      throw new BuildException("The distance of the transformation removeduplicateelement must be larger than 0.");
    }
  }

  @Override
  public boolean applyForDeploy(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    return apply(logWrapper, document);
  }

  private boolean apply(LogWrapper logWrapper, Document document)
  {
    XPath xPath = XPathFactory.newInstance().newXPath();
    
    try {
      List<Node> nodesToDelete = new ArrayList<>();
      Set<String> nodeNames = new HashSet<>();
      
      NodeList nodes = (NodeList)xPath.evaluate(xpath, document.getDocumentElement(), XPathConstants.NODESET);
      for (int i = 0; i < nodes.getLength(); ++i) {
        Node n = nodes.item(i);
        
        if (Node.TEXT_NODE != n.getNodeType()) {
          throw new BuildException(String.format("The node type selected by xpath %s is not a text node.", xpath));
        }
        
        String name = n.getTextContent();
        
        if (nodeNames.contains(name)) {
          for (int j=0; j < distance; j++) {
            n = n.getParentNode();
          }
          if (Node.ELEMENT_NODE != n.getNodeType()) {
            throw new BuildException(String.format("The node type selected by xpath %s and the distance %d is not an element node.", xpath, distance));
          }
          nodesToDelete.add(n);
        } else {
          nodeNames.add(name);
        }
      }
      
      for (Node n : nodesToDelete) {
        logWrapper.log(String.format("Remove duplicate element %s.", n.getNodeName()));
        
        n.getParentNode().removeChild(n);
      }
      
      return true;
    }
    catch (XPathExpressionException e) {
      throw new BuildException(String.format("Error reading transformations.xml: %s.", e.getMessage()), e);
    }
  }

  @Override
  public boolean applyForRetrieve(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    return apply(logWrapper, document);
  }

}
