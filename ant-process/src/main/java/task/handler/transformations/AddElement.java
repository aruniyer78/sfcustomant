package task.handler.transformations;

import java.util.Map;

import javax.xml.bind.annotation.XmlAnyElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import task.handler.LogWrapper;

/**
 * AddElement
 *
 * @author  xlehmf
 */
@XmlRootElement(name = "addelement")
public class AddElement
  extends Transformation
{

  private String xpath;
  private Element element;

  public String getXpath()
  {
    return xpath;
  }

  public void setXpath(String xpath)
  {
    this.xpath = xpath;
  }

  @XmlAnyElement
  public Element getElement()
  {
    return element;
  }

  public void setElement(Element element)
  {
    this.element = element;
  }

  @Override
  public void validate()
  {
    super.validate();

    if (StringUtils.isEmpty(xpath)) {
      throw new BuildException("The xpath of the transformation addelement must be set.");
    }
    if (null == element || 0 == element.getChildNodes().getLength()) {
      throw new BuildException("The element of the transformation addelement must be set.");
    }
  }

  @Override
  public boolean applyForDeploy(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    return apply(logWrapper, document);
  }

  @Override
  public boolean applyForRetrieve(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
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

        logWrapper.log(String.format("Add element after %s.", n.getNodeName()));

        NodeList childs = element.getChildNodes();
        for (int j = childs.getLength(); 0 < j; j--) {
          Node copiedNode = copyNode(document, childs.item(j - 1));
          n.getParentNode().insertBefore(copiedNode, n.getNextSibling());
        }
      }
      return true;
    }
    catch (XPathExpressionException e) {
      throw new BuildException(String.format("Error reading transformations.xml: %s.", e.getMessage()), e);
    }
  }

  private Node copyNode(Document document, Node nodeToCopy)
  {
    Node result = null;
    
    switch (nodeToCopy.getNodeType()) {
      case Node.ELEMENT_NODE:
        Element elem = document.createElement(nodeToCopy.getLocalName());
        NamedNodeMap attributes = nodeToCopy.getAttributes();
        for (int i=0; i < attributes.getLength(); i++) {
          Node attr = attributes.item(i);
          elem.setAttribute(attr.getLocalName(), attr.getNodeValue());
        }
        NodeList childNodes = nodeToCopy.getChildNodes();
        for (int i=0; i < childNodes.getLength(); i++) {
          elem.appendChild(copyNode(document, childNodes.item(i)));
        }
        result = elem;
        break;
      case Node.TEXT_NODE:
        result = document.createTextNode(nodeToCopy.getTextContent());
        break;
      default:
        throw new BuildException(String.format("Node type %d not supported.", nodeToCopy.getNodeType()));
    }
    return result;
  }

}
