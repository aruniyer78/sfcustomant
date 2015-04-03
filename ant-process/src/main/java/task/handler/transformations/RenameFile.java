package task.handler.transformations;

import java.util.Map;

import javax.xml.bind.annotation.XmlRootElement;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.w3c.dom.Document;

import task.handler.LogWrapper;

/**
 * RenameFile
 *
 * @author  xlehmf
 */
@XmlRootElement(name="renamefile")
public class RenameFile extends Transformation {
  
  private String renameto;
  
  public String getRenameto()
  {
    return renameto;
  }

  public void setRenameto(String renameto)
  {
    this.renameto = renameto;
  }

  @Override
  public void validate()
  {
    super.validate();
    
    if (StringUtils.isEmpty(renameto)) {
      throw new BuildException("The renameto of the transformation renamefile must be set.");
    }
  }

  @Override
  public boolean applyForDeploy(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    throw new BuildException(String.format("Transformation %s not supported yet.", getClass().getSimpleName()));    
  }

  @Override
  public boolean applyForRetrieve(LogWrapper logWrapper, Document document, Map<String, String> tokenMappings)
  {
    throw new BuildException("Not implemted yet.");
  }

}
