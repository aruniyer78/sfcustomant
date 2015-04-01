/*
    Type:       Test class of TriggerCampaignMember 
    Purpose:    Test class of TriggerCampaignMember 
    
    User Story: CR-000151
    Used By: 
    ---------------------------------------------------------------
    History:
    
    1. Shuang Li Created on 2014-02-25
*/
@isTest
public class TriggerCampaignMemberTest {
	private static Id accDealer_RecordTypeId = 
                Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
	public static testMethod void testTaskBeforeTrigger() {
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
        List<Campaign_Member_History__c> cmhs = [Select Action__c, Date_of_Change__c, User__r.Name From Campaign_Member_History__c Where CampaignMember__c  = :cm1.id];        
        for (Campaign_Member_History__c cmh : cmhs){
        system.assertEquals(cmh.Action__c,'Created.');
        }
        cm1.Status= 'Responded';
        cm1.Lodgement_Date__c= Date.Today().addDays(1);
        update cm1;
        delete cm1;
	}
}