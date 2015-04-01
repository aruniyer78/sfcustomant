/*
    Type:       Test class for class: ExtSelectAssignedDealer
    Purpose:    Test codes
    User Story: US AU-Lead-007
    Used By:    
    ---------------------------------------------------------------
    History:

    1. Polaris Yu (BreakingPoint) Created on 2013-8-28
*/
@isTest
public class ExtSelectAssignedDealerTest {
    public static testMethod void testSelectAssignedDealer(){
        // Create a Person Account and a Dealer Account
        Id personAccRTId = 
            Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Person Account').getRecordTypeId();
        Account personAcc = new Account(Status__c = 'Customer'
                                        , LastName = 'LastName'
                                        , Salutation = 'Mr'
                                        , Title__c = 'Title'
                                        , FirstName = 'FirstName'
                                        , Suffix__c = 'suffix'
                                        , PersonEmail ='test@test.com'
                                        , RecordTypeId = personAccRTId
                                        , PersonMobilePhone ='1800 999 999');

        Id dealerRTId
            = Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Dealer').getRecordTypeId();
        Account dealer = new Account(Status__c = 'Customer'
                                     , Name = 'TestDealer' + date.Today()
                                     , RecordTypeId = dealerRTId
                                     , Phone ='(01) 8677 0993');
        try{
            insert personAcc;
            insert dealer;
        }
        catch(DMLException e){
            System.debug('Debug Output ======> {Error: ' + e + '}');
        }

        // Create a Finance Lead without 'Assigned Dealer'
        Id finLdRTId
            = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName()
              .get('Finance Lead').getRecordTypeId();
        Lead_Account__c finLead = new Lead_Account__c(Contact__c = personAcc.Id
                                      , Lead_Source__c = 'Web Form'
                                      , Nature_of_Request__c = 'General Enquiry'
                                      , Business_Unit__c = 'Cars'
                                      , Sub_BusinessUnit__c = 'Sales'
                                      , Lead_Status__c = 'New Enquiry');
        try{
            insert finLead;
        }
        catch(DMLException e){
            System.debug('Debug Output ======> {Error: ' + e + '}');
        }

        // Select a dealer for this lead by click the button 'Select Assigned Dealer'
        PageReference pr = new PageReference('/apex/SelectAssignedDealer?Id=' + finLead.Id);
        Test.setCurrentPage(pr);
        ExtSelectAssignedDealer selectDealer = new ExtSelectAssignedDealer(
            new ApexPages.StandardController(finLead));
        selectDealer.name = 'Beijing';
        selectDealer.dealer.Suburb__c = 'Beijing';
        selectDealer.dealer.Post_Code__c = '001010';
        selectDealer.dealer.Business_Unit__c = 'Fuso; smart';
        selectDealer.dealer.Cars_Offered_Service__c = 'Sales; Service';
        selectDealer.query();

        selectDealer.choosenDealerId = dealer.Id;
        selectDealer.lead.Id = null;
        selectDealer.choose();
        selectDealer.lead.Id = finLead.Id;
        selectDealer.choose();
    }
}