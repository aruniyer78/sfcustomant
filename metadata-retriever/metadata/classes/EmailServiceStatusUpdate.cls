/**
    CR-000171
    Apex code needs to be created to enable the dealer to change the lead immediately status 
    by clicking on the hyperlink provided in the notification email. 
    -----------------------------------------------------------------------
    Function Description:
        When SFDC recive a mail that to Address is service mail address.
        run below steps: 
        1. Check information of email
             a. mail subject is "LeadStatusUpdate"
             b. mail body has Id and it is a Lead id
             c. mail body has Status and it's in our picklist value
        Mail body must be defined of formatting "LEADID:STATUS:"
        2. When status has "Close" character, 
             set Lost Reason to characters after "close - "
             set Lead Status to "close"
          else 
             set Lead Status to status characters
        
        3. update lead record
    -----------------------------------------------------------------------
    created by : 2014/2/27 Bing
    
 */
 
global class EmailServiceStatusUpdate implements Messaging.InboundEmailHandler{
    
    //Mail subject 
    private static final String MAIL_SUBJECT = 'UpdateLeadStatus';
    //service 
    private static final String SERVICE_MAIL_ADDRESS = '';
    //update error Message
    private static final String ERROR_MSG = ' update process has error, Please connect Admin or  update manually in SFDC .';
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String body = '';
        Lead_Account__c updateObj = null;
system.debug('email==================='+email);
        //check subject
        
        body = email.subject;
        
        /**
        if (email.htmlBodyIsTruncated) {
            body = email.htmlBody;
        }else{
            body = email.plainTextBody;
        }*/
        
        if(String.isblank(body)){
            return makeErrorResult();
        }else{
            List<String> params = body.split(':');
            updateObj = [select Lost_Reason__c, Lead_Status__c from Lead_Account__c where id = :params[0]];
            if(updateObj == null){
                return makeErrorResult();
            }
            //analyze data format correct and set update value in field
            //Lost reason pick list value
            Set<String> LOST_REASON_PICKLIST = getPicklistValues('Lead_Account__c','Lost_Reason__c');
            //lead status pick list value
            Set<String> STATUS_PICKLIST = getPicklistValues('Lead_Account__c','Lead_Status__c');

            if(STATUS_PICKLIST.contains(params[1])){
                updateObj.Lead_Status__c = params[1];
             }else{
                 return makeErrorResult();
             }
system.debug('params============='+params);
            if(params.size()>2){
                if(LOST_REASON_PICKLIST.contains(params[2])){
                    updateObj.Lost_Reason__c = params[2];
                }else{
                    return makeErrorResult();
                }
            }
        }
        system.debug('updateObj=========='+updateObj);
        //update Lead
        update updateObj;

        return result;
    }

    /**
     * @Method Name: getPicklistValues
       @Description: get all pick list values of a field
       @param String ObjectApi_name
       @param String Field_name
       @return List<String>
     */
    private  Set<String> getPicklistValues(String ObjectApi_name,String Field_name){ 

        Set<String> lstPickvals=new Set<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        //From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); 

        //get a map of fields for the passed sobject
        Map<String, Schema.SObjectField> field_map = sobject_type.getDescribe().fields.getMap(); 

        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); 

        //all values in the picklist list
        for (Schema.PicklistEntry a : pick_list_values) { 
        //add the value to our final list
           lstPickvals.add(a.getValue());
        }

        return lstPickvals;
    }
    
    /**
     * make a error result back to mail sender
     */
    private Messaging.InboundEmailResult makeErrorResult(){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success = false;
        result.message = ERROR_MSG ;
        return result;
    }
}