/*
    Type:       Utility for Contract
    Purpose:    for user story process unit 
    User Story: US_AU-CD-001, US_AU-CD-002
    Used By:    TriggerContractAfterInsertOrUpdate
    ---------------------------------------------------------------
    History:
        1. Bing Bai Created on 2013-08-05
        2. Justin Yu Updated on 2013-08-22
        3. Polaris Yu (BreakingPoint) Updated on 2013-8-23
        4. Polaris Yu (BreakingPoint) Updated on 2013-10-22
        5. Barney Lai Updated on 2014-03-13
*/
public with sharing class ContractHelper {

    //US-CD-001
    //Get vehiches Vehicle_Group__c by vehicle id
    public static Map<id,Vehicle__c> getVehichles(set<Id> ids){
        return new Map<id,Vehicle__c>(
        [select id,
               Vehicle_Group__c
        from Vehicle__c 
        where Id in :ids]);
    }
       
    //US-CD-001 No.11
    //When PA gets a Customer_Contract_Relationship__c
    public static void updataWhenCreateCCR(Set<Id> vehicleIds ,Set<Id> customerIds, List<Contract> cvrs){
        // Modified by Polaris Yu 2013-10-22, changed 'List<Account>' to 'Set<Account>'
        List<Account> accounts = new List<Account>();

        Map<id,Account> accs = AccountHelper.getCustomerInfos(customerIds);
        Map<id,Account> accountsForUpdate = new Map<id,Account>();
        Map<id,Vehicle__c> vehichles = getVehichles(vehicleIds);
        for(Contract curCcr: cvrs){
            if(!String.isblank(curCcr.AccountId)){
                Account acc = accs.get(curCcr.AccountId);
                if(vehichles.get(curCcr.Vehicle__c) != null){
                    if (vehichles.get(curCcr.Vehicle__c).Vehicle_Group__c == 'PC' ){
                        if(acc.PC_Status__c == 'Customer'){
                           continue;
                        }else{
                           acc.PC_Status__c = 'Customer';
                        }
                    }
                    if (vehichles.get(curCcr.Vehicle__c).Vehicle_Group__c == 'CV'){
                        if(acc.CV_Status__c == 'Customer'){
                           continue;
                        }else{
                           acc.CV_Status__c = 'Customer';
                        }
                    }
                    if (vehichles.get(curCcr.Vehicle__c).Vehicle_Group__c == 'Van'){
                        if(acc.VAN_Status__c == 'Customer'){
                           continue;
                        }else{
                           acc.VAN_Status__c = 'Customer';
                        }
                    }
                }
                accountsForUpdate.put(acc.Id, acc);
            }
        }
        
        DBUtil.updateSobjects(accountsForUpdate.values());
        // End of Added Part, Polaris Yu 2013-10-22
    }    
    
    // For US-CD-019 NO.2
    public static void createCompanyIndividualRelationship(Set<String> contractIds){
        List<Account> personAccounts = new List<Account>();
        //Barney lai 2014-3-13 start
        Map<Id, Account> idPersonAccounts = new Map<Id, Account>();
        //Barney lai 2014-3-13 end
        for(Contract contract : [select AccountId, Signer__c, Account.RecordType.Name, Signer__r.Company__c
                                 from Contract where Id in :contractIds]){
            if(contract.Account.RecordType.Name == 'Company' && contract.Signer__c != null){
                contract.Signer__r.Company__c = contract.AccountId;
                //Barney lai 2014-3-13 start
                idPersonAccounts.put(contract.Signer__r.id, contract.Signer__r);
                //Barney lai 2014-3-13 end
            }
        }
        //Barney lai 2014-3-13 start
        personAccounts = idPersonAccounts.values();
        //Barney lai 2014-3-13 end
        update personAccounts;
    }

    // Auto Create Leads
    // Added by Polaris Yu 2013-8-23; For User Story: 
    //    US_AU-Lead-011, US_AU-Lead-012
    public static void autoCreateLeads(Map<Id, Contract> newMap
        , Map<Id, Contract> oldMap){
        // Select the contracts that the '*150 Days Before EOC'
        //    field of which are updated to TRUE
        List<Contract> finCntrctList = new List<Contract>();
        List<Contract> fltCntrctList = new List<Contract>();
        for(Id curCntrctId : newMap.keySet()){
            if((oldMap.get(curCntrctId).X150_Days_Before_EOC__c
                != newMap.get(curCntrctId).X150_Days_Before_EOC__c)
                && newMap.get(curCntrctId).X150_Days_Before_EOC__c == TRUE){
                if(newMap.get(curCntrctId).Fleet__c == TRUE){
                    fltCntrctList.add(newMap.get(curCntrctId));
                }
                else{
                    finCntrctList.add(newMap.get(curCntrctId));
                }
            }
        }

        List<Lead_Account__c> newLeadList = new List<Lead_Account__c>();
        // Create finance leads based on the non-fleet contracts
        if(finCntrctList.size() > 0){
            // Get the finance lead record type information
            RecordType financeLdRT = [SELECT Id, Name FROM RecordType
                                      WHERE Name = 'Finance Lead'];
            if(financeLdRT != null){
                for(Contract curCntrct : finCntrctList){
                    Lead_Account__c newLead = new Lead_Account__c();
                    newLead.RecordTypeId = financeLdRT.Id;
                    newLead.Existing_Contract__c = curCntrct.Id;
                    newLead.Nature_of_Request__c = 'End of Contract';
                    newLead.OwnerId = curCntrct.OwnerId;
                    newLead.Lead_Status__c = 'New Enquiry';
                    newLead.Lead_Source__c = 'End of Contract';
                    newLead.Contact__c = curCntrct.AccountId;
                    newLead.Assigned_Dealer__c = curCntrct.Dealer_Name__c;
                    newLead.Is_Finance_Send_Email_Before_150_Days__c = true;
                    newLeadList.add(newLead);
                }
            }
        }

        // Create fleet leads based on the fleet contracts
        if(fltCntrctList.size() > 0){
            // Get the fleet lead record type information
            RecordType fleetLdRT = [SELECT Id, Name FROM RecordType
                                    WHERE Name = 'Fleet Lead'];
            if(fleetLdRT != null){
                for(Contract curCntrct : fltCntrctList){
                    Lead_Account__c newLead = new Lead_Account__c();
                    newLead.RecordTypeId = fleetLdRT.Id;
                    newLead.Existing_Contract__c = curCntrct.Id;
                    newLead.Nature_of_Request__c = 'End of Contract';
                    newLead.OwnerId = curCntrct.OwnerId;
                    newLead.Lead_Status__c = 'New Enquiry';
                    newLead.Lead_Source__c = 'End of Contract';
                    newLead.Company_Account__c = curCntrct.AccountId;
                    newLead.Assigned_Dealer__c = curCntrct.Dealer_Name__c;
                    newLead.Business_Unit__c = 'Fleet';
                    newLead.Sub_BusinessUnit__c = 'Finance';
                    newLead.Is_Fleet_Send_Email_Before_150_Days__c = true;
                    newLeadList.add(newLead);
                }
            }
        }

        // Insert the new leads into the system
        if(newLeadList.size() > 0){
            try{
                insert newLeadList;
                
                // Send email notifications to corresponding recipients
                //US_AU_CR-000171 Modified by Bing Start
                //LeadHelper.sendEOCEmailNotifications(newLeadList);
                LeadHelper.send171Email(newLeadList);
                //US_AU_CR-000171 Modified by Bing End
            }
            catch(DMLException e){
                Trigger.new[0].addError('Error: ' + e);
            }
        }
    }
    // End of added part, Polaris Yu 2013-8-23
}