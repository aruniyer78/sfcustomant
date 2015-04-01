/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EmailServiceStatusUpdateTest {

    private static Id leadFinanceRT = 
        Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Finance Lead').getRecordTypeId();
    private static TestDataUtil testData = TestDataUtil.getInstance();

    // create a new email and envelope object
    private static Messaging.InboundEmail email = new Messaging.InboundEmail() ;
    private static Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
    static testMethod void myUnitTest() {
        Id accDealer_RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Id FOS_RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FOS Complaint').getRecordTypeId();
        
        Account personaccount1 = testData.standardPersonAccount;
        insert personaccount1;
                
        Account dealeraccount1 = new Account( Name = 'nameAccount',
                                              Email__c = 'sichao.lai@nttdata.com',
                                              RecordTypeId = accDealer_RecordTypeId,
                                              Phone = '(01) 2334 3442',
                                              Dealer_Reason_for_Inactivation__c = 'Test',
                                              Dealer_Active__c=true);
        insert dealeraccount1;
        Contact contact1 = new Contact ( AccountId = dealeraccount1.id,
                                         FirstName = 'lai',
                                         LastName = 'sichao',
                                         Email = 'sichao.lai@nttdata.com',
                                         EOC_Recipient_Type__c = '60 Days Primary');
        
        insert contact1;
        Contract contract1 = new Contract ( AccountId = personaccount1.Id,
                                            StartDate = Date.Today(),
                                            ContractTerm = 2,
                                            Status = 'Draft');
                                            
        insert contract1;        
        
        Lead_Account__c leada = new Lead_Account__c ( RecordTypeId = leadFinanceRT,
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
        insert leada;
        Test.startTest() ;
        email.subject ='UpdateLeadStatus';
        email.htmlBodyIsTruncated = false;
        env.fromAddress = 'blankxyz@gmail.com';
        email.subject=String.valueof(leada.id)+':Contact Attempt Made:';
        EmailServiceStatusUpdate emailProcess = new EmailServiceStatusUpdate();
        system.debug(email.subject);
        emailProcess.handleInboundEmail(email, env);
        

        Lead_Account__c leadAfterUpdate = [select Lost_Reason__c, Lead_Status__c from Lead_Account__c where id =: leada.id];
        system.assertEquals('Contact Attempt Made',leadAfterUpdate.Lead_Status__c);
        system.assertEquals(null,leadAfterUpdate.Lost_Reason__c);

        email.subject=String.valueof(leada.id)+':Closed:Interest Rate:';
        emailProcess.handleInboundEmail(email, env);
        
        leadAfterUpdate = [select Lost_Reason__c,Lead_Status__c from Lead_Account__c where id =: leada.id];
        system.assertEquals('Closed',leadAfterUpdate.Lead_Status__c);
        system.assertEquals('Interest Rate',leadAfterUpdate.Lost_Reason__c);

        email.subject='';
        emailProcess.handleInboundEmail(email, env);
        
        leadAfterUpdate = [select Lost_Reason__c,Lead_Status__c from Lead_Account__c where id =: leada.id];
        system.assertEquals('Closed',leadAfterUpdate.Lead_Status__c);
        system.assertEquals('Interest Rate',leadAfterUpdate.Lost_Reason__c);

/**
        email.subject='subject';
        emailProcess.handleInboundEmail(email, env);
        
        leadAfterUpdate = [select Lost_Reason__c,Lead_Status__c from Lead_Account__c where id =: leada.id];
        system.assertEquals('Closed',leadAfterUpdate.Lead_Status__c);
        system.assertEquals('Interest Rate',leadAfterUpdate.Lost_Reason__c);
*/
        Case cas = new Case();
        cas.Status = 'Open';
        cas.recordTypeId = FOS_RecordTypeId;
        insert cas;
        
        EmailMessage emsg1 = new EmailMessage();
        emsg1.TextBody = 'textbody';
        emsg1.FromAddress = 'from@address.com';
        emsg1.ToAddress = 'to@address.com';
        emsg1.Subject = 'subject';
        emsg1.Incoming = false;
        emsg1.MessageDate = system.now();
        emsg1.ParentId = cas.Id;
        insert emsg1;
            
        Test.stopTest() ;
    }

}