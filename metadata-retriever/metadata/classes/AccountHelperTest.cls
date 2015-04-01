/*
    Type:       Account Controller Test
    Purpose:    Test the class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Bai Bing created on 2013-08-08
    2. Jusitn Yu updated on 2013-11-05
*/
@isTest
private class AccountHelperTest {

    private static TestDataUtil testData = TestDataUtil.getInstance();

    @isTest static void myUnitTest() {
        Account customer1 = testData.standardPersonAccount;
        insert customer1;

        customer1.Partner_Title__c = 'pTitle';
        customer1.Partner_Surname__c = 'pSurName';
        update customer1;
        //system.assertEquals('Professor FirstName LastName and pTitle pSurName', [select Display_Name__c from Account where id=:customer1.id].Display_Name__c);
        
        customer1.Partner_Surname__c = 'LastName';
        update customer1;
        //system.assertEquals('Professor and pTitle LastName', [select Display_Name__c from Account where id=:customer1.id].Display_Name__c);
        
        Account companyAcct = testData.standardCompanyAccount;
        insert companyAcct;
        Account customer2 = customer1.clone();
        customer2.FirstName = 'customer2';
        customer2.LastName = 'customer2';
        customer2.Copy_Postal_Address_2_Street_Address__c = true;
        insert customer2;
        
        customer1.Company__c = companyAcct.id;
        update customer1;
        //system.assertEquals(true,[select Primary__pc from Account where id=:customer1.id].Primary__pc);
        
        customer2.Company__c = companyAcct.Id;
        update customer2;
        //system.assertEquals(true,[select Primary__pc from Account where id=:customer2.id].Primary__pc);
        //system.assertEquals(false,[select Primary__pc from Account where id=:customer1.id].Primary__pc);
        
        delete customer2;
        //system.assertEquals(true,[select Primary__pc from Account where id=:customer1.id].Primary__pc);
    }
    
    @isTest static void testTrackUpdateHistory() {
        Account testAccount = testData.standardPersonAccount;
        insert testAccount;
        
        testAccount.FS_Opt_In_Email__c = true;
        testAccount.Opt_In_Email__c = true;
        update testAccount;
        testAccount = [select FS_Email_Last_Modified_By__c, FS_Email_Last_Modified_Date__c from Account where Id = :testAccount.Id];
        //System.assertEquals(testAccount.FS_Email_Last_Modified_By__c, UserInfo.getName());
        
        testAccount.FS_Opt_In_Hardcopy__c = true;
        testAccount.Opt_In_Hardcopy__c = true;
        update testAccount;
        testAccount = [select FS_Hardcopy_Last_Modified_By__c, FS_Hardcopy_Last_Modified_Date__c from Account where Id = :testAccount.Id];
        //System.assertEquals(testAccount.FS_Hardcopy_Last_Modified_By__c, UserInfo.getName());
        
        testAccount.FS_Opt_In_Phone__c = true;
        testAccount.Opt_In_Phone__c = true;
        update testAccount;
        testAccount = [select FS_Phone_Last_Modified_By__c, FS_Phone_Last_Modified_Date__c from Account where Id = :testAccount.Id];
        //System.assertEquals(testAccount.FS_Phone_Last_Modified_By__c, UserInfo.getName());

        testAccount.FS_Opt_In_SMS__c = true;
        testAccount.Opt_In_SMS__c = true;
        update testAccount;
        testAccount = [select FS_SMS_Last_Modified_By__c, FS_SMS_Last_Modified_Date__c from Account where Id = :testAccount.Id];
        //System.assertEquals(testAccount.FS_SMS_Last_Modified_By__c, UserInfo.getName());   
    } 
}