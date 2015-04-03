/*
 *  Daimler CRM - Extension Platform
 */
package task.handler;

import com.sforce.soap.enterprise.EnterpriseConnection;
import com.sforce.soap.metadata.MetadataConnection;

/**
 * SfdcConnectionContext
 *
 * @author  XLEHMF
 */
public class SfdcConnectionContext
{

  private EnterpriseConnection eConnection;
  private MetadataConnection mConnection;
  
  public SfdcConnectionContext(EnterpriseConnection eConnection, MetadataConnection mConnection)
  {
    this.eConnection = eConnection;
    this.mConnection = mConnection;
  }

  public EnterpriseConnection getEConnection()
  {
    return eConnection;
  }

  public MetadataConnection getMConnection()
  {
    return mConnection;
  }

}

