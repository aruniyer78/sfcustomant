/*
    Type:       Test class of LeadHelper 
    Purpose:    Test class of LeadHelper 
    
    User Story: US_AU-Lead-013,US_AU-Lead-014,US_AU-Lead-015,US_AU-Lead-016,US_AU-Lead-017
    Used By: 
    ---------------------------------------------------------------
    History:
    
    28-Aug-2013 Barney Lai Created
    30-Aug-2013 Polaris Yu (BreakingPoint) Updated
*/

@isTest(seeAlldata=true)
public class LeadHelperTest {
    
    private static Id leadFinanceRT = 
        Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Finance Lead').getRecordTypeId();
    private static Id accDealer_RecordTypeId = 
                Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
    private static TestDataUtil testData = TestDataUtil.getInstance();
    
    public static testMethod void testcheckrecord() {
        Test.startTest();
        
        Account personaccount1 = testData.standardPersonAccount;
        insert personaccount1;
        
        Account dealeraccount1 = new Account( Name = 'nameAccount',
                                              Email__c = 'sichao.lai@nttdata.com',
                                              RecordTypeId = accDealer_RecordTypeId,
                                              Phone = '(01) 2334 3442',
                                              Dealer_Active__c = true,
                                              Dealer_Reason_for_Inactivation__c = 'Test');
        insert dealeraccount1;
        
        Contact contact1 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Email = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '60 Days Primary');
        
        insert contact1;
        Contact contact2 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Email = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '45 Days Primary');
        
        insert contact2;
        Contact contact3 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Email = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '45 Days CC');
        
        insert contact3;
        Contact contact4 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Email = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '20 Days Primary');
        
        insert contact4;
        Contact contact5 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Email = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '15 Days Primary');
        
        insert contact5;
        
        Contract contract1 = new Contract ( AccountId = personaccount1.Id,
                                            StartDate = Date.Today(),
                                            ContractTerm = 2,
                                            Status = 'Draft');
                                            
        insert contract1;
        Contract contract2 = new Contract ( AccountId = personaccount1.Id,
                                            StartDate = Date.Today()-15,
                                            ContractTerm = 2,
                                            Status = 'Draft');
                                            
        insert contract2;
        Contract contract3 = new Contract ( AccountId = personaccount1.Id,
                                            StartDate = Date.Today()-10,
                                            ContractTerm = 1,
                                            Status = 'Draft');
                                            
        insert contract3;
        Contract contract4 = new Contract ( AccountId = personaccount1.Id,
                                            StartDate = Date.Today()-15,
                                            ContractTerm = 1,
                                            Status = 'Draft');
                                            
        insert contract4;
        
        Lead_Account__c lead1 = new Lead_Account__c ( RecordTypeId = leadFinanceRT,
                                      Contact__c = personaccount1.id,
                                      Lead_Source__c = 'End of Contract',
                                      Nature_of_Request__c = 'Key2Key',
                                      Business_Unit__c = 'Cars',
                                      Sub_BusinessUnit__c = 'Sales',
                                      Lead_Status__c = 'New Enquiry',
                                      Assigned_Dealer__c = dealeraccount1.id,
                                      Existing_Contract__c = contract1.id,
                                      //Financial_Product__c = 'Agility Contract',
                                      Is_Finance_Send_Email_Before_60_Days__c = true);
                                      
        insert lead1;
        
        Lead_Account__c lead2 = new Lead_Account__c ( RecordTypeId = leadFinanceRT,
                                      Contact__c = personaccount1.id,
                                      Lead_Source__c = 'End of Contract',
                                      Nature_of_Request__c = 'Key2Key',
                                      Business_Unit__c = 'Cars',
                                      Sub_BusinessUnit__c = 'Sales',
                                      Lead_Status__c = 'New Enquiry',
                                      Assigned_Dealer__c = dealeraccount1.id,
                                      Existing_Contract__c = contract2.id
                                      //Financial_Product__c = 'Agility Contract',
                                      //Is_Finance_Send_Email_Before_45_Days__c = true
                                      );
                                      
        insert lead2;
        Lead_Account__c lead3 = new Lead_Account__c ( RecordTypeId = leadFinanceRT,
                                      Contact__c = personaccount1.id,
                                      Lead_Source__c = 'End of Contract',
                                      Nature_of_Request__c = 'Key2Key',
                                      Business_Unit__c = 'Cars',
                                      Sub_BusinessUnit__c = 'Sales',
                                      Lead_Status__c = 'New Enquiry',
                                      Assigned_Dealer__c = dealeraccount1.id,
                                      Existing_Contract__c = contract3.id,
                                      //Financial_Product__c = 'Agility Contract',
                                      Is_Finance_Send_Email_Before_20_Days__c = true);
                                      
        insert lead3;
        Lead_Account__c lead4 = new Lead_Account__c ( RecordTypeId = leadFinanceRT,
                                      Contact__c = personaccount1.id,
                                      Lead_Source__c = 'End of Contract',
                                      Nature_of_Request__c = 'Key2Key',
                                      Business_Unit__c = 'Cars',
                                      Sub_BusinessUnit__c = 'Sales',
                                      Lead_Status__c = 'New Enquiry',
                                      Assigned_Dealer__c = dealeraccount1.id,
                                      Existing_Contract__c = contract4.id,
                                      //Financial_Product__c = 'Agility Contract',
                                      Is_Finance_Send_Email_Before_15_Days__c = true,
                                      Vehicle_Make_Current__c = '111',
                                      Vehicle_Model_Current__c = 'bb',
                                      Vehicle_Year_Current__c = '2009');
                                      
        insert lead4;
        Test.stopTest();
    }

    // Added by Polaris Yu 2013-8-30; Test codes for method:
    //  emailToLdEscltRcps and method: autoAssignLeads in class LeadHelper.cls
    public static testMethod void testEmailToLdEscltRcps() {
        // Create a Person Account, a Company Account & a Dealer Account
        // Person Account
        Account personAcc = testData.standardPersonAccount;

        // Company Account
        Id comAccRTId
            = Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Company').getRecordTypeId();
        Account comAcc = new Account(Status__c = 'Customer'
                                     , Name = 'TestCompany-' + date.Today()
                                     , RecordTypeId = comAccRTId
                                     , Phone ='(01) 8677 0887'); 

        // Dealer Account
        Id dealerRTId
            = Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Dealer').getRecordTypeId();

            List<Account> accInsertList = new List<Account>();
            //insert personAcc;
            insert comAcc;
            Account dealer = new Account(Status__c = 'Customer'
                                     , Name = 'TestDealer' + date.Today()
                                     , RecordTypeId = dealerRTId
                                     , Phone ='(01) 8677 0993'
                                     , Dealer_Active__c = true
                                     , Inactivation_Date__c = date.Today().addDays(100)
                                     , Dealer_Reason_for_Inactivation__c = 'Test Record');
        accInsertList.add(dealer);
        // Insert the accounts
        try{
            insert accInsertList;
        }
        catch(DMLException e){
            System.debug('Debug Output ======> {Error: ' + e + '}');
        }


        List<Contact> cnttList = new List<Contact>();
        // Create a '24H Untouched Notice', a '72H Untouched Notice' and a both
        //    '24H Untouched Notice' and '72H Untouched Notice' dealer contact
        //    on the dealer account
        Contact x24Cntt
            = new Contact(AccountId = dealer.Id
                          , LastName = 'Test'
                          , FirstName = '24H_1'
                          , Email = 'test@test.com'
                          , Business_Unit__c = 'Cars; Vans'
                          , Sub_BusinessUnit__c = 'Sales; Service'
                          , Lead_Escalation_Recipient_Type__c = '24H Untouched Notice');
        cnttList.add(x24Cntt);
        Contact x2472Cntt
            = new Contact(AccountId = dealer.Id
                          , LastName = 'Test'
                          , FirstName = '24H/72H'
                          , Email = 'test@test.com'
                          , Business_Unit__c = 'Cars; Vans'
                          , Sub_BusinessUnit__c = 'Sales; Service'
                          , Lead_Escalation_Recipient_Type__c 
                                = '24H Untouched Notice; 72H Untouched Notice');
        cnttList.add(x2472Cntt);
        Contact x72Cntt
            = new Contact(AccountId = dealer.Id
                          , LastName = 'Test'
                          , FirstName = '72H'
                          , Email = 'test@test.com'
                          , Business_Unit__c = 'Cars; Vans'
                          , Sub_BusinessUnit__c = 'Sales; Service'
                          , Lead_Escalation_Recipient_Type__c = '72H Untouched Notice');
        cnttList.add(x72Cntt);
        try{
            insert cnttList;
        }
        catch(DMLException e){
            System.debug('Debug Output ======> {Error: ' + e + '}');
        }

        // Create a Service/Parts Lead, lookup the person account, the company
        //    account and the dealer account just created
        Id spRTId
            = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName()
              .get('Service/Parts Lead').getRecordTypeId();
        Lead_Account__c spLd = new Lead_Account__c(RecordTypeId = spRTId
                                   , Contact__c = personAcc.Id
                                   , Company_Account__c = comAcc.Id
                                   , Lead_Source__c = 'Web Form'
                                   , Sub_Source__c = 'Contact Us'
                                   , Nature_of_Request__c = 'Brochure Request'
                                   , Business_Unit__c = 'Cars'
                                   , Sub_BusinessUnit__c = 'Sales'
                                   , Lead_Status__c = 'New Enquiry'
                                   );
        //try{
            insert spLd;
        //}
        //catch(DMLException e){
        //    System.debug('Debug Output ======> {Error: ' + e + '}');
        //}

        // Check the '*24H Untouched' field on the newly created lead
        spLd.X24H_Untouched__c = true;
        //try{
            update spLd;
        //}
        //catch(DMLException e){
        //    System.debug('Debug Output ======> {Error: ' + e + '}');
        //}

        // Check the '*72H Untouched' field on the newly created lead
        spLd.X72H_Untouched__c = true;
        //try{
            update spLd;
        //}
        //catch(DMLException e){
         //   System.debug('Debug Output ======> {Error: ' + e + '}');
        //}
    }

    // Added by Polaris Yu 2013-8-30; Test codes for method:
    //  autoFillAssignedDealer in class LeadHelper.cls
    public static testMethod void testAutoFillAssignedDealer() {
        // Create a Person Account and a Dealer Account
        List<Account> accInsertList = new List<Account>();
        Account personAcc = testData.standardPersonAccount;
        accInsertList.add(personAcc);

        Id dealerRTId
            = Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Dealer').getRecordTypeId();
        Account dealer = new Account(Status__c = 'Customer'
                                     , Name = 'TestDealer' + date.Today()
                                     , RecordTypeId = dealerRTId
                                     , Phone ='(01) 8677 0993'
                                     , Dealer_Active__c = true
                                     , Inactivation_Date__c = date.Today().addDays(100)
                                     , Dealer_Reason_for_Inactivation__c = 'Test Record');
        accInsertList.add(dealer);
        // Insert the accounts
        //try{
            insert accInsertList;
        //}
        //catch(DMLException e){
        //    System.debug('Debug Output ======> {Error: ' + e + '}');
        //}
        Contact contact1 = new Contact ( AccountId =dealer.Id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Email = 'sichao.lai@nttdata.com',
                                          Lead_Escalation_Recipient_Type__c = 'Immediate Notice'
                                          , Dealer_Sales_Gate_Keeper__c = false,
                                         EOC_Recipient_Type__c = '60 Days Primary');
        
        insert contact1;
        
        Profile pro = [select Id from Profile where Name = 'System Administrator'];
        
        User userWithRoleAdd = new User(alias = 'hasrole', email='userwithrole@roletest1.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = Pro.Id,
        timezonesidkey='America/Los_Angeles', username='userwithroleAdd@testorg.com');
        insert userwithroleAdd;
        // Construct a non-fleet contract
        Contract finCntrct = new Contract(Status = 'Draft'
                                          , StartDate = date.Today().addDays(30)
                                          , ContractTerm = 3
                                          , AccountId = personAcc.Id
                                          , Dealer_Name__c = dealer.Id);
        // Insert the contracts
        //try{
            insert finCntrct;
        //}
        //catch(DMLException e){
        //    System.debug('Debug Output ======> {Error: ' + e + '}');
        //}
        // Contruct a finance lead
        Lead_Account__c finld = new Lead_Account__c(RecordTypeId = leadFinanceRT
                                   , Contact__c = personAcc.Id
                                   , Lead_Source__c = 'Web Form'
                                   , Sub_Source__c = 'Contact Us'
                                   , Nature_of_Request__c = 'Brochure Request'
                                   , Business_Unit__c = 'Cars'
                                   , Sub_BusinessUnit__c = 'Sales'
                                   , Lead_Status__c = 'Qualified'
                                   
                                   , Existing_Contract__c = finCntrct.Id);
        //try{
            insert finld;
        //}
        //catch(DMLException e){
        //    System.debug('Debug Output ======> {Error: ' + e + '}');
        //}        
    }
     public static testMethod void testSendServicePartsEmail() {
        Id spRTId = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Service/Parts Lead').getRecordTypeId();
        Account personAcc = testData.standardPersonAccount;
        insert personAcc;
        // Company Account
        Id comAccRTId
            = Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Company').getRecordTypeId();
        Account comAcc = new Account(Status__c = 'Customer'
                                     , Name = 'TestCompany-' + date.Today()
                                     , RecordTypeId = comAccRTId
                                     , Phone ='(01) 8677 0887'); 
        insert comAcc;
        Lead_Account__c spLd = new Lead_Account__c(RecordTypeId = spRTId
                                   , Contact__c = personAcc.Id
                                   , Company_Account__c = comAcc.Id
                                   , Lead_Source__c = 'Web Form'
                                   , Sub_Source__c = 'Contact Us'
                                   , Nature_of_Request__c = 'Brochure Request'
                                   , Business_Unit__c = 'Cars'
                                   , Sub_BusinessUnit__c = 'Sales'
                                   , Lead_Status__c = 'New Enquiry'
                                   ,Is_Finance_Send_Email_Before_60_Days__c = true
                                   );
         insert spLd;
         Account dealeraccount1 = new Account( Name = 'nameAccount',
                                              Email__c = 'shuang.li@nttdata.com',
                                              RecordTypeId = accDealer_RecordTypeId,
                                              Phone = '(01) 2334 3442',
                                              Dealer_Active__c = true,
                                              Dealer_Reason_for_Inactivation__c = 'Test');
        insert dealeraccount1;
        
        Contact contact1 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Business_Unit__c = 'Cars; Vans',
                                         Sub_BusinessUnit__c = 'Sales; Service',
                                         Lead_Escalation_Recipient_Type__c = 'Immediate Notice;24H Untouched Notice;72H Untouched Notice',
                                         Email = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '60 Days Primary');
        
        insert contact1;
        Contact contact2 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Email = 'sichao.lai@nttdata.com',
                                         Business_Unit__c = 'Cars; Vans',
                                         Sub_BusinessUnit__c = 'Sales; Service',
                                         Lead_Escalation_Recipient_Type__c = 'CC Lead Escalation Recipient',
                                         EOC_Recipient_Type__c = '60 Days CC');
       insert contact2;
       MBAuP_Contact__c mbcontact1 = new MBAuP_Contact__c ( Dealer_Name__c = dealeraccount1.id,
                                         First_Name__c = 'lai',
                                         Business_Unit__c = 'Cars; Vans',
                                         Sub_Business_Unit__c = 'Sales; Service',
                                         Lead_Escalation_Recipient_Type__c = 'Immediate Notice;24H Untouched Notice;72H Untouched Notice',
                                         Email_Address__c = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '60 Days Primary');
        
        insert mbcontact1;
        MBAuP_Contact__c mbcontact2 = new MBAuP_Contact__c ( Dealer_Name__c = dealeraccount1.id,
                                         First_Name__c = 'lai',
                                         Business_Unit__c = 'Cars; Vans',
                                         Sub_Business_Unit__c = 'Sales; Service',
                                         Lead_Escalation_Recipient_Type__c = 'CC Lead Escalation Recipient',
                                         Email_Address__c = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '60 Days Primary');
        
        insert mbcontact2;
       
       spLd.Assigned_Dealer__c = dealeraccount1.id;
       update spLd;
        
     }
     public static testMethod void testSendFinanceEmail() {
        Id spRTId = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Finance Lead').getRecordTypeId();
        Account personAcc = testData.standardPersonAccount;
        insert personAcc;
        // Company Account
        Id comAccRTId
            = Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Company').getRecordTypeId();
        Account comAcc = new Account(Status__c = 'Customer'
                                     , Name = 'TestCompany-' + date.Today()
                                     , RecordTypeId = comAccRTId
                                     , Phone ='(01) 8677 0887'); 
        insert comAcc;
        Lead_Account__c spLd = new Lead_Account__c(RecordTypeId = spRTId
                                   , Contact__c = personAcc.Id
                                   , Company_Account__c = comAcc.Id
                                   , Lead_Source__c = 'Web Form'
                                   , Sub_Source__c = 'Contact Us'
                                   , Nature_of_Request__c = 'Brochure Request'
                                   , Business_Unit__c = 'Cars'
                                   , Sub_BusinessUnit__c = 'Sales'
                                   , Lead_Status__c = 'New Enquiry'
                                   ,Is_Finance_Send_Email_Before_60_Days__c = true
                                   );
         insert spLd;
         Account dealeraccount1 = new Account( Name = 'nameAccount',
                                              Email__c = 'shuang.li@nttdata.com',
                                              RecordTypeId = accDealer_RecordTypeId,
                                              Phone = '(01) 2334 3442',
                                              Dealer_Active__c = true,
                                              Dealer_Reason_for_Inactivation__c = 'Test');
        insert dealeraccount1;
        
        Contact contact1 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Business_Unit__c = 'Cars; Vans',
                                         Finance_Lead_Type__c = 'Brochure Request',
                                         Sub_BusinessUnit__c = 'Sales; Service',
                                         Lead_Escalation_Recipient_Type__c = 'Immediate Notice;24H Untouched Notice;72H Untouched Notice',
                                         Email = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '60 Days Primary');
        
        insert contact1;
        Contact contact2 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Email = 'sichao.lai@nttdata.com',
                                         Finance_Lead_Type__c = 'Brochure Request',
                                         Business_Unit__c = 'Cars; Vans',
                                         Sub_BusinessUnit__c = 'Sales; Service',
                                         Lead_Escalation_Recipient_Type__c = 'CC Lead Escalation Recipient',
                                         EOC_Recipient_Type__c = '60 Days CC');
       insert contact2;
       MBAuP_Contact__c mbcontact1 = new MBAuP_Contact__c ( Dealer_Name__c = dealeraccount1.id,
                                         First_Name__c = 'lai',
                                         Business_Unit__c = 'Cars; Vans',
                                         Sub_Business_Unit__c = 'Sales; Service',
                                         Finance_Lead_Type__c = 'Brochure Request',
                                         Lead_Escalation_Recipient_Type__c = 'Immediate Notice;24H Untouched Notice;72H Untouched Notice',
                                         Email_Address__c = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '60 Days Primary');
        
        insert mbcontact1;
        MBAuP_Contact__c mbcontact2 = new MBAuP_Contact__c ( Dealer_Name__c = dealeraccount1.id,
                                         First_Name__c = 'lai',
                                         Business_Unit__c = 'Cars; Vans',
                                         Sub_Business_Unit__c = 'Sales; Service',
                                         Finance_Lead_Type__c = 'Brochure Request',
                                         Lead_Escalation_Recipient_Type__c = 'CC Lead Escalation Recipient',
                                         Email_Address__c = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '60 Days Primary');
        
        insert mbcontact2;
       
       spLd.Assigned_Dealer__c = dealeraccount1.id;
       update spLd;
     }
     
     public static testMethod void testCopyContractNumber() {
        
        Id comAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id fleetRTId = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Fleet Lead').getRecordTypeId();
        Account comAcc = new Account(Status__c = 'Customer'
                                     , Name = 'TestCompany-' + date.Today()
                                     , RecordTypeId = comAccRTId
                                     , Phone ='(01) 8677 0887');
        insert comAcc; 
        
        Contract contr = new Contract();
        contr.Contract_Id__c = 'acme1234';
        contr.AccountId = comAcc.Id;
        insert contr;
        
        Lead_Account__c fleetLd = new Lead_Account__c(RecordTypeId = fleetRTId
                                   , Company_Account__c = comAcc.Id
                                   , Lead_Source__c = 'Web Form'
                                   , CMS_Contract_Number__c = 'acme1234'
                                   , Sub_Source__c = 'Contact Us'
                                   , Nature_of_Request__c = 'Brochure Request'
                                   , Business_Unit__c = 'Cars'
                                   , Sub_BusinessUnit__c = 'Sales'
                                   , Lead_Status__c = 'New Enquiry'
                                   );
         insert fleetLd;
         
         fleetLd = new Lead_Account__c(RecordTypeId = fleetRTId
                                   , Company_Account__c = comAcc.Id
                                   , Lead_Source__c = 'Web Form'
                                   , CMS_Contract_Number__c = 'acme12345'
                                   , Sub_Source__c = 'Contact Us'
                                   , Nature_of_Request__c = 'Brochure Request'
                                   , Business_Unit__c = 'Cars'
                                   , Sub_BusinessUnit__c = 'Sales'
                                   , Lead_Status__c = 'New Enquiry'
                                   );
         try{                         
             insert fleetLd;
         }catch(exception ex) {}
     }
}