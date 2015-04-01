/*
    Type:       test class
    Purpose:    CampaignMemberHistoryController test class
    User Story: CR-000151

    Used By:    CampaignMemberHistoryController
    ---------------------------------------------------------------
    History:

    2014-02-25 Shuang Li (Nttdata)    Created
*/
@isTest
public class CampaignMemberHistoryControllerTest {
	private static Id accDealer_RecordTypeId = 
                Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
    public static testMethod void testCampaignMemberHistoryController1(){
        Campaign cp = new Campaign(
                            Name = 'Campaign4InsertCampaignSharing',
                            Type = 'Other',
                            Campaign_Objective__c = 'test',
                            Description = 'test',
                            Status = 'Planned',
                            StartDate = Date.Today(),
                            EndDate = Date.Today(),
                            Brand__c = 'smart',
                            Frequency_Category__c = 'Daily');
        
        insert cp;
        Account dealeraccount1 = new Account( Name = 'nameAccount',
                                              Email__c = 'sichao.lai@nttdata.com',
                                              RecordTypeId = accDealer_RecordTypeId,
                                              Phone = '(01) 2334 3442',
                                              Dealer_Reason_for_Inactivation__c = 'Test');
        insert dealeraccount1;
        
        Contact contact1 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Email = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '60 Days Primary');
        insert contact1;
        // Campaign Member Initial
        CampaignMember cm1 = new CampaignMember(CampaignId = cp.Id,
                                                Status ='Sent',
                                                Lodgement_Date__c = Date.Today(),
                                                ContactId = contact1.Id
                                                );
        Test.startTest();
        insert cm1;
        ApexPages.standardController controller = new ApexPages.standardController(cm1);
        CampaignMemberHistoryController c1= new CampaignMemberHistoryController(controller);
        c1.getTheResults();
        Test.stopTest();
    }
}