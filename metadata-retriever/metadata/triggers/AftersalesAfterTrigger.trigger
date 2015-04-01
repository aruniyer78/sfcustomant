/*
    Type:       Trigger on Aftersales   
    Purpose:    when aftersales insert update account info
                
    User Story: US-CD-001
    Used By:    
    ---------------------------------------------------------------
    History:
    
*/

trigger AftersalesAfterTrigger on Aftersales__c(after update, after insert) {

    if(!CustomSettingUtil.isEnabled('AftersalesAfterTrigger')){
        return;
    }
    
    Set<Id> aftersalesInfo = new Set<Id>();
    for (Aftersales__c aftersales : trigger.new) {
        aftersalesInfo.add(aftersales.Service_Vehicle__c);
    }
    
    if(aftersalesInfo.size()>0){
        AfterSalesHelper.updateAccountStatus(aftersalesInfo);
    }
}