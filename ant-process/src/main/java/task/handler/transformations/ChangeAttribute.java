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
 * ChangeAttribute
 *
 * @author  xlehmf
 */
@XmlRootElement(name = "changeattribute")
public class ChangeAttribute
  extends Transformation
{

  private String xpath;
  private Token token;
  private String value;

  public String getXpath()
  {
    return xpath;
  }

  public void setXpath(String xpath)
  {
    this.xpath = xpath;
  }

  public Token getToken()
  {
    return token;
  }

  public void setToken(Token token)
  {
    this.token = token;
  }

  public String getValue()
  {
    return value;
  }

  public void setValue(String value)
  {
    this.value = value;
  }

  @Override
  public void validate()
  {
    super.validate();

    if (StringUtils.isEmpty(xpath)) {
      throw new BuildException("The xpath of the transformation changeattribute must be set.");
    }
    if ((null == token) && StringUtils.isEmpty(value)) {
      throw new BuildException("The token or the value of the transformation changeattribute must be set.");
    }
    if ((null != token) && StringUtils.isNotEmpty(value)) {
      throw new BuildException("Only token or the value of the transformation changeattribute can be set, but not both at the same time.");
    }
    if (StringUtils.isNotEmpty(value) && isDeploy() && isRetrieve()) {
      throw new BuildException("The transformation changeattribute cannot be used with a value for deploy and retrieve at the same time. Set one of the operations to false.");
    }
    if (null != token) {
      token.validate();
    }
  }

  @Override
  public Result applyForDeploy(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    Result r = new Result();
    
    XPath xPath = XPathFactory.newInstance().newXPath();

    // value or token?
    String replacement = null;
    if (null != token) {
      if (!tokenMappings.containsKey(token.getText())) {
        throw new BuildException(String.format("Could not find token mapping for token %s.", token.getText()));
      }
      replacement = tokenMappings.get(token.getText());
    }
    else {
      replacement = value;
    }

    try {
      NodeList nodes = (NodeList)xPath.evaluate(xpath, document.getDocumentElement(), XPathConstants.NODESET);
      for (int i = 0; i < nodes.getLength(); ++i) {
        Node n = nodes.item(i);

        if (Node.ATTRIBUTE_NODE != n.getNodeType()) {
          throw new BuildException(String.format("The node type selected by xpath %s is not an attribute node.", xpath));
        }

        String txt = n.getTextContent();

        String newValue = null;
        if (null != token && token.isTokenOnly()) {
          newValue = txt.replaceAll(token.getText(), replacement);

          logWrapper.log(String.format("Replace token %s with %s.", token.getText(), replacement));
        }
        else {
          // regular token or value
          newValue = replacement;

          logWrapper.log(String.format("Change attribute from %s to %s.", txt, newValue));
        }

        n.setNodeValue(newValue);

        r.applied();
      }
      return r;
    }
    catch (XPathExpressionException e) {
      throw new BuildException(String.format("Error applying transformation changeattribute: %s.", e.getMessage()), e);
    }
  }

  @Override
  public Result applyForRetrieve(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    Result r = new Result();
    
    XPath xPath = XPathFactory.newInstance().newXPath();

    // value or token?
    String replacement = null;
    if (null != token) {
      replacement = token.getText();
    }
    else {
      replacement = value;
    }

    try {
      
      logWrapper.log(String.format("xpath %s", xpath));
      
      NodeList nodes = (NodeList)xPath.evaluate(xpath, document.getDocumentElement(), XPathConstants.NODESET);
      
logWrapper.log(String.format("Found %d matches", nodes.getLength()));
      
      for (int i = 0; i < nodes.getLength(); ++i) {
        Node n = nodes.item(i);

        if (Node.ATTRIBUTE_NODE != n.getNodeType()) {
          throw new BuildException(String.format("The node type selected by xpath %s is not a attribute node.", xpath));
        }

        String txt = n.getTextContent();

        String newValue = null;
        if (null != token && token.isTokenOnly()) {
          if (!tokenMappings.containsKey(token.getText())) {
            throw new BuildException(String.format("Could not find token mapping for token %s.", token.getText()));
          }
          String valueToReplace = tokenMappings.get(token.getText());

          newValue = txt.replaceAll(valueToReplace, replacement);

          logWrapper.log(String.format("Replace %s with token %s.", valueToReplace, replacement));
        }
        else {
          newValue = replacement;

          logWrapper.log(String.format("Change attribute from %s to %s.", txt, newValue));
        }

        n.setNodeValue(newValue);
        
        r.applied();
      }
      return r;
    }
    catch (XPathExpressionException e) {
      throw new BuildException(String.format("Error applying transformation changeattribute: %s.", e.getMessage()), e);
    }
  }

}
