/*
    Type:       AddressHelper Test
    Purpose:    Test the class
    User Story: US_AU-CD-003
    ---------------------------------------------------------------
    History:

    1. Barney Lai created on 2013-08-12

*/
@isTest
public class AddressHelperTest {
    
    private static TestDataUtil testData = TestDataUtil.getInstance();
    
    @isTest static void testAddressHelper(){
        Account a1 = testData.standardPersonAccount;
        insert a1;
        Account a2 = a1.clone();
        insert a2;
        Account a3 = a1.clone();
        insert a3;
        
        String personAccountRTID = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        String companyRTID =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
    
        Address__c add1 = testData.standardAddress;
        add1.Customer__c = a1.Id;
        add1.RecordTypeId = personAccountRTID;
        
        Address__c add2_1 = add1.clone();
        add2_1.Customer__c = a2.Id;
        add2_1.Preferred__c = false;
        add2_1.Status__c = '';
        add2_1.Address_Type__c = 'Home';
        add2_1.RecordTypeId = personAccountRTID;
        
        Address__c add2_2 = add1.clone();
        add2_2.Customer__c = a2.Id;
        add2_2.Status__c = '';
        add2_2.RecordTypeId = personAccountRTID;
        
        Address__c add3_1 = add2_1.clone();
        add3_1.Customer__c = a3.Id;
        add3_1.Preferred__c = true;
        add3_1.RecordTypeId = companyRTID;
        
        Address__c add3_2 = add3_1.clone();
        add3_2.Address_Type__c = 'Company';
        add3_2.RecordTypeId = companyRTID;
        
        Address__c add3_3 = add3_2.clone();
        add3_3.Post_Code__c = '';
        add3_3.RecordTypeId = companyRTID;
        
        List<Address__c> addlist = new List<Address__c>();
        addlist.add(add1);
        addlist.add(add2_1);
        addlist.add(add2_2);
        addlist.add(add3_1);
        addlist.add(add3_2);
        addlist.add(add3_3);
        insert addlist;
        
        delete addlist;
    }
    
    @isTest static void testAutoFillPostCode() {
        String insertSuburb = 'B';
        String updateSuburb = 'C';
        Suburb_Zip_Mapping__c record = new Suburb_Zip_Mapping__c(Name = insertSuburb, Zip__c = '002');
        insert record;
        record = new Suburb_Zip_Mapping__c(Name = updateSuburb , Zip__c = '003');
        insert record;
        Account testAccount = testData.standardPersonAccount;
        insert testAccount;
        
        Address__c add = new Address__c(Customer__c = testAccount.id, Address_Line_1__c = 'addressline12', Suburb__c = insertSuburb,
                                         Address_Type__c = 'Home', Country__c = 'New Zeeland');
        insert add;
        
        //Test the update event for Address
        add.Suburb__c = updateSuburb;
        update add;
    }
}