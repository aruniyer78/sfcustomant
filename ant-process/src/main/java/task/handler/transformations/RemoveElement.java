package task.handler.transformations;

import java.util.Map;

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
 * RemoveElement
 *
 * @author  xlehmf
 */
@XmlRootElement(name="removeelement")
public class RemoveElement extends Transformation {
  
  private String xpath;
  
  public String getXpath()
  {
    return xpath;
  }

  public void setXpath(String xpath)
  {
    this.xpath = xpath;
  }

  @Override
  public void validate()
  {
    super.validate();
    
    if (StringUtils.isEmpty(xpath)) {
      throw new BuildException("The xpath of the transformation removeelement must be set.");
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
      NodeList nodes = (NodeList)xPath.evaluate(xpath, document.getDocumentElement(), XPathConstants.NODESET);
      for (int i = 0; i < nodes.getLength(); ++i) {
        Node n = nodes.item(i);
        
        if (Node.ELEMENT_NODE != n.getNodeType()) {
          throw new BuildException(String.format("The node type selected by xpath %s is not an element node.", xpath));
        }
        
        logWrapper.log(String.format("Remove element %s.", n.getNodeName()));
        
        n.getParentNode().removeChild(n);
      }
      
      return true;
    }
    catch (XPathExpressionException e) {
      // TODO
      e.printStackTrace();
      
      throw new BuildException(String.format("Error reading transformations.xml: %s.", e.getMessage()), e);
    }
  }

  @Override
  public boolean applyForRetrieve(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    return apply(logWrapper, document);
  }

}
