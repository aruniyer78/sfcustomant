/*
    Type:       Test Class
    Purpose:    Test the ScheduledSendNotificationEmail class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Justin Yu created on 2013-10-23
*/
@isTest
public class ScheduledSendNotificationEmailTest{
    
    static testMethod void testScheduledSendNotificationEmail(){
        String personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String leadFinanceRT = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Finance Lead').getRecordTypeId();
        String leadFleetRT = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Fleet Lead').getRecordTypeId();
        
        Account account = new Account(RecordTypeId = personRecordTypeId);
        account.Status__c='Customer';
        account.LastName = 'LastName';
        account.Salutation = 'Title';
        account.FirstName = 'FirstName';
        account.Suffix__c = 'suffix';
        account.PersonEmail='bing.bai@nttdata.com';
        account.PersonMobilePhone ='1800 999 999';
        insert account;
        
        Vehicle__c vehicle = new Vehicle__c(Name='Vehicle', Class__c = 'C-Class Sedan');
        insert vehicle;
        
        Contract contract = new Contract(AccountId = account.Id);
        contract.StartDate = Date.Today();
        contract.Contract_End_Date__c = Date.Today().addMonths(18);
        contract.Vehicle__c = vehicle.Id;
        insert contract;
        
        Lead_Account__c financeLeadWith15Days = new Lead_Account__c(
            RecordTypeId = leadFinanceRT, 
            Contact__c = account.Id,
            Lead_Source__c = 'End of Contract',
            Nature_of_Request__c = 'Key2Key',
            Business_Unit__c = 'Cars',
            Sub_BusinessUnit__c = 'Sales',
            Lead_Status__c = 'New Enquiry',
            Existing_Contract__c = contract.Id,
            //Financial_Product__c = 'Agility Contract',
            Is_Finance_Send_Email_Before_15_Days__c = true
        );
        insert financeLeadWith15Days;
        
        Lead_Account__c financeLeadWith20Days = financeLeadWith15Days.clone();
        financeLeadWith20Days.Is_Finance_Send_Email_Before_20_Days__c = true;
        insert financeLeadWith20Days;
        
        Lead_Account__c financeLeadWith45Days = financeLeadWith15Days.clone();
        financeLeadWith45Days.Is_Fleet_Send_Email_Before_45_Days__c = true;
        insert financeLeadWith45Days;
        
        Lead_Account__c fleetLeadWith15Days = new Lead_Account__c(
            RecordTypeId = leadFleetRT, 
            Contact__c = account.Id,
            Lead_Source__c = 'End of Contract',
            Nature_of_Request__c = 'Key2Key',
            Business_Unit__c = 'Cars',
            Sub_BusinessUnit__c = 'Sales',
            Lead_Status__c = 'New Enquiry',
            Existing_Contract__c = contract.Id,
            //Financial_Product__c = 'Agility Contract',
            Is_Fleet_Send_Email_Before_15_Days__c = true
        );
        insert fleetLeadWith15Days;
        
        Lead_Account__c fleetLeadWith20Days = fleetLeadWith15Days.clone();
        fleetLeadWith20Days.Is_Fleet_Send_Email_Before_20_Days__c = true;
        insert fleetLeadWith20Days;
        
        Lead_Account__c fleetLeadWith60Days = fleetLeadWith15Days.clone();
        fleetLeadWith60Days.Is_Fleet_Send_Email_Before_60_Days__c = true;
        insert fleetLeadWith60Days;
        
        Test.startTest();
        System.schedule('ScheduledSendNotificationEmailTest', '0 0 13 * * ?', new ScheduledSendNotificationEmail());
        Test.stopTest();
    }
}