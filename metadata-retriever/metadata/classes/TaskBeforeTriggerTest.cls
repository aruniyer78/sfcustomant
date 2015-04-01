/*
    Type:       Test class of TaskBeforeTrigger 
    Purpose:    Test class of TaskBeforeTrigger 
    
    User Story: US_AU-CD-044
    Used By: 
    ---------------------------------------------------------------
    History:
    
    1. Shuang Li Created on 2014-02-19
*/
@isTest
public class TaskBeforeTriggerTest {
	public static testMethod void testTaskBeforeTrigger() {
		Id paid = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();        
        Account dms2 = new Account(
            LastName = 'Test-Customer2',
            Phone = '1234567', 
            FirstName = 'aa',
            Salutation = 'Attorney',
            Recordtypeid = paid 
        );
        insert dms2;

        Task t1 = new Task(
            recordtypeid =  Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Task').getRecordTypeId(),
            Subject = 'Welcome Call',
            WhatId = dms2.Id,
            WhoId = dms2.PersonContactId,
            Status = 'Open',
            ActivityDate = Date.today()
        );
        insert t1;
        Test.startTest();
        t1.Notification_Email_Flag__c = true;
        update t1;
        Test.stopTest();
	}
}