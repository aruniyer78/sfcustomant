/*
    Type:       Trigger
    Purpose:    1. Prevent some Cusotmer Dealer Relationship records from saving.
                2. Update some cusotmer dealer relationship records when saving.
                
    User Story: US-AU-CD-016
    History: Justin created on 2013-8-20
*/

trigger CustomerDealerRelBeforeTrigger on Customer_Dealer_Relationship__c (before insert) {
    
    if(!CustomSettingUtil.isEnabled('CustomerDealerRelBeforeTrigger')){
        return;
    }
    
    List<Customer_Dealer_Relationship__c> cdrs = new List<Customer_Dealer_Relationship__c>();
    for(Customer_Dealer_Relationship__c cdr : trigger.new){
        if(cdr.Customer__c == null || cdr.Dealer__c == null){
            cdr.addError('Customer or Dealer must be provided!');
        }
        else{
            cdrs.add(cdr);
        }
    }
    if(cdrs.size() > 0){
        CustomerDealerRelHelper.preventRelationshipSaving(cdrs);
    }
}