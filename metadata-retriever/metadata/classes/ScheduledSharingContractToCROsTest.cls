/*
    Type:       Test Class
    Purpose:    Test the ScheduledSharingContractToCROs class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Barney lai created on 2014-3-3
*/
@isTest(seeAllData=true)
public class ScheduledSharingContractToCROsTest{

    static testMethod void testScheduledSharingContractToCROs(){

        String userRoleId = [select id, name from UserRole where name = 'Customer Retention Office 1'].id;
        String profileId = [select id, name from Profile where name = 'Customer Retention'].id;
        
        User usr = new User();
        usr.UserName = 'test' + Math.rint(Math.random() * 100000) + '@daimler.com';
        usr.UserRoleId = userRoleId;
        usr.ProfileId = profileId;
        usr.LastName = 'Test User';
        usr.Email = 'test001@daimler.com.full';
        usr.Alias = 'test';
        usr.TimeZoneSidKey = 'Asia/Shanghai';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.localesidkey='en_US';
        usr.isActive = true;
        usr.Active_Inactive_Flag__c = true;
        insert usr;   
        
        system.runAs(usr){
            Test.startTest();
            testMain1();
            Test.stopTest();
        }
    }
    
    @future
    private static void testMain1() {
    
        String personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();   
    
        Account account1 = new Account(
            firstName = 'Test',
            lastName = 'lai',
            Salutation = 'Doctor',
            PersonMobilePhone = '13011111111',
            PersonOtherPhone = '13022222222',
            Phone = '1234567',
            Individual_Home_Phone__c = '1234567',
            PersonAssistantPhone = '1234567',
            RecordTypeId = personAccountRT);
        insert account1;
        
        Account account2 = new Account(
            firstName = 'Test',
            lastName = 'lai',
            Salutation = 'Doctor',
            Email__c = 'xiaomusyz@sohu.com',
            PersonAssistantPhone = '1234567',
            RecordTypeId = personAccountRT);
        insert account2;
        
        Contract contract1 = new Contract(AccountId = account1.id,
                                          StartDate = date.today().addDays(-5),
                                          ContractTerm = 13,
                                          Status = 'Current',
                                          GFV__c = true,
                                          Welcome_Call__c = true,
                                          Welcome_Call_Task__c = true);
        insert contract1;
        Contract contract11 = new Contract(AccountId = account2.id,
                                          StartDate = date.today().addDays(-5),
                                          ContractTerm = 13,
                                          Status = 'Current',
                                          GFV__c = true,
                                          Welcome_Call__c = true,
                                          Welcome_Call_Task__c = true);
        insert contract11;
        
        Contract contract2 = new Contract(AccountId = account1.id,
                                          StartDate = date.today().addYears(-1),
                                          ContractTerm = 37,
                                          Status = 'Current',
                                          GFV__c = true,
                                          Annual_Call__c = true,
                                          Annual_Call_Task_1_del__c = true);
        insert contract2;
        
        Contract contract3 = new Contract(AccountId = account1.id,
                                          StartDate = date.today().addYears(-2),
                                          ContractTerm = 49,
                                          Status = 'Current',
                                          GFV__c = true,
                                          Annual_Call__c = true,
                                          Annual_Call_Task_2_del__c = true);
        insert contract3;
        
        Contract contract4 = new Contract(AccountId = account1.id,
                                          StartDate = date.today().addYears(-3),
                                          ContractTerm = 61,
                                          Status = 'Current',
                                          GFV__c = true,
                                          Annual_Call__c = true,
                                          Annual_Call_Task_3_del__c = true);
        insert contract4;
        
        Contract contract5 = new Contract(AccountId = account1.id,
                                          StartDate = date.today().addDays(1),
                                          ContractTerm = 13,
                                          Status = 'Current',
                                          GFV__c = true,
                                          EOC_Call__c = true,
                                          EOC_Call_Task_1_del__c = true);
        insert contract5;
        
        Contract contract6 = new Contract(AccountId = account1.id,
                                          StartDate = date.today().addDays(1),
                                          ContractTerm = 6,
                                          Status = 'Current',
                                          GFV__c = true,
                                          EOC_Call__c = true,
                                          EOC_Call_Task_2_del__c = true);
        insert contract6;
        
        Contract contract7 = new Contract(AccountId = account1.id,
                                          StartDate = date.today().addDays(1),
                                          ContractTerm = 3,
                                          Status = 'Current',
                                          GFV__c = true,
                                          EOC_Call__c = true,
                                          EOC_Call_Task_3_del__c = true);
        insert contract7;
        
        Contract contract22 = new Contract(AccountId = account2.id,
                                          StartDate = date.today().addYears(-1),
                                          ContractTerm = 37,
                                          Status = 'Current',
                                          GFV__c = true,
                                          Annual_Call__c = true,
                                          Annual_Call_Task_1_del__c = true);
        insert contract22;
        
        Contract contract33 = new Contract(AccountId = account2.id,
                                          StartDate = date.today().addYears(-2),
                                          ContractTerm = 49,
                                          Status = 'Current',
                                          GFV__c = true,
                                          Annual_Call__c = true,
                                          Annual_Call_Task_2_del__c = true);
        insert contract33;
        
        Contract contract44 = new Contract(AccountId = account2.id,
                                          StartDate = date.today().addYears(-3),
                                          ContractTerm = 61,
                                          Status = 'Current',
                                          GFV__c = true,
                                          Annual_Call__c = true,
                                          Annual_Call_Task_3_del__c = true);
        insert contract44;
        
        Contract contract55 = new Contract(AccountId = account2.id,
                                          StartDate = date.today().addDays(1),
                                          ContractTerm = 13,
                                          Status = 'Current',
                                          GFV__c = true,
                                          EOC_Call__c = true,
                                          EOC_Call_Task_1_del__c = true);
        insert contract55;
        
        Contract contract66 = new Contract(AccountId = account2.id,
                                          StartDate = date.today().addDays(1),
                                          ContractTerm = 6,
                                          Status = 'Current',
                                          GFV__c = true,
                                          EOC_Call__c = true,
                                          EOC_Call_Task_2_del__c = true);
        insert contract66;
        
        Contract contract77 = new Contract(AccountId = account2.id,
                                          StartDate = date.today().addDays(1),
                                          ContractTerm = 3,
                                          Status = 'Current',
                                          GFV__c = true,
                                          EOC_Call__c = true,
                                          EOC_Call_Task_3_del__c = true);
        insert contract77;
        
        String jobId = System.schedule('ScheduledSharingContractToCROsTest', '0 0 6 * * ?', new ScheduledSharingContractToCROs());
    }
}