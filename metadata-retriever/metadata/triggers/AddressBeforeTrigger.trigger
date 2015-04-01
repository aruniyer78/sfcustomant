/*
    Type:       Trigger for Address
    Purpose:    Validate that it shouldn't exist two addresses with same type. US_AU-CD-003
                Auto-fill the post code by the suburb. US_AU-CD-003
                Change the letters of suburb to capital ones.  US_AU-CD-032
    User Story: US_AU-CD-003, US_AU-CD-032
    Used By:    Address__c
    ---------------------------------------------------------------
    History:
    
    1. Bing Bai Created on 2013-08-06
    2. Stanley Yang modified on 2013-08-13
    3. Stanley Yang modified on 2013-08-29
*/
trigger AddressBeforeTrigger on Address__c (before insert, before update) {
    
    if(!CustomSettingUtil.isEnabled('AddressBeforeTrigger')){
        return;
    }
    
    String personAccountRTID = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
    String companyRTID =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
    
    Set<String> csIds = new Set<String>();
    Set<String> suburbs = new Set<String>();
  
    for(Address__c addre : Trigger.new) {
        if(!csIds.contains(addre.Customer__c)){
            csIds.add(addre.Customer__c);
        }
           
        //US_AU-CD-032 Make sure the letters of suburb is capital ones
        if(!String.isBlank(addre.Suburb__c)){
            addre.Suburb__c = addre.Suburb__c.toUpperCase();
            suburbs.add(addre.Suburb__c);
        }
    }
    
    private Map<String,String> suburbAndPostCodeMapping = AddressHelper.getMappingBetweenSuburbAndZip(suburbs);
    
    for(Address__c addre : Trigger.new){
        //US_AU-CD-003, Auto-fill the post code if the suburb-postcode mapping is existed 
        if(String.isBlank(addre.Post_Code__c) 
            && !String.isBlank(addre.Suburb__c) 
            && suburbAndPostCodeMapping.containsKey(addre.Suburb__c)
            && (addre.RecordTypeId == personAccountRTID || addre.RecordTypeId == companyRTID)) {
                
            addre.Post_Code__c = suburbAndPostCodeMapping.get(addre.Suburb__c);
        }
    }
    
    //US_AU-CD-003 No.4
    if(csIds.size()>0){
        Map<String,List<Address__c>> AddressInfoMap = AddressHelper.getAllAddresses(csIds);
        for(Address__c addre : Trigger.new) {
            if(AddressInfoMap.get(addre.Customer__c) != null && (addre.RecordTypeId == personAccountRTID || addre.RecordTypeId == companyRTID)){
                for(Address__c oldInfo : AddressInfoMap.get(addre.Customer__c)){
                    if(oldInfo.Address_Type__c == addre.Address_Type__c && (Trigger.isInsert || (Trigger.isUpdate && trigger.oldMap.get(addre.id).Address_Type__c != addre.Address_Type__c))){
                        addre.addError('Please use another address type, this one already exists for the customer!'); 
                    }
                }           
            }
        }
    }
}