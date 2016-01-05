package task.model;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Typedef;


/**
 * SfdcFeature
 *
 * @author  xlehmf
 */
public class SfdcFeature extends Typedef {
  
  public enum FeatureName
  {
    EXCLUDE_CHECKSUMS("exclude-checksums", true),
    INLCUDE_PERSONACCOUNT("include-personaccount"),
    PACKAGE_NAMESPACES("package-namespaces", true);
    
    private String code;
    private boolean paramRequired;
    
    private FeatureName(String code) {
      this.code = code;
      this.paramRequired = false;
    }
    
    private FeatureName(String code, boolean paramRequired) {
      this.code = code;
      this.paramRequired = paramRequired;
    }
    
    public String getCode()
    {
      return code;
    }
    
    public boolean isParamRequired()
    {
      return paramRequired;
    }

    public static FeatureName findByCode(String code) {
      for (FeatureName fn : values()) {
        if (StringUtils.equals(fn.getCode(), code)) {
          return fn;
        }
      }
      return null;
    }
  }

  private FeatureName name;
  private String param;

  @Override
  public void setName(String name)
  {
    this.name = FeatureName.findByCode(name);
  }

  @Override
  public String getName()
  {
    return name.getCode();
  }
  
  public FeatureName getFeature() {
    return name;
  }

  public String getParam()
  {
    return param;
  }

  public void setParam(String param)
  {
    this.param = param;
  }

  public void validateSettings()
  {
    if (null == name) {
      List<String> codes = new ArrayList<>();
      for (FeatureName fn : FeatureName.values()) {
        codes.add(fn.getCode());
      }
      
      throw new BuildException(String.format("The name of the feature must be set and must match one of the following values: %s.", StringUtils.join(codes, ",")));
    }
    if (name.isParamRequired() && StringUtils.isEmpty(param)) {
      throw new BuildException(String.format("The feature %s requires a parameter.", name.getCode()));
    }
  }
  
}
