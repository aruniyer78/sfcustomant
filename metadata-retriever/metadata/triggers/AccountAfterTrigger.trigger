/*
    Type:       Trigger
    Purpose:    1. Flag the primary contact after the original primary contact is removed.
                
    User Story: US-CD-004
    History: 1.Justin Yu created on  2013-08-20
             2.Justin Yu modified on 2013-08-30
             3.Sinow modified on 2013-09-26
             4.Sinow modified on 2015-03-10 ContactRole
*/

trigger AccountAfterTrigger on Account (after insert, after update, after delete) {
    
    if(!CustomSettingUtil.isEnabled('AccountAfterTrigger')){
        return;
    }
    
    Set<String> companyIds = new Set<String>();
    Set<Id> dealerIds = new Set<Id>();
    List<AccountContactRole> AccountContactRoles = new List<AccountContactRole>();
    Set<Id> personAccountIds = new Set<Id>();
    Map<Id, Id> personAccountIdcontactId = new Map<Id, Id>();
    AccountContactRole temp;
    
    if(trigger.isDelete || trigger.isUpdate) {
        for(Account item : Trigger.old){
            if(item.isPersonAccount && item.Primary__pc && item.Company__c != null){
                if(trigger.isDelete){
                    companyIds.add(item.Company__c);
                }
                if(trigger.isUpdate && item.Company__c != trigger.newMap.get(item.Id).Company__c){
                    companyIds.add(item.Company__c);
                }
            }
        }
    }
    
    if(trigger.isInsert) {
        for(Account item : Trigger.new){
            if(item.isPersonAccount && item.Company__c != null){
                personAccountIds.add(item.Id);
            }
        }
    }
    
    if(personAccountIds.size() > 0) {
        for(Contact con : [select Id, AccountId from Contact where AccountId in :personAccountIds]) {
            personAccountIdcontactId.put(con.AccountId, con.Id);
        }
    }
    
    if(trigger.isInsert) {
        for(Account item : Trigger.new){
            if(item.isPersonAccount && item.Company__c != null && personAccountIdcontactId.containsKey(item.Id)){
                temp = new AccountContactRole();
                temp.AccountId = item.Company__c;
                temp.ContactId = personAccountIdcontactId.get(item.Id);
                temp.Role = item.Job_Title__c;
                AccountContactRoles.add(temp);
            }
        }
    }

    if(trigger.isUpdate){
        String dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        for(Account item : Trigger.new){
            if(item.RecordTypeId == dealerRecordTypeId && !item.Dealer_Active__c && Trigger.oldMap.get(item.Id).Dealer_Active__c) {
                dealerIds.add(item.Id);
            }
        }
    }
    
    if(companyIds.size() > 0){
        AccountHelper.flagPrimaryContact(companyIds);
    }
    
    if(dealerIds.size() > 0){
        AccountHelper.deleteDealerLocators(dealerIds);
    }
    
    if(AccountContactRoles.size() > 0) {
        insert AccountContactRoles;
    }
}