/*
    Type:       Trigger for Address
    Purpose:    When an address be created, execute prefered address calculation.
    User Story: US_AU-CD-003
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Bing Bai Created on 2013-08-06
    2. Justin Yu modified on 2013-08-07
*/
trigger AddressAfterTrigger on Address__c (after insert, after update, after delete) {
    
    if(!CustomSettingUtil.isEnabled('AddressAfterTrigger')){
        return;
    }
    
    String personAccountRTID = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
    String companyRTID =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
    
    // 1. Searches the related records
    Set<String> customerIds = new Set<String>();
    if(trigger.isDelete){
        for(Address__c item : Trigger.old){
            if(item.Preferred__c && (item.RecordTypeId == personAccountRTID || item.RecordTypeId == companyRTID)){
                customerIds.add(item.Customer__c);
            }
        }
        
    }
    else{
        for(Address__c address : Trigger.new) {
            if(Trigger.isUpdate && Trigger.oldMap.get(address.Id).Preferred__c != address.Preferred__c){
                continue;
            }
            if(address.RecordTypeId == personAccountRTID || address.RecordTypeId == companyRTID){
                customerIds.add(address.Customer__c);
            }
        }
    }
    
    // 2. Business logics  -- preferred the address and populate the address info to its customer
    if(customerIds.size() > 0){
        AddressHelper.flagPreferredAddressAndPopulateToCustomer(customerIds);
    }
}