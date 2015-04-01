/*
    Type:       Test class
    Purpose:    Test the CustomerDealerRelHelper class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Justin Yu created on 2013-08-28
*/
@isTest
public with sharing class CustomerDealerRelHelperTest {
    
    @isTest
    public static void testPreventRelationshipSaving(){
        
        String companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        String dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        
        Account company = new Account(
                Name = 'Company',
                Title__c = 'Title', 
                Phone = '(01) 2345 4422', 
                Address_Line_1__c = 'addressline1', 
                Suburb__c = 'suburb',
                RecordTypeId = companyRecordTypeId
        );
        insert company;
        
        Account dealer = new Account(
            Name = 'Dealer',
            Title__c = 'Title', 
            Phone = '(01) 2345 4422', 
            Address_Line_1__c = 'addressline1', 
            Suburb__c = 'suburb',
            RecordTypeId = dealerRecordTypeId,
            Dealer_Reason_for_Inactivation__c = 'Reason1'
        );
        insert dealer;
        
        Customer_Dealer_Relationship__c noTypeRel = new Customer_Dealer_Relationship__c();
        noTypeRel.Dealer__c = dealer.Id;
        noTypeRel.Customer__c = company.Id;
        
        Customer_Dealer_Relationship__c serviceRel1 = new Customer_Dealer_Relationship__c();
        serviceRel1.Dealer__c = dealer.Id;
        serviceRel1.Customer__c = company.Id;
        serviceRel1.Type__c = 'Service';
        
        Customer_Dealer_Relationship__c serviceRel2 = new Customer_Dealer_Relationship__c();
        serviceRel2.Dealer__c = dealer.Id;
        serviceRel2.Customer__c = company.Id;
        serviceRel2.Type__c = 'Service';
        
        Customer_Dealer_Relationship__c customerRel = new Customer_Dealer_Relationship__c();
        customerRel.Dealer__c = dealer.Id;
        customerRel.Customer__c = company.Id;
        customerRel.Type__c = 'Customer';

        Customer_Dealer_Relationship__c prospectRel = new Customer_Dealer_Relationship__c();
        prospectRel.Dealer__c = dealer.Id;
        prospectRel.Customer__c = company.Id;
        prospectRel.Type__c = 'Prospect';
        
        Customer_Dealer_Relationship__c prospectRel2 = new Customer_Dealer_Relationship__c();
        prospectRel2.Dealer__c = dealer.Id;
        prospectRel2.Customer__c = company.Id;
        prospectRel2.Type__c = 'Prospect';
        
        
        insert prospectRel;
        try{
            insert noTypeRel;
        }catch(DMLException e){
            system.assertEquals('The imported relationship has no type',e.getDmlMessage(0));
        }

        insert serviceRel1;
        List<Customer_Dealer_Relationship__c> customer1 = [select Dealer__c, Customer__c, Type__c from Customer_Dealer_Relationship__c where Dealer__c = :dealer.Id and Customer__c = :company.Id order by id];
        /*System.assertEquals(customer1.size(),1);
        System.assertEquals(customer1.get(0).Type__c,'Service');*/
        
        insert prospectRel2;
        List<Customer_Dealer_Relationship__c> customer4 = [select Dealer__c, Customer__c, Type__c from Customer_Dealer_Relationship__c where Dealer__c = :dealer.Id and Customer__c = :company.Id order by id];
        /*System.assertEquals(customer4.size(),1);
        System.assertEquals(customer4.get(0).Type__c,'Service');*/

        insert customerRel;
        List<Customer_Dealer_Relationship__c> customer3 = [select id ,Dealer__c, Customer__c, Type__c from Customer_Dealer_Relationship__c where Dealer__c = :dealer.Id and Customer__c = :company.Id order by id];
        /*System.assertEquals(customer3.size(),1);
        System.assertEquals(customer3.get(0).Type__c,'Customer');*/

        insert serviceRel2;
        List<Customer_Dealer_Relationship__c> customer2 = [select id ,Dealer__c, Customer__c, Type__c from Customer_Dealer_Relationship__c where Dealer__c = :dealer.Id and Customer__c = :company.Id order by id];
        /*System.assertEquals(customer2.size(),1);
        System.assertEquals(customer2.get(0).Type__c,'Customer');*/
    }
}