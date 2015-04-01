/*
    Type:       Trigger on Lead_Account__c   
    Purpose:    1. For auto filled Assigned Dealer field as Existing Contract Dealer
                2. Update CRM1 Existing Contract No. lookup field via the CMS Contract Number
                
    User Story: US_AU-Lead-005, quick wins FOS Complaint
    Used By:    
    ---------------------------------------------------------------
    History:
    1. Polaris Yu (BreakingPoint) Created on 2013-09-25
    2. 2015-03-03 Sinow Modified
*/

trigger LeadBeforeTrigger on Lead_Account__c (before insert, before update) {
    
    if(!CustomSettingUtil.isEnabled('LeadBeforeTrigger')){
        return;
    }
    
    // Added by Polaris Yu 2013-9-25
    // For User Story: US_AU-Lead-005
    if(Trigger.isInsert || Trigger.isUpdate){
        // For Finance Leads, if Existing Contract is filled, Assigned Dealer will
        //    be auto filled as Contract Dealer
        LeadHelper.autoFillAssignedDealer(Trigger.new);
    }
    // End of added part, Polaris Yu 2013-9-25
    
    //Update CRM1 Existing Contract No. lookup field via the CMS Contract Number
    Set<String> CMSContractsRelationNames = new Set<String>();
    Map<String, Id> CMSNameContractIdMap = new Map<String, Id>();
    String leadFleetRt = Schema.sObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Fleet Lead').getRecordTypeId();
    
    for(Lead_Account__c lead : Trigger.new) {
        if(lead.RecordTypeId == leadFleetRt && lead.CMS_Contract_Number__c != null && (Trigger.isInsert || (Trigger.isUpdate && lead.CMS_Contract_Number__c != Trigger.oldMap.get(lead.Id).CMS_Contract_Number__c))){
            CMSContractsRelationNames.add(lead.CMS_Contract_Number__c);
        }
    }
    
    for(Contract con : [select Contract_Id__c, Id from Contract where Contract_Id__c in :CMSContractsRelationNames]) {
        CMSNameContractIdMap.put(con.Contract_Id__c, con.Id);
    }
    
    for(Lead_Account__c lead : Trigger.new) {
        if(lead.RecordTypeId == leadFleetRt && lead.CMS_Contract_Number__c != null && (Trigger.isInsert || (Trigger.isUpdate && lead.CMS_Contract_Number__c != Trigger.oldMap.get(lead.Id).CMS_Contract_Number__c))){
            if(CMSNameContractIdMap.containsKey(lead.CMS_Contract_Number__c)) {
                lead.Existing_Contract__c = CMSNameContractIdMap.get(lead.CMS_Contract_Number__c);
            }
            else {
                lead.addError('System does not exist such a contract.');
            }
        }
    }
}