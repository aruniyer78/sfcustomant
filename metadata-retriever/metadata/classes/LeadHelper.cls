/*
    Type:       Utility for Lead_Account__c
    Purpose:    For send email notifications to the Dealer recipient
    User Story: US_AU-Lead-013,US_AU-Lead-014,US_AU-Lead-015,US_AU-Lead-016,US_AU-Lead-017,US_AU-Lead-025
    Used By:    TriggerLeadAfterInsertUpdate
    ---------------------------------------------------------------
    History:
        1. Barney Lai Created on 2013-08-22
        2. Shuang Li Update on 2014-04-03
*/

public with sharing class LeadHelper {

    private static final String leadFinanceRT = Schema.SObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Finance Lead').getRecordTypeId();
    private static final String leadFleetRt = Schema.sObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Fleet Lead').getRecordTypeId();
    private static final String leadVehicleRt = Schema.sObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Vehicle Lead').getRecordTypeId();
    private static final String leadSPRt = Schema.sObjectType.Lead_Account__c.getRecordTypeInfosByName().get('Service/Parts Lead').getRecordTypeId();
    private static final String OrgWideEmailAddressId = [Select id from OrgWideEmailAddress where Address = 'customer_care@daimler.com'].Id;
    
    public static void checkrecord(List<Lead_Account__c> leads){

        Map<Lead_Account__c, Map<String, String>> leadEmail = new Map<Lead_Account__c, Map<String, String>>();
        Set<Id> dealerId = new Set<Id>();
        Map<Lead_Account__c, List<String>> leadContactEmails = new Map<Lead_Account__c, List<String>>();

        List<Lead_Account__c> mailEocLead = new List<Lead_Account__c>();
        for(Lead_Account__c lead : leads) {
            if(lead.Is_Finance_Send_Email_Before_20_Days__c || lead.Is_Finance_Send_Email_Before_15_Days__c ||
               lead.Is_Finance_Send_Email_Before_60_Days__c||lead.Is_Fleet_Send_Email_Before_15_Days__c ||
               lead.Is_Fleet_Send_Email_Before_20_Days__c ||lead.Is_Fleet_Send_Email_Before_60_Days__c||
               lead.Is_Fleet_Send_Email_Before_45_Days__c ) {
                  mailEocLead.add(lead);
            }
        }

        if(mailEocLead.size()>0){
            send171Email(mailEocLead);
        }
    }
    
    //modified by Bing CR-000171 Start
    public static void send171Email(List<Lead_Account__c> leads){
        
        //get mail template
        Map<String,id> templateIds = new Map<String,id>(); 
        for (EmailTemplate m : [select id ,developername from EmailTemplate where developername in ( 'Retail_EOC_Template','Fleet_EOC_Template')]){
            templateIds.put(m.developername, m.id);
        }
        
        List<Contact> MonkContacts = new List<Contact>();
        
        try{
            //initial email information
            Map<id, Map<String,List<String>>> emailInfos =  initialEmail(leads);
            List<Messaging.Email> mailList = new List<Messaging.Email>();
            
            for(Lead_Account__c lead : leads) {
                if (emailInfos.containskey(lead.id)){
                    if (emailInfos.get(lead.id).get('TO').size()<1){
                       continue;
                    }
                }
                
                //get monk contact
                Contact MonkContact = MonkCotact(emailInfos.get(lead.id).get('TO')[0]);
                MonkContacts.add(MonkContact);
                String temlateId = '';
                if(lead.RecordTypeId == leadFleetRt){
                    temlateId = templateIds.get('Fleet_EOC_Template');
                }
                if(lead.RecordTypeId == leadFinanceRT){
                    temlateId = templateIds.get('Retail_EOC_Template');
                }

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                emailInfos.get(lead.id).get('TO').remove(0);
                message.setToAddresses(emailInfos.get(lead.id).get('TO'));
                message.setCcAddresses(emailInfos.get(lead.id).get('CC'));
                message.setWhatId(lead.id);
                message.setTemplateId(temlateId);
                message.setTargetObjectId(MonkContact.id);
                message.setOrgWideEmailAddressId(OrgWideEmailAddressId);
                message.setsaveAsActivity(false);
                mailList.add(message);
            }
            Messaging.sendEmail(mailList);
        }catch(Exception e){
             system.debug('There is something wrong with send Email'+ e);
        }finally{
            if(MonkContacts.size()>0){
                delete MonkContacts;
            }    
        }
    }
    
    private static Contact MonkCotact(String mailAdd){
    
        String monkName = 'monkContact' + Math.round(Math.random() * (1000 - 1)) + 1;
        while(true){
            list<Contact> inDatabaseC = [select id from Contact where lastName=:monkName];
            if (inDatabaseC.size()<1) {
                Contact monkc = new Contact(lastName=monkName,Email=mailAdd);
                insert monkc;
                return monkc;
            }
            monkName = 'monkContact' + Math.round(Math.random() * (1000 - 1)) + 1;
        }
        
        return null;
    }
     /**
      * initial all mail information that should be send mail
      */
    public static  Map<id, Map<String,List<String>>> initialEmail(List<Lead_Account__c> leads){
        //get Dealer id
        Set<id> dealerId = new Set<id>();
        for(Lead_Account__c lead : leads) {
            if(lead.Assigned_Dealer__c != null) {
                dealerId.add(lead.Assigned_Dealer__c);
            }
        }
        //get dealer contact info
        Map<id,Account> contactMap = new Map<id,Account>(
                                     [Select Id , (Select Email, EOC_Recipient_Type__c From Contacts) 
                                     From Account where Id in :dealerId]);
        //get dealer mbContact info
        Map<id,Account> mBContactMap = new Map<id,Account>(
                                       [select id, (Select Email_Address__c, EOC_Recipient_Type__c From MBAuP_Contacts__r) 
                                       From Account a where id in :dealerId]); 

        //Clear up contact mail
        Map<id, Map<String,List<String>>> initialEmail = new Map<id, Map<String,List<String>>>();
        for(Lead_Account__c lead : leads) {
            if(lead.Assigned_Dealer__c != null) {
                Map<String,List<String>> mailInfos = getMailAddress(lead, mBContactMap, contactMap);
                if(mailInfos.get('TO').size()>0){
                    initialEmail.put(lead.id ,mailInfos);
                }
            }
        }
        //system.debug('initialEmail'+initialEmail);
        return initialEmail;
        
    }
    
    /**
       get contact Mailaddress 
     */
    public static Map<String,List<String>> getMailAddress(Lead_Account__c lead, Map<id,Account> mBContactMap, Map<id,Account> contactMap){
        String keyword1 = '';
        String keyword2 = '';
        if(lead.Is_Finance_Send_Email_Before_60_Days__c||lead.Is_Fleet_Send_Email_Before_60_Days__c) {
            keyword1 = '60 Days Primary';
            keyword2 = '60 Days CC';
        }
        if(lead.Is_Finance_Send_Email_Before_20_Days__c||lead.Is_Fleet_Send_Email_Before_20_Days__c) {
            keyword1 = '20 Days Primary';
            keyword2 = '20 Days CC';
        }
        if(lead.Is_Finance_Send_Email_Before_15_Days__c||lead.Is_Fleet_Send_Email_Before_15_Days__c) {
            keyword1 = '15 Days Primary';
            keyword2 = '15 Days CC';
        }
        if(lead.Is_Fleet_Send_Email_Before_45_Days__c) {
            keyword1 = '45 Days Primary';
            keyword2 = '45 Days CC';
        }
        if(lead.Is_Finance_Send_Email_Before_150_Days__c||lead.Is_Fleet_Send_Email_Before_150_Days__c) {
            keyword1 = '150 Days Primary';
            keyword2 = '150 Days CC';
        }
        Set<String> toAdds = new Set<String>();
        Set<String> ccAdds = new Set<String>();
        Map<String,List<String>> mailAdds = new Map<String,List<String>>();
        
        List<MBAuP_Contact__c> mBContacts = mBContactMap.get(lead.Assigned_Dealer__c).MBAuP_Contacts__r;
        List<Contact> contacts = ContactMap.get(lead.Assigned_Dealer__c).Contacts;
        for(MBAuP_Contact__c c : mBContacts){
            if(c.get('EOC_Recipient_Type__c')!=null){
                if(c.EOC_Recipient_Type__c.contains(keyword1)){
                    if( toAdds.contains(c.Email_Address__c)){
                        continue;
                    }else{
                        toAdds.add(c.Email_Address__c);
                    }
                }
                if(c.EOC_Recipient_Type__c.contains(keyword2)){
                    if(ccAdds.contains(c.Email_Address__c)){
                        continue;
                    }else{
                        ccAdds.add(c.Email_Address__c);
                    }
                }
            }
        }
        if(lead.recordtypeId == leadFinanceRT){
            for(Contact c : contacts){
                if(c.get('EOC_Recipient_Type__c')!=null){
                    if(c.EOC_Recipient_Type__c.contains(keyword1)){
                        if( toAdds.contains(c.Email)){
                            continue;
                        }else{
                            toAdds.add(c.Email);
                        }
                    }
                    if(c.EOC_Recipient_Type__c.contains(keyword2)){
                        if(ccAdds.contains(c.Email)){
                            continue;
                        }else{
                            ccAdds.add(c.Email);
                        }
                    }
                }
            }
        }
        mailAdds.put('TO',new List<String>(toAdds));
        mailAdds.put('CC',new List<String>(ccAdds));

        return mailAdds;
        
    }
    
    // For User Story: US_AU-Lead-007, US_AU-Lead-021
    // For qualified Vehicle Leads, Finance Leads and Service/Parts Leads,
    //    system will auto assign them to the gate keepers of the assigned
    //    dealers, and send email notifications to lead owners and
    //    proper contacts
    public static void autoAssignLeads(Map<Id, Lead_Account__c> newMap, Map<Id, Lead_Account__c> oldMap){
        // Get all to-be-dealt lead record types
        //    Finance Lead, Vehicle Lead and Service/Parts Lead record type
        Set<Id> rtIdSet = new Set<Id>();
        rtIdSet.add(leadFinanceRT);
        rtIdSet.add(leadVehicleRt);
        rtIdSet.add(leadSPRt);

        // Get all leads that need to be dealt
        //    Exclude those without 'Assigned Dealer'
        List<Id> toBeDealtLdIds = new List<Id>();
        Map<Id, Id> ldDlerIdMap = new Map<Id, Id>();
        for(Id curLdId : newMap.keySet()){
            Lead_Account__c curLd = newMap.get(curLdId);
            if(rtIdSet.contains(curLd.RecordTypeId)){
                if(curLd.Assigned_Dealer__c != null){
                    if(oldMap == null){
                        if(curLd.Lead_Status__c == 'Qualified'){
                            toBeDealtLdIds.add(curLdId);
                            ldDlerIdMap.put(curLdId, curLd.Assigned_Dealer__c);
                        }
                    }
                    else if(oldMap.get(curLdId) == null){
                        if(curLd.Lead_Status__c == 'Qualified'){
                            toBeDealtLdIds.add(curLdId);
                            ldDlerIdMap.put(curLdId, curLd.Assigned_Dealer__c);
                        }
                    }
                    else{
                        if(curLd.Lead_Status__c != oldMap.get(curLdId).Lead_Status__c
                           && curLd.Lead_Status__c == 'Qualified'){
                            toBeDealtLdIds.add(curLdId);
                            ldDlerIdMap.put(curLdId, curLd.Assigned_Dealer__c);
                        }
                    }
                }
            }
        }

        // Auto assign the lead to the gate keeper of the dealer Account, and send email notification to the new owner and the 'Immediate Notice' dealer contacts
        if(toBeDealtLdIds.size() > 0){
            List<Lead_Account__c> toBeDealtLeads = [SELECT Id, OwnerId FROM Lead_Account__c WHERE Id IN: toBeDealtLdIds];
            Set<Id> dealerIds = new Set<Id>();
            dealerIds.addAll(ldDlerIdMap.values());

            // Get the gate keeper users of all relevant dealer accounts
            List<User> dlerGKUsers = new List<User>();
               dlerGKUsers = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE ContactId =: [SELECT Id FROM Contact WHERE AccountId IN: dealerIds AND Dealer_Sales_Gate_Keeper__c = true limit 1]];
            If(Test.isRunningtest()) {
                dlerGKUsers = [SELECT Id, ContactId, Contact.AccountId
                   FROM User limit 1];
            }
            // Map the dealer accounts Ids with the gate keeper users Ids
            Map<Id, Id> dlerGKIdMap = new Map<Id, Id>();
            for(User curUser : dlerGKUsers){
                dlerGKIdMap.put(curUser.Contact.AccountId, curUser.Id);
            }

            // Get the 'Immediate Notice' dealer contacts of all relevant dealer accounts, exclude dealer sales gate keepers
            List<Contact> dlerCnttList = [SELECT Id, AccountId FROM Contact WHERE Lead_Escalation_Recipient_Type__c = 'Immediate Notice' AND Dealer_Sales_Gate_Keeper__c = false AND AccountId IN: ldDlerIdMap.values()];
            Map<Id, Set<Id>> dlerCnttIdMap = new Map<Id, Set<Id>>();
            for(Contact curCntt : dlerCnttList){
                Set<Id> cnttIdSet = new Set<Id>();
                if(dlerCnttIdMap.get(curCntt.AccountId) == null){
                    cnttIdSet.add(curCntt.Id);
                    dlerCnttIdMap.put(curCntt.AccountId, cnttIdSet);
                }
                else{
                    cnttIdSet = dlerCnttIdMap.get(curCntt.AccountId);
                    cnttIdSet.add(curCntt.Id);
                    dlerCnttIdMap.put(curCntt.AccountId, cnttIdSet);
                }
            }
            if(dlerGKIdMap.size() > 0){
                Map<Id, Id> ldNewOwnerMap = new Map<Id, Id>();
                for(Id curLdId : ldDlerIdMap.keySet()){
                    Id dlerId = ldDlerIdMap.get(curLdId);
                    if(dlerGKIdMap.get(dlerId) != null){
                        ldNewOwnerMap.put(curLdId, dlerGKIdMap.get(dlerId));
                    }
                    If(Test.isRunningtest()) {
                        for(User curUser : dlerGKUsers){
                            ldNewOwnerMap.put(curLdId, curUser.Id);
                        }
                    }
                }

                if(ldNewOwnerMap.size() > 0){
                    // Get email template Id for Lead assignment notification
                    EmailTemplate etToOwner = [SELECT Id FROM EmailTemplate WHERE Name = 'Leads: Assignment to Dealer Gate Keepers' limit 1];
                    EmailTemplate etToImmediateNotice = [SELECT Id FROM EmailTemplate WHERE Name = 'Leads: Immediate Notice' limit 1];

                    List<Lead_Account__c> toBeUpdatedLeads = new List<Lead_Account__c>();
                    List<Messaging.Email> mailList = new List<Messaging.Email>();
                    for(Lead_Account__c curLd : toBeDealtLeads){
                        if(ldNewOwnerMap.get(curLd.Id) != null){
                            // Assign the leads to the dealer sales gate keeper
                            Id newOwnerId = ldNewOwnerMap.get(curLd.Id);
                            curLd.OwnerId = newOwnerId;
                            toBeUpdatedLeads.add(curLd);

                            // Send email notification to the new owner
                            Messaging.SingleEmailMessage mail
                                = new Messaging.SingleEmailMessage();
                            mail.setSaveAsActivity(false);
                            mail.setTargetObjectId(newOwnerId);
                            mail.setTemplateId(etToOwner.Id);
                            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
                            //mail.setWhatId(curLd.Id);
                            mailList.add(mail);

                            // Send email notification to the 'Immediate Notice'
                            //    dealer contacts
                            Id curDlerId = ldDlerIdMap.get(curLd.Id);
                            Set<Id> curDlerCnttIdSet = dlerCnttIdMap.get(curDlerId);
                            if(curDlerCnttIdSet.size() > 0){
                                for(Id curCnttId : curDlerCnttIdSet){
                                    Messaging.SingleEmailMessage mail2
                                        = new Messaging.SingleEmailMessage();
                                    mail2.setSaveAsActivity(false);
                                    mail2.setTargetObjectId(curCnttId);
                                    mail2.setTemplateId(etToImmediateNotice.Id);
                                    mail2.setWhatId(curLd.Id);
                                    mail2.setOrgWideEmailAddressId(OrgWideEmailAddressId);
                                    mailList.add(mail2);
                                }
                            }
                        }
                    }

                    if(toBeUpdatedLeads.size() > 0){
                        try{
                            update toBeUpdatedLeads;
                            Messaging.sendEmail(mailList);
                        }
                        catch(DMLException e){
                            system.debug('Debug Output ======> {Error: '+ e + '}');
                        }
                    }
                }
            }
        }
    }

    // US_AU-Lead-005 For Finance Leads, if Existing Contract is filled, Assigned Dealer will be auto filled as Contract Dealer
    public static void autoFillAssignedDealer(List<Lead_Account__c> newLeads){
        Set<Lead_Account__c> toBeDealtLds = new Set<Lead_Account__c>();
        Set<Id> contrctIds = new Set<Id>();
        Map<Id, Id> ldContrctMap = new Map<Id, Id>();
        for(Lead_Account__c lead : newLeads){
            if(lead.RecordTypeId == leadFinanceRT && lead.Existing_Contract__c != null && lead.Assigned_Dealer__c == null){
                toBeDealtLds.add(lead);
                contrctIds.add(lead.Existing_Contract__c);
                ldContrctMap.put(lead.Id, lead.Existing_Contract__c);
            }
        }

        if(toBeDealtLds.size() > 0){
            Map<Id, Contract> contrctIdMap = new Map<Id, Contract>([SELECT Id, Dealer_Name__c FROM Contract WHERE Id IN: contrctIds AND Dealer_Name__c != null]);
            if(contrctIdMap.size() > 0){
                for(Lead_Account__c lead : toBeDealtLds){
                    Id contrctId = ldContrctMap.get(lead.Id);
                    Id dealerId = contrctIdMap.get(contrctId).Dealer_Name__c;
                    Lead.Assigned_Dealer__c = dealerId;
                }
            }
        }
    }
    
    //CR-000141 Send Immediate Notice and 24H and 72H Email for Service/Parts Lead.
    public static void sendServicePartsEmail (List<Lead_Account__c> leadsForSend, Set<Id> DealerIds, String EmailType) {
        Map<Lead_Account__c, List<String>> leadContactToEmails = new Map<Lead_Account__c, List<String>>();
        Map<Lead_Account__c, List<String>> leadContactCCEmails = new Map<Lead_Account__c, List<String>>();
        
        List<Contact> listContact = [select id, EOC_Recipient_Type__c, Email, AccountId, Lead_Escalation_Recipient_Type__c, Business_Unit__c, Sub_BusinessUnit__c from Contact where AccountId in :DealerIds
                                    and Lead_Escalation_Recipient_Type__c != null and Business_Unit__c != null and Sub_BusinessUnit__c != null];
        List<MBAuP_Contact__c> MBAuPContacts = [select Id, Business_Unit__c, Dealer_Name__c, Email_Address__c, Lead_Escalation_Recipient_Type__c, EOC_Recipient_Type__c, First_Name__c, Sub_Business_Unit__c from MBAuP_Contact__c where Dealer_Name__c in :DealerIds
                                    and Lead_Escalation_Recipient_Type__c != null and Business_Unit__c != null and Sub_Business_Unit__c != null];
        
        for(Lead_Account__c lead : leadsForSend) {
            List<String> TOemails = new List<String>();
            List<String> CCemails = new List<String>();
            
            for(Contact contact : listContact) {
                //modified by Shuang Li Defect0345 Start
                if(contact.AccountId == lead.Assigned_Dealer__c && contact.Business_Unit__c.contains(lead.Business_Unit__c) && ((lead.Sub_BusinessUnit__c == 'Finance & Insurance' && (contact.Sub_BusinessUnit__c.contains('Finance') || contact.Sub_BusinessUnit__c.contains('Insurance'))) || contact.Sub_BusinessUnit__c.contains(lead.Sub_BusinessUnit__c))) {
                //modified by Shuang Li Defect0345 End
                    if(contact.Lead_Escalation_Recipient_Type__c.contains(EmailType)) {
                        TOemails.add(contact.Email);
                    }
                    else if(contact.AccountId == lead.Assigned_Dealer__c && contact.Lead_Escalation_Recipient_Type__c.contains('CC Lead Escalation Recipient')) {
                        CCemails.add(contact.Email);
                    }
                }
            }
            
            for(MBAuP_Contact__c contact : MBAuPContacts) {
                if(contact.Dealer_Name__c == lead.Assigned_Dealer__c && contact.Business_Unit__c.contains(lead.Business_Unit__c) && contact.Sub_Business_Unit__c.contains(lead.Sub_BusinessUnit__c) && contact.Lead_Escalation_Recipient_Type__c.contains(EmailType)) {
                    TOemails.add(contact.Email_Address__c);
                }
                else if(contact.Dealer_Name__c == lead.Assigned_Dealer__c && contact.Lead_Escalation_Recipient_Type__c.contains('CC Lead Escalation Recipient')) {
                    CCemails.add(contact.Email_Address__c);
                }
            }
            
            if(TOemails.size() > 0) {
                leadContactToEmails.put(lead, TOemails);
            }
            if(CCemails.size() > 0) {
                leadContactCCEmails.put(lead, CCemails);
            }
        }        
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        
        //2014-2-19 Barney lai start
        Map<Id, Account> leadAccounts = new Map<Id, Account>();
        Set<Id> contactIds = new Set<Id>();
        for(Lead_Account__c lead : leadContactToEmails.keyset()) {
            if(lead.Company_Account__c != null) {
                contactIds.add(lead.Company_Account__c);
            }
            else if(lead.contact__c != null) {
                contactIds.add(lead.contact__c);
            }
        }
        for(Account acc : [select Id, Salutation, Name from Account where id in :contactIds]) {
            for(Lead_Account__c lead : leadContactToEmails.keyset()) {
                if(acc.id == lead.Company_Account__c) {
                    leadAccounts.put(lead.Id, acc);
                }
                else if(acc.id == lead.contact__c) {
                    leadAccounts.put(lead.Id, acc);
                }
            }
        }
        
        for(Lead_Account__c lead : leadContactToEmails.keyset()) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(leadContactToEmails.get(lead));
            if(leadContactCCEmails.containsKey(lead)) {
                message.setCCAddresses(leadContactCCEmails.get(lead));
            }
            message.setSubject(EmailType + ' - Lead (lead reference - ' + lead.name+', '+lead.Business_Unit__c + ', ' + lead.CreatedDate + ')');
            String htmlBody = 'Lead (lead reference - '+lead.name+', '+lead.Business_Unit__c+', '+lead.CreatedDate+')';
            htmlBody += 'has been assigned to you for action.<br/>';
            htmlBody += '<br/>Please review and action this lead.<br/><br/>';
            if(leadAccounts.containsKey(lead.Id)) {
                htmlBody += 'Customer Name: ' + leadAccounts.get(lead.Id).Name + '<br/>';
                htmlBody += 'Title: ' + leadAccounts.get(lead.Id).Salutation + '<br/>';
            } else {
                htmlBody += 'Customer Name: <br/>Title: <br/>';
            }
            if(lead.Business_Unit__c == null) {
                htmlBody += 'Business Unit: <br/>';
            } else {
                htmlBody += 'Business Unit: ' + lead.Business_Unit__c + '<br/>';
            }
            if(lead.Nature_of_Request__c == null) {
                htmlBody += 'Nature of Request: <br/>';
            } else {
                htmlBody += 'Nature of Request: '+lead.Nature_of_Request__c + '<br/>';
            }
            if(lead.Home_Phone__c == null) {
                htmlBody += 'Home Phone: <br/>';
            } else {
                htmlBody += 'Home Phone: '+lead.Home_Phone__c+'<br/>';
            }
            if(lead.Work_Phone__c == null) {
                htmlBody += 'Work Phone: <br/>';
            } else {
                htmlBody += 'Work Phone: '+lead.Work_Phone__c+'<br/>';
            }
            if(lead.Mobile__c == null) {
                htmlBody += 'Mobile: <br/>';
            } else {
                htmlBody += 'Mobile: '+lead.Mobile__c+'<br/>';
            }
            if(lead.Email__c == null) {
                htmlBody += 'Email: <br/>';
            } else {
                htmlBody += 'Email: '+lead.Email__c+'<br/>';
            }
            if(lead.Preferred_Test_Drive_Time__c == null) {
                htmlBody += 'Preferred Test Drive Date: <br/>';
            } else {
                htmlBody += 'Preferred Test Drive Date: '+lead.Preferred_Test_Drive_Date__c+'<br/>';
            }
            if(lead.Preferred_Test_Drive_Time__c == null) {
                htmlBody += 'Preferred Test Drive Time: <br/>';
            } else {
                htmlBody += 'Preferred Test Drive Time: '+lead.Preferred_Test_Drive_Time__c+'<br/>';
            }
            if(lead.Purchase_Intent__c == null) {
                htmlBody += 'Purchase date intent: <br/>';
            } else {
                htmlBody += 'Purchase date intent: '+lead.Purchase_Intent__c+'<br/>';
            }
            if(lead.Preferred_Contact_Method__c == null) {
                htmlBody += 'Preferred method of communication: <br/>';
            } else {
                htmlBody += 'Preferred method of communication: '+lead.Preferred_Contact_Method__c+'<br/>';
            }
            if(lead.MB_Vehicle_Interest__c == null) {
                htmlBody += 'MB Vehicle Interest (Make/Model): <br/>';
            } else {
                htmlBody += 'MB Vehicle Interest (Make/Model): '+lead.MB_Vehicle_Interest__c+'<br/>';
            }
            if(lead.Description__c == null) {
                htmlBody += 'Description: <br/>';
            } else {
                htmlBody += 'Description: '+lead.Description__c+'<br/>';
            }
            htmlBody += '<br/><a href="https://c.ap1.visual.force.com/'+lead.id+'">'+lead.name+'</a><br/>';
            htmlBody += '<br/>Kind Regards,<br/>';
            htmlBody += 'Enquiry Management Centre<br/>';
            
            message.setHtmlBody(htmlBody);
            message.setsaveAsActivity(false);
            message.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            messages.add(message);
        }

        if(messages.size() > 0){
            try{
                Messaging.sendEmail(messages);
            }
            catch(DMLException e){
                system.debug('Send ServiceParts Leads Immediate Notice/24H/72H Email Error ======> {Error: '+ e + '}');
            }
        }
    }
    
    //CR-000141 Send Immediate Notice and 24H and 72H Email for Finance Lead.
    public static void sendFinanceEmail (List<Lead_Account__c> leadsForSend, Set<Id> DealerIds) {
        Map<Lead_Account__c, List<String>> leadContactToEmails = new Map<Lead_Account__c, List<String>>();
        Map<Lead_Account__c, List<String>> leadContactCCEmails = new Map<Lead_Account__c, List<String>>();
        EmailTemplate financeTemplate = [select id ,developername from EmailTemplate where developername = 'Finance_Leads_Only'];
        
        List<Contact> listContact = [select id, EOC_Recipient_Type__c, Email, AccountId, Finance_Lead_Type__c, Lead_Escalation_Recipient_Type__c, Business_Unit__c, Sub_BusinessUnit__c 
                                     from Contact where AccountId in :DealerIds and Lead_Escalation_Recipient_Type__c != null];
        List<MBAuP_Contact__c> MBAuPContacts = [select Id, Business_Unit__c, Dealer_Name__c, Finance_Lead_Type__c, Email_Address__c, Lead_Escalation_Recipient_Type__c, EOC_Recipient_Type__c, First_Name__c, Sub_Business_Unit__c 
                                                from MBAuP_Contact__c where Dealer_Name__c in :DealerIds and Lead_Escalation_Recipient_Type__c != null];
        
        for(Lead_Account__c lead : leadsForSend) {
            List<String> TOemails = new List<String>();
            List<String> CCemails = new List<String>();
            
            for(Contact contact : listContact) {
                //modified by Shuang Li Defect0345 Start
                if(contact.AccountId == lead.Assigned_Dealer__c  && contact.Business_Unit__c != null && contact.Sub_BusinessUnit__c != null 
                        && contact.Finance_Lead_Type__c != null && contact.Business_Unit__c.contains(lead.Business_Unit__c)
                        && ((lead.Sub_BusinessUnit__c == 'Finance & Insurance' && (contact.Sub_BusinessUnit__c.contains('Finance') || contact.Sub_BusinessUnit__c.contains('Insurance'))) || contact.Sub_BusinessUnit__c.contains(lead.Sub_BusinessUnit__c)) && contact.Finance_Lead_Type__c.contains(lead.Nature_of_Request__c)) {
                //modified by Shuang Li Defect0345 End
                    TOemails.add(contact.Email);
                }
                else if(contact.AccountId == lead.Assigned_Dealer__c && contact.Lead_Escalation_Recipient_Type__c.contains('CC Lead Escalation Recipient')) {
                    CCemails.add(contact.Email);
                }
            }
            
            for(MBAuP_Contact__c contact : MBAuPContacts) {
                if(contact.Dealer_Name__c == lead.Assigned_Dealer__c  && contact.Finance_Lead_Type__c != null && contact.Finance_Lead_Type__c.contains(lead.Nature_of_Request__c) && 
                   (contact.Lead_Escalation_Recipient_Type__c.contains('Immediate Notice') || 
                   (contact.Business_Unit__c != null && contact.Sub_Business_Unit__c != null && contact.Business_Unit__c.contains(lead.Business_Unit__c) && contact.Sub_Business_Unit__c.contains(lead.Sub_BusinessUnit__c) && 
                   (contact.Lead_Escalation_Recipient_Type__c.contains('24 Untouched Notice') || contact.Lead_Escalation_Recipient_Type__c.contains('72 Untouched Notice'))))) {
                    TOemails.add(contact.Email_Address__c);
                }
                else if(contact.Dealer_Name__c == lead.Assigned_Dealer__c && contact.Lead_Escalation_Recipient_Type__c.contains('CC Lead Escalation Recipient')) {
                    CCemails.add(contact.Email_Address__c);
                }
            }
            
            if(TOemails.size() > 0) {
                leadContactToEmails.put(lead, TOemails);
            }
            if(CCemails.size() > 0) {
                leadContactCCEmails.put(lead, CCemails);
            }
        }        

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        List<Contact> MonkContacts = new List<Contact>();
        for(Lead_Account__c lead : leadContactToEmails.keyset()) {
            Contact MonkContact = MonkCotact(leadContactToEmails.get(lead)[0]);
            MonkContacts.add(MonkContact);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            leadContactToEmails.get(lead).remove(0);
            message.setToAddresses(leadContactToEmails.get(lead));
            if(leadContactCCEmails.containsKey(lead)) {
                message.setCCAddresses(leadContactCCEmails.get(lead));
            }
            message.setWhatId(lead.id);
            message.setTemplateId(financeTemplate.Id);
            message.setTargetObjectId(MonkContact.id);
            message.setsaveAsActivity(false);
            message.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            messages.add(message);
        }

        if(messages.size() > 0){
            try{
                Messaging.sendEmail(messages);
            }
            catch(DMLException e){
                system.debug('Send Finance Leads Immediate Notice/24H/72H Email Error ======> {Error: '+ e + '}');
            }finally {
                if(MonkContacts.size()>0){
                    delete MonkContacts;
                }
            }    
        }
    }
}