package task.model;

import org.apache.tools.ant.taskdefs.Typedef;


/**
 * SfdcInclude
 *
 * @author  xlehmf
 */
public class SfdcInclude extends Typedef {
  
  private String name;

  @Override
  public void setName(String name)
  {
    this.name = name;
  }

  @Override
  public String getName()
  {
    return name;
  }
  
}
