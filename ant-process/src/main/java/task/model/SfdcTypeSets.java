package task.model;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Typedef;


/**
 * SfdcTypeSets
 *
 * @author  xlehmf
 */
public class SfdcTypeSets extends Typedef {
  
  private String names;

  public void setNames(String names)
  {
    this.names = names;
  }

  public String getNames()
  {
    return names;
  }
  
  public void validateSettings()
  {
    if (StringUtils.isEmpty(names)) {
      throw new BuildException(String.format("The names of the typeset must be set."));
    }
  }
}