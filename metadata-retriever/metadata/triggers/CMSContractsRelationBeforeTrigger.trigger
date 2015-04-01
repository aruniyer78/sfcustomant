/*
    Purpose:    Update CMS Contract lookup field via the CMS Name
    User Story: quick wins FOS Complaint

    Used By:    
    ---------------------------------------------------------------
    History:

    2015-02-25 Sinow Created
*/
trigger CMSContractsRelationBeforeTrigger on CMS_Contracts_Relation__c (before insert) {
    
    Set<String> CMSContractsRelationNames = new Set<String>();
    Map<String, Id> CMSNameContractIdMap = new Map<String, Id>();
    
    for(CMS_Contracts_Relation__c  ccr : Trigger.new) {
        CMSContractsRelationNames.add(ccr.Name);
    }
    
    for(Contract con : [select Contract_Id__c, Id from Contract where Contract_Id__c in :CMSContractsRelationNames]) {
        CMSNameContractIdMap.put(con.Contract_Id__c, con.Id);
    }
    
    for(CMS_Contracts_Relation__c  ccr : Trigger.new) {
        if(CMSNameContractIdMap.containsKey(ccr.Name)) {
            ccr.CRM1_Contract__c = CMSNameContractIdMap.get(ccr.Name);
        }
        else {
            ccr.addError('System does not exist such a contract.');
        }
    }
}