/*
    Type:       Utility for Account
    Purpose:    For user story process unit 
    User Story: US_AU-CD-001, US_AU-CD-002, US_AU-CD-001.6, US_AU-DD-004
    Used By:    AccountTriggerBeforeInsertOrUpdate
    ---------------------------------------------------------------
    History:
        1. Bing Bai Created on 2013-08-05
        2. Stanley updated on 2013-08-07
        3. Justin Yu modified on 2013-08-09
        4. Stanley Yang updated on 2013-08-30
        5. Sinow updated on 2013-09-26     delete Dealer locators   US_AU-DD-004
        6. Shuang Li updated on 2014-02-20     CR-000213
*/
public with sharing class AccountHelper {

    private static final String ONE_SPACE = ' ';
    
    public static final Set<Id> RECORD_TYPE_SET = new Set<Id>{
        Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
        Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId()
    };
        
    //US-CD-001 #7. update field "Display Name"
    public static Account updateDisplayName(Account acc){
        
        if (String.isblank(acc.Partner_Surname__c)) {
            //if no partner information available than <Customer Title> < First Name> <Surname> <Suffix>
            acc.Display_Name__c = 
                (String.isblank(acc.Salutation)?'': acc.Salutation + ONE_SPACE) + 
                (String.isblank(acc.FirstName)?'': acc.FirstName + ONE_SPACE) + 
                (String.isblank(acc.LastName)?'': acc.LastName + ONE_SPACE) + 
                (String.isblank(acc.Suffix__c)?'': acc.Suffix__c);
        }else{
            //if the surname of Customer and Partner is equal then <Title Customer> and <Title Partner> <Surname Customer>
            if (acc.LastName == acc.Partner_Surname__c){
                acc.Display_Name__c = 
                    (String.isblank(acc.Salutation)? '' : acc.Salutation) + 
                    ' and ' + 
                    (String.isblank(acc.Partner_Title__c)?'': acc.Partner_Title__c) + ONE_SPACE + 
                    (String.isblank(acc.LastName)?'': acc.LastName);
            }else{
               //If the surname is unequal the <Title Customer> <First Name Surname Customer> and <Title Partner> <First Name Surname Partner>
                acc.Display_Name__c = (String.isblank(acc.Salutation)?'': acc.Salutation + ONE_SPACE) + 
                                      (String.isblank(acc.FirstName)?'': acc.FirstName + ONE_SPACE) + 
                                      (String.isblank(acc.LastName)?'': acc.LastName) + ' and ' +
                                      (String.isblank(acc.Partner_Title__c)?'': acc.Partner_Title__c + ONE_SPACE) +
                                      (String.isblank(acc.Partner_First_Name__c)?'': acc.Partner_First_Name__c + ONE_SPACE) +
                                      (String.isblank(acc.Partner_Surname__c)?'': acc.Partner_Surname__c);
            }
        }
        return acc;
    }
    
    //US-CD-001, US-CD-002 Get pc status and cv status by customerIds
    public static Map<id,Account> getCustomerInfos(set<Id> ids){
        return new Map<id,Account>([
               select id,
                       PC_Status__c,
                       CV_Status__c,
                       PC_Tenure__c,
                       CV_Tenure__c,
                       PC_No_Brand_Purchases__c,
                       CV_No_Brand_Purchases__c,
                       VAN_Status__c,
                       VAN_Tenure__c,
                       VAN_No_Brand_Purchases__c
                from Account
                where Id in :ids]);
    }

    //US-CD-001, US-CD-002 set field default value when object created
    public static Account setDefaultValue(Account acc){
        if (RECORD_TYPE_SET.contains(acc.RecordTypeId)){
            acc.PC_Status__c = 'Prospect';
            acc.CV_Status__c = 'Prospect';
            acc.VAN_Status__c = 'Prospect';
        }
        return acc;
    }
     
    // US_AU-CD-004: cancel the primary contact.
    public static void cancelPrimaryContact(Set<String> newCompanyIds, Set<String> personIds){
        
        Account[] cancelPrimaryAccounts = [select Primary__pc from Account 
                                           where Company__c in :newCompanyIds 
                                           and Primary__pc = true
                                           and Id not in :personIds];
        if(cancelPrimaryAccounts.size() > 0){
            for(Account item : cancelPrimaryAccounts){
                item.Primary__pc = false;
            }
            update cancelPrimaryAccounts;
        }
    }
    
    // US_AU-CD-004: flag the primary contact.
    public static void flagPrimaryContact(Set<String> companyIds){
        
        Map<String, Account> primaryContacts = new Map<String, Account>();
        Map<String, List<Account>> contacts = new Map<String, List<Account>>();
        
        for(Account item : [select Primary__pc, Company__c from Account where Company__c in :companyIds order by CreatedDate desc]){
            if(contacts.containsKey(item.Company__c)){
                contacts.get(item.Company__c).add(item);
            }
            else{
                contacts.put(item.Company__c, new List<Account>{item});
            }
        }

        for(String companyId : companyIds){
            List<Account> cons = contacts.get(companyId);
            if(cons != null && cons.size() > 0){
                cons[0].Primary__pc = true;
                primaryContacts.put(cons[0].Id, cons[0]);
            }
        }

        if(primaryContacts.size() > 0){
            update primaryContacts.values();
        }
    }
    
    // US_AU-CD-001.6 Track the updating history for FS fields
    public static void trackUpdatHistoryForFsInfo(Account updateAcc, Account oldAcc){
        if(updateAcc.FS_Opt_In_Email__c != oldAcc.FS_Opt_In_Email__c){
            updateAcc.FS_Email_Last_Modified_By__c = UserInfo.getName();
            updateAcc.FS_Email_Last_Modified_Date__c = System.now();
        }
        if(updateAcc.FS_Opt_In_Hardcopy__c != oldAcc.FS_Opt_In_Hardcopy__c){
            updateAcc.FS_Hardcopy_Last_Modified_By__c = UserInfo.getName();
            updateAcc.FS_Hardcopy_Last_Modified_Date__c = System.now();
        }
        
        if(updateAcc.FS_Opt_In_Phone__c != oldAcc.FS_Opt_In_Phone__c){
            updateAcc.FS_Phone_Last_Modified_By__c = UserInfo.getName();
            updateAcc.FS_Phone_Last_Modified_Date__c = System.now();
        }
        
        if(updateAcc.FS_Opt_In_SMS__c != oldAcc.FS_Opt_In_SMS__c){
            updateAcc.FS_SMS_Last_Modified_By__c = UserInfo.getName();
            updateAcc.FS_SMS_Last_Modified_Date__c = System.now();
        }
        if(updateAcc.Opt_In_Email__c != oldAcc.Opt_In_Email__c){
            updateAcc.Email_Last_Modified_By__c = UserInfo.getName();
            updateAcc.Email_Last_Modified_Date__c = System.now();
        }
        if(updateAcc.Opt_In_Hardcopy__c != oldAcc.Opt_In_Hardcopy__c){
            updateAcc.Hardcopy_Last_Modified_By__c = UserInfo.getName();
            updateAcc.Hardcopy_Last_Modified_Date__c = System.now();
        }
        
        if(updateAcc.Opt_In_Phone__c != oldAcc.Opt_In_Phone__c){
            updateAcc.Phone_Last_Modified_By__c = UserInfo.getName();
            updateAcc.Phone_Last_Modified_Date__c = System.now();
        }
        
        if(updateAcc.Opt_In_SMS__c != oldAcc.Opt_In_SMS__c){
            updateAcc.SMS_Last_Modified_By__c = UserInfo.getName();
            updateAcc.SMS_Last_Modified_Date__c = System.now();
        }
    }
    
    //Delete Dealer locators   US_AU-DD-004
    public static void deleteDealerLocators(Set<Id> dealerIds) {
    	
        try {
        	//   CR-000213 start
            List<Dealer_Locator__c> dealerLocators = [select Id from Dealer_Locator__c where Dealer_Name__c in :dealerIds];
            for (Dealer_Locator__c dl : dealerLocators){
                 dl.Inactive__c = true;
            }
            update dealerLocators;
            List<Contact> contacts = [select id from Contact where AccountId in :dealerIds];
            for (Contact con : contacts){
                 con.Inactive__c = true;
            }
            update contacts;
            //   CR-000213 end
        }
        catch(Exception ex) {
            trigger.new[0].addError('inactivate Dealer Locator Error, please contact administrator');
        }
    }
}