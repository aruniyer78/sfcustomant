/*
    Type:       Trigger
    Purpose:    PA gets a Customer-FinancialContract-Relationship linked to a PC - Status = "Customer" 
                
    User Story: US_AU-CD-001,US_AU-CD-002
    ---------------------------------------------------------------
    History:

    1. Polaris Yu (BreakingPoint) Updated on 2013-8-23
*/
trigger ContractAfterTrigger on Contract (after insert, after update) {
    
    if(!CustomSettingUtil.isEnabled('ContractAfterTrigger') && !Test.isRunningTest()){
        return;
    }
    
    Set<ID> vehicleIds = new Set<ID>();
    Set<ID> customerIds = new Set<ID>();
    List<Contract> insertCvrs = new List<Contract>();
    
    // For US_AU-CD-019
    Set<String> contractIds = new Set<String>();
    
    for(Contract cvr : Trigger.new) {
        if(trigger.isInsert){
            customerIds.add(cvr.AccountId);
            vehicleIds.add(cvr.Vehicle__c);
            insertCvrs.add(cvr);
        }
        contractIds.add(cvr.Id);
    }
    
    // US_AU-CD-001 & 2 No.11
    if(customerIds.size()>0 && vehicleIds.size()>0){
        ContractHelper.updataWhenCreateCCR(vehicleIds, customerIds, insertCvrs);
    }
    
    // US_AU-CD-019, If the borrower is company, create a Company Individual Relationship.
    if(contractIds.size() > 0){
        ContractHelper.createCompanyIndividualRelationship(contractIds);
    }

    // Added by Polaris Yu 2013-8-23; For User Story: 
    //    US_AU-Lead-011, US_AU-Lead-012
    if(Trigger.isUpdate){
        // Auto create leads for contracts at 150 days before the
        //    end date
        ContractHelper.autoCreateLeads(Trigger.newMap, Trigger.oldMap);
    }
    // End of added part, Polaris Yu 2013-8-23
}