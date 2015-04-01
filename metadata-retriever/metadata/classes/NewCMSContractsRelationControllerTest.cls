/*
    Type:       test class
    Purpose:    NewCMSContractsRelationController test class
    User Story: quick wins FOS Complaint

    Used By:    NewCMSContractsRelationController 
    ---------------------------------------------------------------
    History:

    2015-02-27 Sinow Created
*/
@isTest
public class NewCMSContractsRelationControllerTest {

    private static Id FOSId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FOS Complaint').getRecordTypeId();
    private static TestDataUtil testData = TestDataUtil.getInstance();
       
    public static testMethod void testNewCMSContractsRelationController() {
        
        Account customer = testData.standardPersonAccount;
        insert customer;
        
        Contract contr = new Contract();
        contr.Contract_Id__c = 'acme1234';
        contr.AccountId = customer.Id;
        insert contr;
        
        Case c = new Case();
        c.RecordTypeId = FOSId;
        c.Subject = 'acme';
        insert c;
        
        CMS_Contracts_Relation__c cms = new CMS_Contracts_Relation__c();
        cms.CRM1_Case_No__c = c.Id;
        
        ApexPages.standardController controller = new ApexPages.standardController(cms);
        NewCMSContractsRelationController newCMS = new NewCMSContractsRelationController(controller);
        newCMS.CMSContractsRelationInfo.Name = 'acme1234';
        newCMS.saveCMS();
        newCMS.cancelCMS();
    }
}