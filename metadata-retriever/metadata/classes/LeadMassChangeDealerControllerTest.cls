/*
    Type:       Test class of CaseEscalationController
    Purpose:    1. Escalate Case to Region Q
                2. Escalate Case to Central Q
    
    User Story: US-DP-013, US-DP-015
    Used By:    
    ---------------------------------------------------------------
    History:
    
    2014-02-17 Shuang Li (NTTData)  Created
*/     
@isTest
public class LeadMassChangeDealerControllerTest {
        @isTest
        static void testCaseEscalationController1(){
        Id leadFinanceRT = 
        Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Finance Lead').getRecordTypeId();
        Id dealerRTId
            = Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Dealer').getRecordTypeId();
        Account dealer1 = new Account(Status__c = 'Customer'
                                     , Name = 'TestDealer' + date.Today()
                                     , RecordTypeId = dealerRTId
                                     , Phone ='(01) 8677 0993'
                                     , Dealer_Active__c = true
                                     , Inactivation_Date__c = date.Today().addDays(100)
                                     , Dealer_Reason_for_Inactivation__c = 'Test Record');
        insert dealer1;
        Account dealer2 = new Account(Status__c = 'Customer'
                                     , Name = 'TestDealer' + date.Today()
                                     , RecordTypeId = dealerRTId
                                     , Dealer_Active__c = true
                                     , Phone ='(01) 8677 0993'
                                     , Inactivation_Date__c = date.Today().addDays(100)
                                     , Dealer_Reason_for_Inactivation__c = 'Test Record');
        insert dealer2;
        Account personaccount1 = TestDataUtil.getInstance().standardPersonAccount;
        insert personaccount1;
        Contract contract1 = new Contract ( AccountId = personaccount1.Id,
                                            StartDate = Date.Today(),
                                            ContractTerm = 2,
                                            Status = 'Draft');
                                            
        insert contract1;
        Lead_Account__c lead1 = new Lead_Account__c ( RecordTypeId = leadFinanceRT,
                                      Contact__c = personaccount1.id,
                                      Lead_Source__c = 'End of Contract',
                                      Nature_of_Request__c = 'Key2Key',
                                      Business_Unit__c = 'Cars',
                                      Sub_BusinessUnit__c = 'Sales',
                                      Lead_Status__c = 'New Enquiry',
                                      Assigned_Dealer__c = dealer1.id,
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
                                      Assigned_Dealer__c = dealer1.id,
                                      Existing_Contract__c = contract1.id,
                                      //Financial_Product__c = 'Agility Contract',
                                      Is_Finance_Send_Email_Before_60_Days__c = true);
                                      
        insert lead2;
        Test.startTest();
        PageReference leadMassChangeDealer = Page.LeadMassChangeDealer;
        leadMassChangeDealer.getParameters().put('objIds',lead1.id + ',' + lead2.id);
        Test.setCurrentPage(leadMassChangeDealer);
        LeadMassChangeDealerController controller = new LeadMassChangeDealerController();
        controller.assignedDealer = dealer2.id;
        controller.emailRequired = true;
        controller.saveClick(); 
        Set<Id> Ids = new Set<Id>();
        Ids.add(lead1.id);
        Ids.add(lead2.id);
        List<Lead_Account__c> leads = [Select Assigned_Dealer__c From Lead_Account__c Where Id in :Ids];        
        for (Lead_Account__c lead : leads){
        system.assertEquals(lead.Assigned_Dealer__c,dealer2.id);
        }
        controller.assignedDealer = '';
        controller.assignedDealerName= 'TestDealer' + date.Today();
        controller.saveClick(); 
        Test.stopTest();
        
    }
    @isTest
    static void testCaseEscalationController2(){
        
        Test.startTest();
        PageReference leadMassChangeDealer = Page.LeadMassChangeDealer;
        leadMassChangeDealer.getParameters().put('name','TestDealer');
        Test.setCurrentPage(leadMassChangeDealer);
        LeadMassChangeDealerController controller = new LeadMassChangeDealerController();
        controller.query(); 
        controller.choose(); 
        Test.stopTest();
        
    }
    @isTest
    static void testCaseEscalationController3(){
        
        Test.startTest();
        PageReference leadMassChangeDealer = Page.LeadMassChangeDealer;
        leadMassChangeDealer.getParameters().put('name','abc');
        Test.setCurrentPage(leadMassChangeDealer);
        LeadMassChangeDealerController controller = new LeadMassChangeDealerController();
        controller.query(); 
        Test.stopTest();
        
    }
}