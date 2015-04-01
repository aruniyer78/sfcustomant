/*
    Type:       AfterSales Controller Test
    Purpose:    Test the class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Bai Bing created on 2013-08-08

*/
@isTest(seeAllData=true)
private class AfterSalesHelperTest {

    private static TestDataUtil testData = TestDataUtil.getInstance();
    static Account customer1 = testData.standardPersonAccount;
                                    
    static testMethod void myUnitTest() {
        testUscd001And002();
    }
    
    static void testUscd001And002(){
        insert customer1;
        Vehicle__c car1 = new Vehicle__c(Name='xxxxxxxx01',Class__c='C-Class Sedan');
        Vehicle__c car2 = new Vehicle__c(Name='xxxxxxxx02',Class__c='CL-Class');
        Vehicle__c car3 = new Vehicle__c(Name='xxxxxxxx03',Class__c='Valente');
        Vehicle__c car4 = new Vehicle__c(Name='xxxxxxxx04',Class__c='Fighter');
        insert car1;
        system.debug([select id ,Vehicle_Group__c from Vehicle__c where id=:car1.id]);
        Aftersales__c record1 = new Aftersales__c(Service_Vehicle__c=car1.id );
        insert record1;
        
        customer1 = [select PC_Status__c from Account where id=:customer1.id];
        
        //system.assertEquals('Service Only',customer1.PC_Status__c);
        

        insert car4;
        insert car2;
        Customer_Vehicle_Relationship__c cvr = new Customer_Vehicle_Relationship__c(Customer__c=customer1.id,Vehicle_ID__c=car2.id);
        Contract contractPC = new Contract( AccountId = customer1.Id,
                                            StartDate = Date.Today(),
                                            ContractTerm = 18,
                                            Status = 'Draft',
                                            Vehicle__c = car2.Id);

        Customer_Vehicle_Relationship__c cvr1 = new Customer_Vehicle_Relationship__c(Customer__c=customer1.id,Vehicle_ID__c=car4.id);
        Contract contractPC1 = new Contract( AccountId = customer1.Id,
                                            StartDate = Date.Today(),
                                            ContractTerm = 18,
                                            Status = 'Draft',
                                            Vehicle__c = car4.Id);
        insert cvr;
        insert contractPC;
        insert cvr1;
        insert contractPC1;

        Aftersales__c record2 = new Aftersales__c(Service_Vehicle__c=car4.id );
        Aftersales__c record3 = new Aftersales__c(Service_Vehicle__c=car2.id );
        insert record2;
        insert record3;
        customer1 = [select CV_Status__c from Account where id=:customer1.id];
        
        //system.assertEquals('Service Only',customer1.CV_Status__c);
    }
}