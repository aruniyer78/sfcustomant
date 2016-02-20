package task;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Taskdef;

import task.handler.SfdcHandler;
import task.model.SfdcOrgDescriptor;

import com.sforce.soap.enterprise.DescribeSObjectResult;
import com.sforce.soap.enterprise.Field;

/**
 * SfdcCompareDataModelsTask
 *
 * @author  xlehmf
 */
public class SfdcCompareDataModelsTask
  extends Taskdef
{

  private boolean useProxy;
  private String proxyHost;
  private int proxyPort;

  private SfdcOrgDescriptor masterOrg;
  private List<SfdcOrgDescriptor> slaveOrgs;

  public void setUseProxy(boolean useProxy)
  {
    this.useProxy = useProxy;
  }

  public void setProxyHost(String proxyHost)
  {
    this.proxyHost = proxyHost;
  }

  public void setProxyPort(int proxyPort)
  {
    this.proxyPort = proxyPort;
  }

  public void addConfigured(SfdcOrgDescriptor orgDescriptor)
  {
    orgDescriptor.validateSettings();
    
    if (SfdcOrgDescriptor.TYPEDEF_NAME_MASTER.equals(orgDescriptor.getTaskName())) {
      if (null == masterOrg) {
        masterOrg = orgDescriptor;
      }
      else {
        throw new BuildException("There can only be one master organisation!");
      }
    } else if (SfdcOrgDescriptor.TYPEDEF_NAME_SLAVE.equals(orgDescriptor.getTaskName())) {
        slaveOrgs.add(orgDescriptor);
    } else {
      throw new BuildException(String.format("Unknown organisation type: %s!", orgDescriptor.getTaskName()));
    }
  }

  @Override
  public void init()
  {
    super.init();

    slaveOrgs = new ArrayList<>();
  }

  @Override
  public void execute()
  {
    validate();
    initialize();

    SfdcHandler sfdcHandler = new SfdcHandler();
    sfdcHandler.initialize(this,
                           0,
                           false,
                           false,
                           masterOrg.getUrl(),
                           masterOrg.getUser(),
                           masterOrg.getPassword(),
                           useProxy,
                           proxyHost,
                           proxyPort,
                           null);

    List<DescribeSObjectResult> masterSObjects = sfdcHandler.describeSObjects(masterOrg.getOrg());

    sfdcHandler.discardContext();

    for (SfdcOrgDescriptor slaveOrg : slaveOrgs) {
      sfdcHandler = new SfdcHandler();
      sfdcHandler.initialize(this,
                             0,
                             false,
                             false,
                             slaveOrg.getUrl(),
                             slaveOrg.getUser(),
                             slaveOrg.getPassword(),
                             useProxy,
                             proxyHost,
                             proxyPort,
                             null);

      List<DescribeSObjectResult> slaveSObjects = sfdcHandler.describeSObjects(slaveOrg.getOrg());

      sfdcHandler.discardContext();

      compareOrgs(masterOrg.getOrg(), masterSObjects, slaveOrg.getOrg(), slaveSObjects);
    }
  }

  private void compareOrgs(String masterName,
                           List<DescribeSObjectResult> masterSObjects,
                           String slaveName,
                           List<DescribeSObjectResult> slaveSObjects)
  {
    Map<String, DescribeSObjectResult> masterMap = createObjectMap(masterSObjects);
    Map<String, DescribeSObjectResult> slaveMap = createObjectMap(slaveSObjects);

    for (String name : masterMap.keySet()) {
      DescribeSObjectResult masterDSOR = masterMap.get(name);
      DescribeSObjectResult slaveDSOR = slaveMap.remove(name);

      if (null != slaveDSOR) {
        Map<String, String> masterFieldMap = createFieldMap(masterDSOR);
        Map<String, String> slaveFieldMap = createFieldMap(slaveDSOR);

        for (String field : masterFieldMap.keySet()) {
          String masterInfo = masterFieldMap.get(field);
          String slaveInfo = slaveFieldMap.remove(field);

          if (null != slaveInfo) {
            if (!masterInfo.equals(slaveInfo)) {
              log(String.format("The field %s of object %s is different in %s and %s:",
                                field,
                                name,
                                masterName,
                                slaveName));
              log(String.format("%s (%s)", masterInfo, masterName));
              log(String.format("%s (%s)", slaveInfo, slaveName));
            }
          }
          else {
            log(String.format("The field %s of object %s in missing in %s.", field, name, slaveName));
          }
        }

        for (String field : slaveFieldMap.keySet()) {
          log(String.format("The field %s of object %s in missing in %s.", field, name, masterName));
        }
      }
      else {
        log(String.format("The object %s is missing in %s.", name, slaveName));
      }
    }

    for (String name : slaveMap.keySet()) {
      log(String.format("The object %s is missing in %s.", name, masterName));
    }
  }

  private Map<String, String> createFieldMap(DescribeSObjectResult dsor)
  {
    Map<String, String> result = new HashMap<>();

    for (Field field : dsor.getFields()) {
      result.put(field.getName(),
                 String.format("Type: %s Length: %d Digits: %d, Auto: %b Calculated: %b ExternalId: %b",
                               field.getType().name(),
                               field.getLength(),
                               field.getDigits(),
                               field.getAutoNumber(),
                               field.getCalculated(),
                               field.getExternalId()));
    }

    return result;
  }

  private Map<String, DescribeSObjectResult> createObjectMap(List<DescribeSObjectResult> sObjects)
  {
    Map<String, DescribeSObjectResult> result = new HashMap<>();

    for (DescribeSObjectResult dsor : sObjects) {
      result.put(dsor.getName(), dsor);
    }

    return result;
  }

  private void initialize()
  {
    // nothing to do here
  }

  private void validate()
  {
    if (null == masterOrg) {
      throw new BuildException("The master organistation must be specified.");
    }
    if (slaveOrgs.isEmpty()) {
      throw new BuildException("At least one slave organisation must be specified.");
    }
  }

}
