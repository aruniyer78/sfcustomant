/*
    Type:       Extension class for Visualforce Page:
                SelectAssignedDealerController
    Purpose:    1) Display the proper dealer information according
                to the filters setup by the operating user
                2) Auto assigned the lead to the selected dealer
    User Story: US AU-Lead-007
    Used By:    SelectAssignedDealer.page
    ---------------------------------------------------------------
    History:

    1. Polaris Yu (BreakingPoint) Created on 2013-8-22
*/
public with sharing class ExtSelectAssignedDealer {
    public Lead_Account__c lead                  {get; set;}
    public String name                           {get; set;}
    public Account dealer                        {get; set;}
    public Boolean hasQueryResult                {get; set;}
    public List<Account> dealers                 {get; set;}
    public Id choosenDealerId                    {get; set;}
    public Boolean hasMessage                    {get; set;}

    // Query return limit and Dealer's Record Type Name
    private final Integer QUERY_LIMIT = 200;
    private Id dealerRecordTypeId = null;
    
    public ExtSelectAssignedDealer(ApexPages.StandardController controller) {
        lead = [SELECT RecordType.Name, Name, Assigned_Dealer__c, Postcode__c
                FROM Lead_Account__c WHERE Id =: controller.getId()];
        
        // Initiate dealer
        RecordType dealerRecordType = [SELECT Id FROM RecordType
                                       WHERE Name = 'Dealer'
                                       AND SObjectType = 'Account'];
        dealerRecordTypeId = dealerRecordType.Id;
        dealer = new Account(RecordTypeId = dealerRecordTypeId
                             , Post_Code__c = lead.Postcode__c);

        query();
    }
    
    // Get the SOQL Expr of DealerSearchColumns FieldSet fields
    private String getColumns() {
        String columns = '';
        for (Schema.FieldSetMember member : this.getFieldSetMembers()) {
            columns += member.getFieldPath() + ', ';
        }
        
        return columns;
    }
    
    // Get the FieldSet Members of Account FieldSet(AssignedDealerColumns)
    private List<Schema.FieldSetMember> getFieldSetMembers() {
        return SObjectType.Account.FieldSets.AssignedDealerColumns.getFields();
    }

    public void query() {
        // We must inculde the IsPsersonAccount in the SOQL, otherwise, 
        // we will get exception in debug log but not display on the page
        String querySOQL = 'SELECT ' + this.getColumns() + 
            'IsPersonAccount, Id FROM Account WHERE ' + 
            'Dealer_Active__c = true and RecordTypeId =: dealerRecordTypeId ';

        // Filter Part
        // Filtered by 'Dealer Name'
        if (name != null && name != '') {
            querySOQL += 'AND Name Like \'%' + name + '%\' ';
        }

        if ((dealer.Suburb__c != null && dealer.Suburb__c != '')
            || (dealer.Post_Code__c != null && dealer.Post_Code__c != '')
            || (dealer.Business_Unit__c != null && dealer.Business_Unit__c != '')
            || (dealer.Cars_Offered_Service__c != null
            && dealer.Cars_Offered_Service__c != '')){
            querySOQL += 'AND Id IN (SELECT Dealer_Name__c FROM Dealer_Locator__c WHERE ';

            // Filtered by 'Suburb'
            if (dealer.Suburb__c != null && dealer.Suburb__c != '') {
                String suburb = dealer.Suburb__c;
                querySOQL += 'Suburb__c =: suburb AND ';
            }

            // Filtered by 'Post Code'
            if(dealer.Post_Code__c != null && dealer.Post_Code__c != ''){
                String postCode = dealer.Post_Code__c;
                querySOQL += 'Post_Code__c =: postCode AND ';
            }

            // Filtered by 'Business Unit'
            if(dealer.Business_Unit__c != null && dealer.Business_Unit__c != ''){
                List<String> businessUnit = dealer.Business_Unit__c.split(';', -1);
                String buQuery = '';
                for(integer i = 0; i < businessUnit.size(); i ++){
                    if(i < (businessUnit.size()-1)){
                        buQuery += 'Business_Unit__c = \'' + businessUnit[i] + '\' OR ';
                    }
                    else if(i == (businessUnit.size()-1)){
                        buQuery += 'Business_Unit__c = \'' + businessUnit[i] + '\'';
                    }
                }
                if(businessUnit.size() > 1){
                    querySOQL += '(' + buQuery + ') AND ';
                }
                else{
                    querySOQL += buQuery + ' AND ';
                }
            }

            // Filtered by 'Offered Service'; 8 kinds of Offered Service
            if(dealer.Cars_Offered_Service__c != null && dealer.Cars_Offered_Service__c != ''){
                List<String> offeredService = dealer.Cars_Offered_Service__c.split(';', -1);
                String osQuery = '';
                for(integer i = 0; i < offeredService.size(); i ++ ){
                    if(i < (offeredService.size()-1)){
                        osQuery += 'Offered_Service__c = \'' + offeredService[i] + '\' OR ';
                    }
                    else if(i == (offeredService.size()-1)){
                        osQuery += 'Offered_Service__c = \'' + offeredService[i] + '\'';
                    }
                }
                if(offeredService.size() > 1){
                    querySOQL += '(' + osQuery + ') AND ';
                }
                else{
                    querySOQL += osQuery + ' AND ';
                }
            }
            querySOQL = querySOQL.subString(0, querySOQL.length() - 4) + ')';
        }
        
        // Query Dealers               
        querySOQL += ' ORDER BY Suburb__c DESC NULLS LAST LIMIT ' + this.QUERY_LIMIT;
        System.debug('Debug Output ======> {' + querySOQL + '}');
        System.debug('Debug Output ======> {recordType:'
            + dealerRecordTypeId + '}');
        
        dealers = Database.query(querySOQL); 
        
        // If no query result, system alert no search result.
        hasQueryResult = (dealers.size() > 0);
        if (!hasQueryResult) {
            this.addInfoMessage('No Search Result');
        }
    }
    
    public PageReference choose() {
        // Populate assigned dealer
        hasMessage = false;
        lead.Assigned_Dealer__c = choosenDealerId;

        try {
            update lead;
        }
        catch (DMLException e) {
            this.addErrorMessage(e.getDMLMessage(0));
            hasMessage = true;
            System.debug('Debug Output ======> {' + hasMessage + '}');
        }

        return new PageReference('/' + lead.Id);
    }

    private void addInfoMessage(String msg) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.severity.INFO, msg));
    }

    private void addErrorMessage(String msg) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.severity.ERROR, msg));
    }
}