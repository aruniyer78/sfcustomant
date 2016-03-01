package task.model;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Typedef;


/**
 * SfdcOrgDescriptor
 *
 * @author  xlehmf
 */
public class SfdcOrgDescriptor extends Typedef {

  public static final String TYPEDEF_NAME_MASTER = "antlib:task:master";
  public static final String TYPEDEF_NAME_SLAVE = "antlib:task:slave";
  
  private String org;
  private String url;
  private String user;
  private String password;
  private List<SfdcExclude> excludes;

  public SfdcOrgDescriptor()
  {
    excludes = new ArrayList<>();
  }

  public String getOrg()
  {
    return org;
  }

  public void setOrg(String org)
  {
    this.org = org;
  }

  public String getUrl()
  {
    return url;
  }

  public void setUrl(String url)
  {
    this.url = url;
  }

  public String getUser()
  {
    return user;
  }

  public void setUser(String user)
  {
    this.user = user;
  }

  public String getPassword()
  {
    return password;
  }

  public void setPassword(String password)
  {
    this.password = password;
  }

  public void addConfigured(SfdcExclude exclude)
  {
    excludes.add(exclude);
  }
  
  public List<SfdcExclude> getExcludes()
  {
    return excludes;
  }

  public void validateSettings()
  {
    if (StringUtils.isEmpty(org)) {
      throw new BuildException(String.format("The org of the configuration must be set."));
    }
    if (StringUtils.isEmpty(url)) {
      throw new BuildException(String.format("The url of the configuration must be set."));
    }
    if (StringUtils.isEmpty(user)) {
      throw new BuildException(String.format("The user of the configuration must be set."));
    }
    if (StringUtils.isEmpty(password)) {
      throw new BuildException(String.format("The password of the configuration must be set."));
    }
  }
  
}
