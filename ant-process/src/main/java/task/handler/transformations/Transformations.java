package task.handler.transformations;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Transformations
 *
 * @author  xlehmf
 */
@XmlRootElement
public class Transformations
{

  private List<Transformation> transformations;

  public List<Transformation> getTransformations()
  {
    return transformations;
  }

  @XmlElements({
      @XmlElement(name = "changetext", type = ChangeText.class),
      @XmlElement(name = "changeattribute", type = ChangeAttribute.class),
      @XmlElement(name = "removeelement", type = RemoveElement.class),
      @XmlElement(name = "renamefile", type = RenameFile.class),
      @XmlElement(name = "addelement", type = AddElement.class),
      @XmlElement(name = "skipfile", type = SkipFile.class),
      @XmlElement(name = "defaultpermissions", type = DefaultPermissionsInProfile.class),
      @XmlElement(name = "removeduplicateelement", type = RemoveDuplicateElement.class)})
  public void setTransformations(List<Transformation> transformations)
  {
    this.transformations = transformations;
  }

}
