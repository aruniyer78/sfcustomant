/*
    Type:       Trigger on Lead_Account__c   
    Purpose:    For send email notifications to the Dealer recipients
                
    User Story: US_AU-Lead-013,US_AU-Lead-014,US_AU-Lead-015,US_AU-Lead-016,US_AU-Lead-017
    Used By:    
    ---------------------------------------------------------------
    History:
    1. Barney Lai Created on 2013-08-22 
    2. Polaris Yu (BreakingPoint) Updated on 2013-8-29
*/

trigger LeadAfterTrigger on Lead_Account__c (after insert, after update) {
    
    private static final String leadFinanceRT = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Finance Lead').getRecordTypeId();
    private static final String leadSPRt = Schema.sObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Service/Parts Lead').getRecordTypeId();
    private static final String leadVehicleRt = Schema.sObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Vehicle Lead').getRecordTypeId();
    Map<Id, User> IntegrationUsers = new Map<Id, User>([select Id from User where Profile.Name = 'IntegrationAPI']);
    
    if(!CustomSettingUtil.isEnabled('LeadAfterTrigger') && !Test.isRunningTest()){
        return;
    }
    
    List<Lead_Account__c> preparedLeads = new List<Lead_Account__c>();
    
    for(Lead_Account__c lead : Trigger.new) {
        preparedLeads.add(lead);
    }
    if(preparedLeads.size() > 0) {
        LeadHelper.checkrecord(preparedLeads);
    }
    // Added by Polaris Yu 2013-8-29

    // For User Story: US_AU-Lead-007; US_AU-Lead-021
    if(Trigger.isInsert || Trigger.isUpdate){
        // For qualified Leads, they will be automatically assigned
        //    to the dealer sales gate keeper user
        LeadHelper.autoAssignLeads(Trigger.newMap, Trigger.oldMap);        
    }
    
    //CR-000141 Send Immediate Notice and 24H and 72H Email for Service/Parts Lead.
    List<Lead_Account__c> serviceLeadsForImmediateNotice = new List<Lead_Account__c>();
    List<Lead_Account__c> serviceLeadsFor24H = new List<Lead_Account__c>();
    List<Lead_Account__c> serviceLeadsFor72H = new List<Lead_Account__c>();
    Set<Id> serviceDealerIdsForImmediateNotice = new Set<Id>();
    Set<Id> serviceDealerIdsFor24H = new Set<Id>();
    Set<Id> serviceDealerIdsFor72H = new Set<Id>();
    
    //CR-000141 Send Immediate Notice and 24H and 72H Email for Finance Lead.
    List<Lead_Account__c> financeLeads = new List<Lead_Account__c>();
    Set<Id> financeDealerIds = new Set<Id>();

    
    for(Lead_Account__c lead : Trigger.new) {
        If(lead.Assigned_Dealer__c != null && lead.Business_Unit__c != null && lead.Sub_BusinessUnit__c != null && 
          (Trigger.isInsert || (Trigger.isUpdate && lead.Assigned_Dealer__c != Trigger.oldMap.get(lead.Id).Assigned_Dealer__c)) && 
          (lead.LDCL_Lead_Id__c == null || (lead.LDCL_Lead_Id__c != null && !IntegrationUsers.KeySet().contains(lead.LastModifiedById)))) {
            if(lead.RecordTypeId == leadSPRt || lead.RecordTypeId == leadVehicleRt) { 
                serviceLeadsForImmediateNotice.add(lead);
                serviceDealerIdsForImmediateNotice.add(lead.Assigned_Dealer__c);
            }
            else if(lead.RecordTypeId == leadFinanceRT) {
                financeLeads.add(lead);
                financeDealerIds.add(lead.Assigned_Dealer__c);
            }
        }
        If(lead.Assigned_Dealer__c != null && lead.Business_Unit__c != null && lead.Sub_BusinessUnit__c != null && 
          Trigger.isUpdate && lead.X24H_Untouched__c && lead.X24H_Untouched__c != Trigger.oldMap.get(lead.Id).X24H_Untouched__c) {
            if(lead.RecordTypeId == leadSPRt || lead.RecordTypeId == leadVehicleRt) { 
                serviceLeadsFor24H.add(lead);
                serviceDealerIdsFor24H.add(lead.Assigned_Dealer__c);
            }
            else if(lead.RecordTypeId == leadFinanceRT) {
                financeLeads.add(lead);
                financeDealerIds.add(lead.Assigned_Dealer__c);
            }
        }
        If(lead.Assigned_Dealer__c != null && lead.Business_Unit__c != null && lead.Sub_BusinessUnit__c != null && 
          Trigger.isUpdate && lead.X72H_Untouched__c && lead.X72H_Untouched__c != Trigger.oldMap.get(lead.Id).X72H_Untouched__c) {
            if(lead.RecordTypeId == leadSPRt || lead.RecordTypeId == leadVehicleRt) {
                serviceLeadsFor72H.add(lead);
                serviceDealerIdsFor72H.add(lead.Assigned_Dealer__c);
            }
            else if(lead.RecordTypeId == leadFinanceRT) {
                financeLeads.add(lead);
                financeDealerIds.add(lead.Assigned_Dealer__c);
            }
        }
    }
    
    if(serviceLeadsForImmediateNotice.size() > 0) {
        LeadHelper.sendServicePartsEmail(serviceLeadsForImmediateNotice, serviceDealerIdsForImmediateNotice, 'Immediate Notice');
    }
    if(serviceLeadsFor24H.size() > 0) {
        LeadHelper.sendServicePartsEmail(serviceLeadsFor24H, serviceDealerIdsFor24H, '24H Untouched Notice');
    }
    if(serviceLeadsFor72H.size() > 0) {
        LeadHelper.sendServicePartsEmail(serviceLeadsFor72H, serviceDealerIdsFor72H, '72H Untouched Notice');
    }
    if(financeLeads.size() > 0) {
        LeadHelper.sendFinanceEmail(financeLeads, financeDealerIds);
    }
}