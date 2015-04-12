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
  public Result applyForDeploy(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    return apply(logWrapper);
  }

  private Result apply(LogWrapper logWrapper)
  {
    Result r = new Result();
    
    logWrapper.log("Skip file.");
    
    r.skipped();
    
    return r;
  }

  @Override
  public Result applyForRetrieve(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    return apply(logWrapper);
  }

}
