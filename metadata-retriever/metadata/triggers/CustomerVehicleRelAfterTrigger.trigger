/*
    Type:      Trigger
    Purpose:   1.PA gets a Customer-Vehicle-Relationship to PC,CV,VAN set Status = "Customer" 
    User Story:US_AU-CD-001
*/
trigger CustomerVehicleRelAfterTrigger on Customer_Vehicle_Relationship__c (after insert, after update) {
    
    if(!CustomSettingUtil.isEnabled('CustomerVehicleRelAfterTrigger')){
        return;
    }
    
    Set<Id> vehicleIds = new Set<Id>();
    Set<Id> customerIds = new Set<Id>();
    List<Customer_Vehicle_Relationship__c> insertCvrs = new List<Customer_Vehicle_Relationship__c>();
    
    for(Customer_Vehicle_Relationship__c cvr : Trigger.new) {
        if(trigger.isInsert){
            // Make sure the vehicle id not null
            if (null == cvr.Vehicle_ID__c){
                cvr.addError('Please select the vehicle Id !');
                return;
            }
            
            if (!customerIds.contains(cvr.Customer__c)){
                customerIds.add(cvr.Customer__c);
            }
                        
            if (!vehicleIds.contains(cvr.Vehicle_ID__c)){
                vehicleIds.add(cvr.Vehicle_ID__c);
            }
            
            insertCvrs.add(cvr);
        }
    }
    system.debug(customerIds);
    system.debug(vehicleIds);
    //US_AU-CD-001 & 002 & 001.1 & 002.1
    if(customerIds.size()>0 && vehicleIds.size()>0){
        CustomerVehicleRelHelper.updataWhenCreateCVR(vehicleIds, customerIds, insertCvrs);
    }
}