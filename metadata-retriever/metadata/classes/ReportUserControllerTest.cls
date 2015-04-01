/*
    Type:       ReportUserController Test
    Purpose:    Test the class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Shuang Li created on 2013-09-13

*/
@isTest
public class ReportUserControllerTest {

    @isTest
    public static void testReportUserController(){
        
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        Profile pro = [select Id from Profile where Name = 'System Administrator'];
        
        User userWithRoleAdd = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = Pro.Id,
        timezonesidkey='America/Los_Angeles', username='userwithroleAdd@testorg.com');
        
        User userWithRoleMod = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = Pro.Id,
        timezonesidkey='America/Los_Angeles', username='userwithroleMod@testorg.com');
        insert userWithRoleAdd;
        insert userWithRoleMod;
        TestDataUtil testData = TestDataUtil.getInstance();
    	Account customer1 = testData.standardPersonAccount;
        Vehicle__c car1 = new Vehicle__c(Name='xxxxxxxx01', Class__c='C-Class Sedan');
        Vehicle__c car2 = new Vehicle__c(Name='xxxxxxxx02', Class__c='CL-Class');
        Task task1 = new Task(ActivityDate = Date.today(), CallDisposition = 'Contact left a message1', CallType = 'Inbound', Description = 'aa', Status = 'Completed', Subject = 'Phone Message from ', Type = 'Call');
        Task task2 = new Task(ActivityDate = Date.today(), CallDisposition = 'Contact left a message2', CallType = 'Inbound', Description = 'aab', Status = 'Completed', Subject = 'Phone Message from1 ', Type = 'Call');

        System.runAs(userWithRoleAdd) {
            insert task1;
            insert task2;
            insert customer1;
            insert car1;
            insert car2;
            Customer_Vehicle_Relationship__c cvr1 = new Customer_Vehicle_Relationship__c(Customer__c=customer1.id,Vehicle_ID__c=car1.id);
            Customer_Vehicle_Relationship__c cvr2 = new Customer_Vehicle_Relationship__c(Customer__c=customer1.id,Vehicle_ID__c=car2.id);
            insert cvr1;
            insert cvr2;
        }
        System.runAs(userWithRoleMod) {
            update customer1;
            Customer_Vehicle_Relationship__c cvr3 = new Customer_Vehicle_Relationship__c(Customer__c=customer1.id,Vehicle_ID__c=car1.id);
            Customer_Vehicle_Relationship__c cvr4 = new Customer_Vehicle_Relationship__c(Customer__c=customer1.id,Vehicle_ID__c=car2.id);
            insert cvr3;
            insert cvr4;
            update cvr3;
            update task2;
        }
        
        
        ReportUserController controller = new ReportUserController();
        controller.getTheResults();
        for ( integer i=0;i< controller.theResults.size();i++){   
            if(userWithRoleAdd.Id == controller.theResults.get(i).UserId){
               System.assertEquals(1, controller.theResults.get(i).totalAccountAdd);
               System.assertEquals(0, controller.theResults.get(i).totalAccountMod);
               System.assertEquals(2, controller.theResults.get(i).totalTasksAdd);
               System.assertEquals(1, controller.theResults.get(i).totalTasksMod);
               System.assertEquals(2, controller.theResults.get(i).totalVehicleAdd);
               System.assertEquals(2, controller.theResults.get(i).totalVehicleMod);
            }else if(userWithRoleMod.Id == controller.theResults.get(i).UserId){
               System.assertEquals(0, controller.theResults.get(i).totalAccountAdd);
               System.assertEquals(1, controller.theResults.get(i).totalAccountMod);
               System.assertEquals(0, controller.theResults.get(i).totalTasksAdd);
               System.assertEquals(1, controller.theResults.get(i).totalTasksMod);
               System.assertEquals(2, controller.theResults.get(i).totalVehicleAdd);
               System.assertEquals(2, controller.theResults.get(i).totalVehicleMod);
            
            }          
        }
    }
}