package task.model;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Typedef;


/**
 * SfdcTypeSet
 *
 * @author  xlehmf
 */
public class SfdcTypeSet extends Typedef {
  
  private String name;
  private boolean force;
  private boolean suppressChecksumUpdate;
  private List<SfdcInclude> includes;
  private List<SfdcExclude> excludes;

  public SfdcTypeSet()
  {
    includes = new ArrayList<>();
    excludes = new ArrayList<>();
  }
  
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
  
  public boolean isForce()
  {
    return force;
  }

  public void setForce(boolean force)
  {
    this.force = force;
  }

  public boolean isSuppressChecksumUpdate()
  {
    return suppressChecksumUpdate;
  }

  public void setSuppressChecksumUpdate(boolean suppressChecksumUpdate)
  {
    this.suppressChecksumUpdate = suppressChecksumUpdate;
  }

  public List<SfdcInclude> getIncludes()
  {
    return includes;
  }

  public List<SfdcExclude> getExcludes()
  {
    return excludes;
  }

  public void addConfigured(SfdcInclude include)
  {
    includes.add(include);
  }
  
  public void addConfigured(SfdcExclude exclude)
  {
    excludes.add(exclude);
  }

  public void validateSettings()
  {
    if (StringUtils.isEmpty(name)) {
      throw new BuildException(String.format("The name of the typeset must be set."));
    }
  }
  
}
