package task.handler.transformations;

import java.util.Map;

import javax.xml.bind.annotation.XmlRootElement;

import org.w3c.dom.Document;

import task.handler.LogWrapper;

/**
 * SkipFile
 *
 * @author  xlehmf
 */
@XmlRootElement(name="skipfile")
public class SkipFile extends Transformation {
  
  @Override
  public void validate()
  {
    super.validate();
  }

  @Override
  public boolean applyForDeploy(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    return apply(logWrapper);
  }

  private boolean apply(LogWrapper logWrapper)
  {
    logWrapper.log("Skip file.");
    
    return false;
  }

  @Override
  public boolean applyForRetrieve(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    return apply(logWrapper);
  }

}
