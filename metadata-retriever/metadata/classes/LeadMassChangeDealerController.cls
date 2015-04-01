/*
    Type:       Controller for LeadMassChangeDealer Visualforce page 
    Purpose:    Mass Change Dealers
    User Story: CR-000144, CR-000039
    Used By:    LeadMassChangeDealer.page
    ---------------------------------------------------------------
    History:
    
    1. Shuang Li Created on 2013-02-14
*/

public class LeadMassChangeDealerController {

    private String [] arrObjIds;
    private final String ACCOUNT_RT_DEALER = 'Dealer';
       
    public List<Account> dealers { get; set; }
    public Boolean hasQueryResult { get; set; }
    public String name {get; set;}
    public Boolean emailRequired {get; set;}
    public String choosenDealerName    {get; set;}
    public Id choosenDealerId    {get; set;}
    public String selectIdText {get; set;}
    public String selectNameText {get; set;}
    public String assignedDealer {set;get;}
    public String assignedDealerName {set;get;}
    
    public LeadMassChangeDealerController(){  
        Map<String, String> params = ApexPages.currentPage().getParameters();        
        String strObjIds = params.get('objIds'); 
        if(strObjIds != null){       
            arrObjIds = strObjIds.split(','); 
        }else{
            String strName = params.get('name');    
            name = strName ;
            query();
        }  
    }            
        
    public PageReference saveClick(){  
        if(assignedDealer == null || assignedDealer ==''){ 
            if(assignedDealerName == null || assignedDealerName ==''){           
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'Invalid Data.'));
                return null; 
            }
            else{
                List<Account> accounts = [Select id From Account Where name = :assignedDealerName or SF_Dealer_ID__c = :assignedDealerName limit 1 ];
                if(accounts.size()>0){   
                    assignedDealer = accounts[0].id;
                }else{
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'Invalid Data.'));
                    return null; 
                }
            
            }   
        }     
        List<Lead_Account__c> leads = [Select Id, Assigned_Dealer__c, name From Lead_Account__c Where Id=:arrObjIds];  
        String leadLink=''; 
        String host = ApexPages.currentPage().getHeaders().get('Host');     
        String url = 'https://' + host;
        for(Lead_Account__c t : leads){            
            t.Assigned_Dealer__c = assignedDealer  ; 
            leadLink=leadLink+ t.name +': <a target="_blank" href=' + url + '/' + t.id  +'>'+url + '/' + t.id + '</a>' + '<br/>';
        }
        
        if(leads.size()>0){   
            if(emailRequired ){ 
                Account account = [Select name ,Dealer_email__c From Account Where Id = :assignedDealer];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {account.Dealer_email__c};
                mail.setToAddresses(toAddresses);
                mail.setSubject('Notification Email ');
                mail.setHtmlBody('Dear  ' + account.name + '<br/>Follow leads is transfered to you <br />To view the details of these leads in salesforce.com click on the following ' +'<br />'
                +leadLink);
                try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                } catch(Exception ex) {
                    system.debug('Send Notification Email Exception : finish :' + ex.getMessage());
                }   
            }           
            try {      
                update leads; 
            }
            catch (DMLException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 
                e.getDMLMessage(0)));
                return null;       
            } 
        }
        return new PageReference('/a08');   
    }
    
    public PageReference choose() {
        selectIdText = choosenDealerId;
        selectNameText = choosenDealerName;
        return null;
    }
    
    public void query() {
        String querySOQL = 'SELECT name, Owner.Name ,Type ,Id FROM Account WHERE Dealer_Active__c = true and ' + 
            'RecordType.Name = :ACCOUNT_RT_DEALER ';

        if (name != null && name != '') {
            querySOQL += 'and (Name Like \'%' + name + '%\' OR ' + 'SF_Dealer_ID__c Like \'%' + name +'%\')';
        }
        
        dealers = Database.query(querySOQL);
        
        // If no query result, system alert no search result.
        hasQueryResult = (dealers.size() > 0);
        if (!hasQueryResult) {
            this.addInfoMessage('No records found');
        }
    }
    
    private void addInfoMessage(String msg) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.severity.INFO, msg));
    }
}