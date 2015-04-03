/*
 *  Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.File;
import java.util.List;

import task.handler.configuration.DeploymentUnit;

/**
 * DeploymentInfo
 *
 * @author  XLEHMF
 */
public class DeploymentInfo
{

  private DeploymentUnit deploymentUnit;
  private List<File> fileList;
  private List<String> entityNames;

  public DeploymentInfo(DeploymentUnit du, List<File> fileList, List<String> entityNames)
  {
    this.deploymentUnit = du;
    this.fileList = fileList;
    this.entityNames = entityNames;
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

  
}

