/*
    Type:       Utility for Lead_Account__c
    Purpose:    For send email notifications to the Dealer recipient 
    User Story: US_AU-Lead-013,US_AU-Lead-014,US_AU-Lead-015,US_AU-Lead-016,US_AU-Lead-017
    Used By:    
    ---------------------------------------------------------------
    History:
        1. Barney Lai Created on 2013-09-18
*/

global class ScheduledSendNotificationEmail implements Schedulable{

    private static final String leadFinanceRT = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Finance Lead').getRecordTypeId();
    private static final String leadFleetRT = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Fleet Lead').getRecordTypeId();

    global void execute(SchedulableContext SC) {
        
        List<Lead_Account__c> financeLeads = new List<Lead_Account__c>();
        List<Lead_Account__c> fleetLeads = new List<Lead_Account__c>();
        Map<Lead_Account__c, Id> financeLeadsContractId = new Map<Lead_Account__c, Id>();
        Map<Lead_Account__c, Id> fleetLeadsContractId = new Map<Lead_Account__c, Id>();
        Map<Lead_Account__c, Contract> financeLeadsContract = new Map<Lead_Account__c, Contract>();
        Map<Lead_Account__c, Contract> fleetLeadsContract = new Map<Lead_Account__c, Contract>();
        List<Lead_Account__c> prepareLeads = new List<Lead_Account__c>();
        
        financeLeads = [select id, Status_Category__c, Lead_Source__c, Existing_Contract__c,
            Is_Finance_Send_Email_Before_15_Days__c, Is_Finance_Send_Email_Before_20_Days__c,
             Is_Finance_Send_Email_Before_60_Days__c, Is_Fleet_Send_Email_Before_45_Days__c 
            from Lead_Account__c where RecordTypeId = :leadFinanceRT];
        
        fleetLeads = [select id, Status_Category__c, Lead_Source__c, Existing_Contract__c,
            Is_Fleet_Send_Email_Before_15_Days__c , Is_Fleet_Send_Email_Before_20_Days__c ,
            
            Is_Fleet_Send_Email_Before_60_Days__c from Lead_Account__c where RecordTypeId = :leadFleetRT];
        
        for(Lead_Account__c lead : financeLeads) {
            if(lead.Existing_Contract__c != null) {
                financeLeadsContractId.put(lead, lead.Existing_Contract__c);
            }
        }
        for(Lead_Account__c lead : fleetLeads) {
            if(lead.Existing_Contract__c != null) {
                fleetLeadsContractId.put(lead, lead.Existing_Contract__c);
            }
        }
        if(financeLeadsContractId.size() > 0) {
            for(Contract contract : [select id, Contract_End_Date__c from Contract where id in :financeLeadsContractId.values()]) {
                for(Lead_Account__c lead : financeLeadsContractId.keyset()) {
                    if(contract.id == financeLeadsContractId.get(lead)) {
                        financeLeadsContract.put(lead, contract);
                    }
                }
            }
        }
        if(fleetLeadsContractId.size() > 0) {
            for(Contract contract : [select id, Contract_End_Date__c from Contract where id in :fleetLeadsContractId.values()]) {
                for(Lead_Account__c lead : fleetLeadsContractId.keyset()) {
                    if(contract.id == fleetLeadsContractId.get(lead)) {
                        fleetLeadsContract.put(lead, contract);
                    }
                }
            }
        }
        
        for(Lead_Account__c lead : financeLeadsContract.keyset()) {
            if(lead.Status_Category__c == 'Open' && lead.Lead_Source__c == 'End of Contract'
                && lead.Is_Finance_Send_Email_Before_15_Days__c == false) {
                Contract c = financeLeadsContract.get(lead);
                if(c != null && c.Contract_End_Date__c == Date.today() + 15) {
                    lead.Is_Finance_Send_Email_Before_15_Days__c = true;
                    prepareLeads.add(lead);
                }
            }
            
            if(lead.Status_Category__c == 'Open' && lead.Lead_Source__c == 'End of Contract'
                && lead.Is_Finance_Send_Email_Before_20_Days__c == false) {
                Contract c = financeLeadsContract.get(lead);
                if(c != null && c.Contract_End_Date__c == Date.today() + 20) {
                    lead.Is_Finance_Send_Email_Before_20_Days__c = true;
                    prepareLeads.add(lead);
                }
            }
           
            if(lead.Status_Category__c == 'Open' && lead.Lead_Source__c == 'End of Contract'
                && lead.Is_FLeet_Send_Email_Before_45_Days__c == false) {
                Contract c = financeLeadsContract.get(lead);
                if(c != null && c.Contract_End_Date__c == Date.today() + 45) {
                    lead.Is_Fleet_Send_Email_Before_45_Days__c = true;
                    prepareLeads.add(lead);
                }
            }
            
            if(lead.Status_Category__c == 'Open' && lead.Lead_Source__c == 'End of Contract'
                && lead.Is_Finance_Send_Email_Before_60_Days__c == false) {
                Contract c = financeLeadsContract.get(lead);
                if(c != null && c.Contract_End_Date__c == Date.today() + 60) {
                    lead.Is_Finance_Send_Email_Before_60_Days__c = true;
                    prepareLeads.add(lead);
                }
            }
        }
        
        for(Lead_Account__c lead : fleetLeadsContract.keyset()) {
            if(lead.Status_Category__c == 'Open' && lead.Lead_Source__c == 'End of Contract'
                && lead.Is_Fleet_Send_Email_Before_15_Days__c == false) {
                Contract c = fleetLeadsContract.get(lead);
                if(c.Contract_End_Date__c == Date.today() + 15) {
                    lead.Is_Fleet_Send_Email_Before_15_Days__c = true;
                    prepareLeads.add(lead);
                }
            }
            
            if(lead.Status_Category__c == 'Open' && lead.Lead_Source__c == 'End of Contract'
                && lead.Is_Fleet_Send_Email_Before_20_Days__c == false) {
                Contract c = fleetLeadsContract.get(lead);
                if(c.Contract_End_Date__c == Date.today() + 20) {
                    lead.Is_Fleet_Send_Email_Before_20_Days__c = true;
                    prepareLeads.add(lead);
                }
            }
            
            if(lead.Status_Category__c == 'Open' && lead.Lead_Source__c == 'End of Contract'
                && lead.Is_Fleet_Send_Email_Before_60_Days__c == false) {
                Contract c = fleetLeadsContract.get(lead);
                if(c.Contract_End_Date__c == Date.today() + 60) {
                    lead.Is_Fleet_Send_Email_Before_60_Days__c = true;
                    prepareLeads.add(lead);
                }
            }
        }
        
        if(prepareLeads.size() > 0) {
            try{
                update prepareLeads;
            }
            catch(DMLException e){
                System.debug('Debug Output ======> {Error: '+ e + '}');
            }    
        }
    }
}