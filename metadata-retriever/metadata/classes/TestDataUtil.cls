/*
    Type:       Class
    Purpose:    Utility for test data creating.
    User Story: 
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Justin Yu Created on 2013-11-01
*/
@isTest
public class TestDataUtil {
    
    // Singleton
    private static TestDataUtil instance;
    private TestDataUtil(){}
    public static TestDataUtil getInstance(){
        if(instance == null){
            instance = new TestDataUtil();
        }
        return instance;
    }
    
    private Id person_RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    private Id company_RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
    
    public Account standardPersonAccount{
        get{
            if(standardPersonAccount == null){
                standardPersonAccount = new Account(
                    Status__c = 'Customer',
                    LastName = 'LastName',
                    Salutation = 'Professor',
                    FirstName = 'FirstName',
                    Suffix__c = 'suffix',
                    PersonEmail = 'test@test.com',
                    RecordTypeId = person_RecordTypeId,
                    PersonMobilePhone = '1800 999 999'
                );
            }
            return standardPersonAccount;
        }
        set;
    }
    
    public Account standardCompanyAccount{
        get{
            if(standardCompanyAccount == null){
                standardCompanyAccount = new Account(
                    Status__c='Customer',
                    Name = 'Company',
                    Suffix__c = 'Mr.',
                    Email__c='test@test.com',
                    RecordTypeId=company_RecordTypeId
                );
            }
            return standardCompanyAccount;
        }
        set;
    }
    
    public Address__c standardAddress{
        get{
            if(standardAddress == null){
                standardAddress = new Address__c(
                    Address_Line_1__c = 'Address Line', 
                    Suburb__c = 'Suburb',
                    Address_Type__c = 'Mailing', 
					Post_Code__c = '1000', 
					Preferred__c = true, 
					Status__c = 'Incomplete',
					Country__c = 'New Zeeland'
                );
            }
            return standardAddress;
        }
        set;
    }                      
}