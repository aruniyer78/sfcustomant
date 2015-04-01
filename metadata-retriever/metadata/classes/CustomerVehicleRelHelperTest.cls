/*
    Type:       Test class
    Purpose:    Test the CustomerDealerRelHelper class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Bai Bing created on 2013-08-20
*/
@isTest(seeAllData=true)
private class CustomerVehicleRelHelperTest {

    private static TestDataUtil testData = TestDataUtil.getInstance();
    private static Account customer1 = testData.standardPersonAccount;
    
    static testMethod void myUnitTest() {
        insert customer1;
        Vehicle__c car1 = new Vehicle__c(Name='xxxxxxxx01',Class__c='C-Class Sedan');
        Vehicle__c car2 = new Vehicle__c(Name='xxxxxxxx02',Class__c='CL-Class');
        Vehicle__c car3 = new Vehicle__c(Name='xxxxxxxx03',Class__c='Valente');
        Vehicle__c car4 = new Vehicle__c(Name='xxxxxxxx04',Class__c='Fighter');
        insert car1;
        Customer_Vehicle_Relationship__c cvr = new Customer_Vehicle_Relationship__c(Customer__c=customer1.id,Vehicle_ID__c=car1.id);
        insert cvr;
        
        customer1 = [select id, PC_Status__c, CV_Status__c,PC_Tenure__c,CV_Tenure__c, PC_No_Brand_Purchases__c,
                    CV_No_Brand_Purchases__c from Account where Id = :customer1.id];
        
        /*System.assertEquals(customer1.PC_Status__c,'Customer');
        System.assertEquals(customer1.PC_Tenure__c,0);
        System.assertEquals(customer1.PC_No_Brand_Purchases__c,1);*/

        insert car2;
        cvr = new Customer_Vehicle_Relationship__c(Customer__c=customer1.id,Vehicle_ID__c=car2.id);
        insert cvr;

        customer1 = [select id, PC_Status__c, CV_Status__c,PC_Tenure__c,CV_Tenure__c, PC_No_Brand_Purchases__c,
                    CV_No_Brand_Purchases__c from Account where Id = :customer1.id];
                            
        /*System.assertEquals(customer1.PC_Status__c,'Customer');
        System.assertEquals(customer1.PC_Tenure__c,0);
        System.assertEquals(customer1.PC_No_Brand_Purchases__c,2);*/

        insert car3;
        cvr = new Customer_Vehicle_Relationship__c(Customer__c=customer1.id,Vehicle_ID__c=car3.id);
        insert cvr;

        customer1 = [select id, VAN_Status__c,VAN_Tenure__c,
                    VAN_No_Brand_Purchases__c from Account where Id = :customer1.id];
                            
        /*System.assertEquals(customer1.VAN_Status__c,'Customer');
        System.assertEquals(customer1.VAN_Tenure__c,0);
        System.assertEquals(customer1.VAN_No_Brand_Purchases__c,1);*/
        

        cvr = new Customer_Vehicle_Relationship__c(Customer__c=customer1.id);
        
        try{
            insert cvr;
        }catch(DMLException e){
            //system.assertEquals('Please select the vehicle Id !',e.getDmlMessage(0));
        }
    }
}