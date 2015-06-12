/*
 *  Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.File;
import java.util.List;

import task.handler.configuration.DeploymentUnit;
import task.model.SfdcTypeSet;

/**
 * DeploymentInfo
 *
 * @author  XLEHMF
 */
public class DeploymentInfo
{

  private final DeploymentUnit deploymentUnit;
  private final List<File> fileList;
  private final List<String> entityNames;
  private final SfdcTypeSet typeSet;

  public DeploymentInfo(DeploymentUnit du, List<File> fileList, List<String> entityNames, SfdcTypeSet typeSet)
  {
    this.deploymentUnit = du;
    this.fileList = fileList;
    this.entityNames = entityNames;
    this.typeSet = typeSet;
  }

  public DeploymentUnit getDeploymentUnit()
  {
    return deploymentUnit;
  }

  public List<File> getFileList()
  {
    return fileList;
  }

  public List<String> getEntityNames()
  {
    return entityNames;
  }

  public SfdcTypeSet getTypeSet()
  {
    return typeSet;
  }
  
}

