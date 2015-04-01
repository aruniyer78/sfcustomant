/*
    Type:       Test class of ContractHelper 
    Purpose:    Test class of ContractHelper 
    
    User Story: US-CD-001
    Used By: 
    ---------------------------------------------------------------
    History:
    
    12-Aug-2013 Chaos (NTTData)  Created
    26-Aug-2013 Polaris Yu (BreakingPoint) Updated
*/     
@isTest(seeAlldata=true)
public class ContractHelperTest {

    private static TestDataUtil testData = TestDataUtil.getInstance();

    public static testMethod void testUpdateWhenCreateCCR() {
        
        Account normalAcc = testData.standardPersonAccount;
        insert normalAcc;
        Account accountPC = normalAcc.clone();
        accountPC.LastName = 'lastnamePC';
        Account accountCV = normalAcc.clone();
        accountCV.LastName = 'lastnameCV';
        insert accountPC;
        insert accountCV;
        
        Vehicle__c carPC = new Vehicle__c( Name='NamePC',
                                            Class__c = 'C-Class Sedan'
                                            );
        Vehicle__c carCV = new Vehicle__c( Name='NameCV',
                                            Class__c = 'Columbia'
                                            );
        Vehicle__c carVAN = new Vehicle__c( Name='NameCV',
                                            Class__c = 'Valente'
                                            );
        insert carPC;
        insert carCV;
        insert carVAN;

        // Branch 1 (Vehicle : PC , PC_Status : '') 
        Contract contractPC = new Contract( StartDate = Date.Today(),
                                            ContractTerm = 18,
                                            AccountId = accountPC.Id,
                                            Vehicle__c = carPC.Id);
        insert contractPC;
        
        // Get the latest Account info
        accountPC = [select Id, PC_Status__c, CV_Status__c, Status__c from Account where Id = :accountPC.id];
        
        // Validate
        
        /*System.assertEquals(accountPC.PC_Status__c, 'Customer');
        System.assertEquals(accountPC.CV_Status__c, 'Prospect');*/
      
        // Branch 2 (Vehicle : PC , PC_Status : Customer) 
        Contract customerContractPC = new Contract( StartDate = Date.Today(),
                                            ContractTerm = 18,
                                            AccountId = accountPC.Id,
                                            Vehicle__c = carPC.Id);
        insert customerContractPC;
        
        // Get the latest Account info
        accountPC = [select Id, PC_Status__c, CV_Status__c, Status__c from Account where Id = :accountPC.id];
        
        /*System.assertEquals(accountPC.PC_Status__c, 'Customer');
        System.assertEquals(accountPC.CV_Status__c, 'Prospect');*/
      
        // Branch 3 (Vehicle : CV , CV_Status : '') 
        Contract contractCV = new Contract( StartDate = Date.Today(),
                                            ContractTerm = 18,
                                            AccountId = accountCV.Id,
                                            Vehicle__c = carCV.Id);
        insert contractCV;
        
        // Get the latest Account info
        accountCV = [select Id, PC_Status__c, CV_Status__c, Status__c from Account where Id = :accountCV.id];
        
        /*System.assertEquals(accountCV.CV_Status__c, 'Customer');
        System.assertEquals(accountCV.PC_Status__c, 'Prospect');*/
      
        // Branch 4 (Vehicle : CV , CV_Status : Customer) 
        Contract customerContractCV = new Contract( StartDate = Date.Today(),
                                            ContractTerm = 18,
                                            AccountId = accountCV.Id,
                                            Vehicle__c = carCV.Id);
        insert customerContractCV;
        
        // Get the latest Account info
        accountCV = [select Id, PC_Status__c, CV_Status__c, Status__c from Account where Id = :accountCV.id];
        
        /*System.assertEquals(accountCV.CV_Status__c, 'Customer');
        System.assertEquals(accountCV.PC_Status__c, 'Prospect');*/

        // Branch 5 (Vehicle : VAN , VAN_Status : Customer) 
        Contract customerContractVAN = new Contract( StartDate = Date.Today(),
                                            ContractTerm = 18,
                                            AccountId = accountCV.Id,
                                            Vehicle__c = carVAN.Id);
        insert customerContractVAN;
        
        // Get the latest Account info
        accountCV = [select Id, VAN_Status__c,PC_Status__c, CV_Status__c, Status__c from Account where Id = :accountCV.id];
        
        //System.assertEquals(accountCV.VAN_Status__c, 'Customer');
    }

    // Added by Polaris Yu 2013-8-26; Test codes for autoCreateLeads 
    //    method in ContractHelper.cls 
    public static testMethod void testAutoCreateLeads(){
        // Create a Person Account, a company account and a Dealer Account
        List<Account> accInsertList = new List<Account>();
        Account personAcc = testData.standardPersonAccount;
        accInsertList.add(personAcc);

        Id companyRTId
            = Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Company').getRecordTypeId();
        Account companyAcc = new Account(Status__c = 'Customer'
                                         , Name = 'TestCompany' + date.Today()
                                         , RecordTypeId = companyRTId
                                         , Phone ='(01) 8677 0993');
        accInsertList.add(companyAcc);

        Id dealerRTId
            = Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Dealer').getRecordTypeId();
        Account dealer1 = new Account(Status__c = 'Customer'
                                     , Name = 'TestDealer' + date.Today()
                                     , RecordTypeId = dealerRTId
                                     , Phone ='(01) 8677 0993'
                                     , Inactivation_Date__c = date.Today().addDays(100)
                                     , Dealer_Active__c =true
                                     , Dealer_Reason_for_Inactivation__c = 'Test Record');
        accInsertList.add(dealer1);
        Account dealer2 = new Account(Status__c = 'Customer'
                                     , Name = 'TestDealer2' + date.Today()
                                     , RecordTypeId = dealerRTId
                                     , Phone ='(01) 8677 0993'
                                     , Dealer_Active__c =true
                                     , Inactivation_Date__c = date.Today().addDays(100)
                                     , Dealer_Reason_for_Inactivation__c = 'Test Record');
        accInsertList.add(dealer2);

        try{
            insert accInsertList;
        }
        catch(DMLException e){
            System.debug('Debug Output ======> {Error: ' + e + '}');
        }

        List<Contact> cnttList = new List<Contact>();
        // Create a '150 Days Primary' dealer contact and a '150 Days CC' dealer
        //    contact on the dealer account
        Contact primCntt1 = new Contact(AccountId = dealer1.Id
                                       , LastName = 'Test'
                                       , FirstName = 'Primary1'
                                       , Email = 'test@test.com'
                                       , EOC_Recipient_Type__c = '150 Days Primary');
        cnttList.add(primCntt1);
        Contact ccCntt1 = new Contact(AccountId = dealer1.Id
                                     , LastName = 'Test'
                                     , FirstName = 'CC1'
                                     , Email = 'test@test.com'
                                     , EOC_Recipient_Type__c = '150 Days CC');
        cnttList.add(ccCntt1);
        Contact ccCntt2 = new Contact(AccountId = dealer2.Id
                                      , LastName = 'Test'
                                      , FirstName = 'CC2'
                                      , Email = 'test@test.com'
                                      , EOC_Recipient_Type__c = '150 Days CC');
        cnttList.add(ccCntt2);
        Contact primCntt2 = new Contact(AccountId = dealer2.Id
                                        , LastName = 'Test'
                                        , FirstName = 'Primary2'
                                        , Email = 'test@test.com'
                                        , EOC_Recipient_Type__c = '150 Days Primary');
        cnttList.add(primCntt2);
        try{
            insert cnttList;
        }
        catch(DMLException e){
            System.debug('Debug Output ======> {Error: ' + e + '}');
        }

        List<Contract> cntrctList = new List<Contract>();
        // Construct a non-fleet contract
        Contract finCntrct1 = new Contract(Status = 'Draft'
                                          , StartDate = date.Today().addDays(30)
                                          , ContractTerm = 3
                                          , AccountId = personAcc.Id
                                          , Dealer_Name__c = dealer1.Id);
        cntrctList.add(finCntrct1);
        Contract finCntrct2 = new Contract(Status = 'Draft'
                                          , StartDate = date.Today().addDays(30)
                                          , ContractTerm = 3
                                          , AccountId = personAcc.Id
                                          , Dealer_Name__c = dealer2.Id);
        cntrctList.add(finCntrct2);

        // Construct a fleet contract
        Contract fltCntrct = new Contract(Status = 'Draft'
                                          , StartDate = date.Today().addDays(30)
                                          , ContractTerm = 3
                                          , AccountId = companyAcc.Id
                                          , Dealer_Name__c = dealer1.Id
                                          , Fleet__c = true);
        cntrctList.add(fltCntrct);

        // Insert the contracts
        try{
            insert cntrctList;
        }
        catch(DMLException e){
            System.debug('Debug Output ======> {Error: ' + e + '}');
        }

        for(Contract cntrct : cntrctList){
            cntrct.X150_Days_Before_EOC__c = true;
        }

        // Update the field '*150 Days Before EOC' to TRUE
        try{
            update cntrctList;
        }
        catch(DMLException e){
            System.debug('Debug Output ======> {Error: ' + e + '}'); 
        }
    }
    // End of added part, Polaris Yu 2013-8-26
}