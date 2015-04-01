/*
    Type:       Test Class
    Purpose:    Test the TaskMassChangeActivateDeactive class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Barney lai created on 2014-3-4
*/
@isTest(seeAllData=true)
public class TaskMassChangeActivateDeactiveTest {

    static testMethod void testTaskMassChangeActivateDeactive1(){

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
        
        User usr = [select id, Active_Inactive_Flag__c from User where isActive = true limit 1];
        
        task1.ownerId = usr.id;
        update task1;
        
        Test.startTest();
        PageReference taskMassChangeActivateDeactive = Page.TaskMassChangeActivateDeactive;
        taskMassChangeActivateDeactive.getParameters().put('objIds', task1.id);
        Test.setCurrentPage(taskMassChangeActivateDeactive);
        TaskMassChangeActivateDeactive controller = new TaskMassChangeActivateDeactive();
        controller.task = task1;
        controller.Activate();
        usr = [select id, Active_Inactive_Flag__c from User where id = :usr.id];
        System.assertEquals(usr.Active_Inactive_Flag__c, true);
        controller.Deactivate();
        usr = [select id, Active_Inactive_Flag__c from User where id = :usr.id];
        System.assertEquals(usr.Active_Inactive_Flag__c, false); 
        Test.stopTest();
    }
    
    static testMethod void testTaskMassChangeActivateDeactive2(){

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
        
        User usr = [select id, Active_Inactive_Flag__c from User where isActive = true limit 1];
        
        task1.ownerId = usr.id;
        update task1;
        
        Test.startTest();
        PageReference taskMassChangeActivateDeactive = Page.TaskMassChangeActivateDeactive;
        taskMassChangeActivateDeactive.getParameters().put('objIds', task1.id);
        Test.setCurrentPage(taskMassChangeActivateDeactive);
        TaskMassChangeActivateDeactive controller = new TaskMassChangeActivateDeactive();
        controller.Activate();
        controller.Deactivate(); 
        Test.stopTest();
    }
}