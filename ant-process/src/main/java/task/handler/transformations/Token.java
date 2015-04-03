package task.handler.transformations;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlValue;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;

/**
 * Token
 *
 * @author  xlehmf
 */
@XmlRootElement(name="token")
public class Token {
  
  private String text;
  
  private boolean tokenOnly;

  public String getText()
  {
    return text;
  }

  @XmlValue
  public void setText(String text)
  {
    this.text = text;
  }

  public boolean isTokenOnly()
  {
    return tokenOnly;
  }

  @XmlAttribute(name="tokenonly")
  public void setTokenOnly(boolean tokenOnly)
  {
    this.tokenOnly = tokenOnly;
  }

  public void validate()
  {
    if (StringUtils.isEmpty(text)) {
      throw new BuildException("The token text of the transformation changetext must be set.");
    }
  }
  
  
}
