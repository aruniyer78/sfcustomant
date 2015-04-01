/*
    Type:       Test Class
    Purpose:    Test the TaskMassChangeOwner class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Barney lai created on 2014-3-4
*/
@isTest(seeAllData=true)
public class TaskMassChangeOwnerTest{

    static testMethod void testTaskMassChangeOwner1(){

        Id welcomeCallRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Welcome Call').getRecordTypeId();
        Id paid = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();        
        
        Account personAccount1 = new Account(
            LastName = 'Test-Customer1',
            Phone = '1234567', 
            FirstName = 'aa',
            Salutation = 'Attorney',
            Recordtypeid = paid 
        );
        insert personAccount1;
        
        Task task1 = new Task(
            RecordTypeId = welcomeCallRT,
            WhatId = personAccount1.Id,
            WhoId = personAccount1.PersonContactId,
            Status = 'Open'
        );
        insert task1;
        
        User user1 = [select id from User where isActive = true limit 1];
        
        Test.startTest();
        PageReference taskMassChangeOwner = Page.TaskMassChangeOwner;
        taskMassChangeOwner.getParameters().put('objIds', task1.id);
        Test.setCurrentPage(taskMassChangeOwner);
        TaskMassChangeOwner controller = new TaskMassChangeOwner();
        controller.task.CROUser__c = user1.id;
        controller.assignToOwnerClick();
        task1 = [select id, ownerId from Task where id = :task1.id];
        System.assertEquals(task1.ownerId, user1.id); 
        Test.stopTest();
    }
    
    static testMethod void testTaskMassChangeOwner2(){

        Id welcomeCallRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Welcome Call').getRecordTypeId();
        Id paid = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();        
        
        Account personAccount1 = new Account(
            LastName = 'Test-Customer1',
            Phone = '1234567', 
            FirstName = 'aa',
            Salutation = 'Attorney',
            Recordtypeid = paid 
        );
        insert personAccount1;
        
        Task task1 = new Task(
            RecordTypeId = welcomeCallRT,
            WhatId = personAccount1.Id,
            WhoId = personAccount1.PersonContactId,
            Status = 'Open'
        );
        insert task1;
        
        Test.startTest();
        PageReference taskMassChangeOwner = Page.TaskMassChangeOwner;
        taskMassChangeOwner.getParameters().put('objIds', task1.id);
        Test.setCurrentPage(taskMassChangeOwner);
        TaskMassChangeOwner controller = new TaskMassChangeOwner();
        controller.assignToOwnerClick(); 
        Test.stopTest();
    }
}