/*
    Type:       Utility for Contract
    Purpose:    For creation Task and sharing the task to CROs 
    User Story: CR-000185
    Used By:    
    ---------------------------------------------------------------
    History:
        1. Barney Lai Created on 2014-02-25
*/

global class ScheduledSharingContractToCROs implements Schedulable{

    private static final Id AnnualCallRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Annual Call').getRecordTypeId();
    private static final Id EOCCallRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('EOC Call').getRecordTypeId();
    private static final Id WelcomeCallRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Welcome Call').getRecordTypeId();
    private static final Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    

    global void execute(SchedulableContext SC) {
        List<Contract> contracts = new List<Contract>();
        List<Contract> Welcontracts = new List<Contract>();
        List<Contract> Ann1contracts = new List<Contract>();
        List<Contract> Ann2contracts = new List<Contract>();
        List<Contract> Ann3contracts = new List<Contract>();
        List<Contract> EOC1contracts = new List<Contract>();
        List<Contract> EOC2contracts = new List<Contract>();
        List<Contract> EOC3contracts = new List<Contract>();
        List<User> users = new List<User>();
        List<User> RTLusers = new List<User>();
        List<Task> preTask = new List<Task>();
        List<Contract> preContract = new List<Contract>();
        List<Id> accountIds = new List<Id>();
        Map<Id, Id> accountIdContactId = new Map<Id, Id>();
        Map<Id, List<String>> accountIdPhone = new Map<Id, List<String>>();
        List<String> contractStatus = new List<String>{'Current','Default-Collection Officer','Default-External Agent','Overdue'};
        
        contracts = [select id, StartDate, Contract_End_Date__c, AccountId, Welcome_Call__c, Annual_Call__c, EOC_Call__c, 
                     Welcome_Call_Task__c, Annual_Call_Task_1_del__c, Annual_Call_Task_2_del__c, Annual_Call_Task_3_del__c, 
                     EOC_Call_Task_1_del__c, EOC_Call_Task_2_del__c, EOC_Call_Task_3_del__c from Contract 
                     where GFV__c = true and Contract_Status__c in :contractStatus];
        
        for(Contract con : contracts) {
            Date today = Date.today();
            Date startday = con.StartDate;
            Date endday = con.Contract_End_Date__c;
            
            accountIds.add(con.AccountId);
            accountIdContactId.put(con.AccountId, null);
            List<String> phone = new List<String>();
            phone.add('');
            phone.add('');
            phone.add('');
            accountIdPhone.put(con.AccountId, phone);
            boolean flag = false;
                 
            if(con.Welcome_Call__c == true && con.Welcome_Call_Task__c == true) {
                Welcontracts.add(con);
                con.Welcome_Call_Task__c = false;
                flag = true;
            }
            if(con.Annual_Call__c == true && con.Annual_Call_Task_1_del__c == true) {
                Ann1contracts.add(con);
                con.Annual_Call_Task_1_del__c = false;
                flag = true;
            }
            if(con.Annual_Call__c == true && con.Annual_Call_Task_2_del__c == true) {
                Ann2contracts.add(con);
                con.Annual_Call_Task_2_del__c = false;
                flag = true;
            }
            if(con.Annual_Call__c == true && con.Annual_Call_Task_3_del__c == true){
                Ann3contracts.add(con);
                con.Annual_Call_Task_3_del__c = false;
                flag = true;
            }
            if(con.EOC_Call__c == true && con.EOC_Call_Task_1_del__c == true) {
                EOC1contracts.add(con);
                con.EOC_Call_Task_1_del__c = false;
                flag = true;
            }
            if(con.EOC_Call__c == true && con.EOC_Call_Task_2_del__c == true) {
                EOC2contracts.add(con);
                con.EOC_Call_Task_2_del__c = false;
                flag = true;
            }
            if(con.EOC_Call__c == true && con.EOC_Call_Task_3_del__c == true) {
                EOC3contracts.add(con);
                con.EOC_Call_Task_3_del__c = false;
                flag = true;
            }
            if(flag == true) {
                preContract.add(con);
            }
        }
        
        for(Account acc : [select id, PersonContactId, Individual_Home_Phone__c, Phone, PersonMobilePhone from Account where Id in :accountIds and RecordTypeId = :personAccountRT]) {
            accountIdContactId.put(acc.id, acc.PersonContactId);
            List<String> phone = new List<String>();
            phone.add(acc.Individual_Home_Phone__c);
            phone.add(acc.Phone);
            phone.add(acc.PersonMobilePhone);
            accountIdPhone.put(acc.id, phone);
        }
        
        users = [select id, name from User where Active_Inactive_Flag__c = true and profile.name = 'Customer Retention' and UserRole.name like '%Customer Retention Office%'];
        RTLusers = [select id, name from User where UserRole.name = 'Remarketing Team Lead'];
        if(users.size() == 0) {
            users = RTLusers;
        }
        Integer usersNum = users.size();
        Integer RTLusersNum = RTLusers.size();
        Integer i = 0;
        Integer j = 0;
        //Welcome Call
        for(Contract con : Welcontracts) {
            Id contactid = null;
            contactid = accountIdContactId.get(con.accountId);
            List<String> phone = new List<String>();
            phone = accountIdPhone.get(con.accountId);
            if(phone[0] == null && phone[1] == null && phone[2] == null) {
                Task t = createTask(con, RTLusers[j], 'Welcome Call', contactid, phone, WelcomeCallRT);
                preTask.add(t);
                j++;
                if(j >= RTLusersNum) {
                    j = 0;
                }
            } else {
                Task t = createTask(con, users[i], 'Welcome Call', contactid, phone, WelcomeCallRT);
                preTask.add(t);
                i++;
                if(i >= usersNum) {
                    i = 0;
                }
            }
        }
        //Annual Call
        i = 0;
        for(Contract con : Ann1contracts) {
            Id contactid = null;
            contactid = accountIdContactId.get(con.accountId);
            List<String> phone = new List<String>();
            phone = accountIdPhone.get(con.accountId);
            if(phone[0] == null && phone[1] == null && phone[2] == null) {
                Task t = createTask(con, RTLusers[j], 'First Year Annual Call', contactid, phone, AnnualCallRT);
                preTask.add(t);
                j++;
                if(j >= RTLusersNum) {
                    j = 0;
                }
            } else {
                Task t = createTask(con, users[i], 'First Year Annual Call', contactid, phone, AnnualCallRT);
                preTask.add(t);
                i++;
                if(i >= usersNum) {
                    i = 0;
                }
            }
        }
        for(Contract con : Ann2contracts) {
            Id contactid = null;
            contactid = accountIdContactId.get(con.accountId);
            List<String> phone = new List<String>();
            phone = accountIdPhone.get(con.accountId);
            if(phone[0] == null && phone[1] == null && phone[2] == null) {
                Task t = createTask(con, RTLusers[j], 'Second Year Annual Call', contactid, phone, AnnualCallRT);
                preTask.add(t);
                j++;
                if(j >= RTLusersNum) {
                    j = 0;
                }
            } else {
                Task t = createTask(con, users[i], 'Second Year Annual Call', contactid, phone, AnnualCallRT);
                preTask.add(t);
                i++;
                if(i >= usersNum) {
                    i = 0;
                }
            }
        }
        for(Contract con : Ann3contracts) {
            Id contactid = null;
            contactid = accountIdContactId.get(con.accountId);
            List<String> phone = new List<String>();
            phone = accountIdPhone.get(con.accountId);
            if(phone[0] == null && phone[1] == null && phone[2] == null) {
                Task t = createTask(con, RTLusers[j], 'Third Year Annual Call', contactid, phone, AnnualCallRT);
                preTask.add(t);
                j++;
                if(j >= RTLusersNum) {
                    j = 0;
                }
            } else {
                Task t = createTask(con, users[i], 'Third Year Annual Call', contactid, phone, AnnualCallRT);
                preTask.add(t);
                i++;
                if(i >= usersNum) {
                    i = 0;
                }
            }
        }
        //EOC Call
        i = 0;
        for(Contract con : EOC1contracts) {
            Id contactid = null;
            contactid = accountIdContactId.get(con.accountId);
            List<String> phone = new List<String>();
            phone = accountIdPhone.get(con.accountId);
            if(phone[0] == null && phone[1] == null && phone[2] == null) {
                Task t = createTask(con, RTLusers[j], 'First End of Contract Call', contactid, phone, EOCCallRT);
                preTask.add(t);
                j++;
                if(j >= RTLusersNum) {
                    j = 0;
                }
            } else {
                Task t = createTask(con, users[i], 'First End of Contract Call', contactid, phone, EOCCallRT);
                preTask.add(t);
                i++;
                if(i >= usersNum) {
                    i = 0;
                }
            }
        }
        for(Contract con : EOC2contracts) {
            Id contactid = null;
            contactid = accountIdContactId.get(con.accountId);
            List<String> phone = new List<String>();
            phone = accountIdPhone.get(con.accountId);
            if(phone[0] == null && phone[1] == null && phone[2] == null) {
                Task t = createTask(con, RTLusers[j], 'Second End of Contract Call', contactid, phone, EOCCallRT);
                preTask.add(t);
                j++;
                if(j >= RTLusersNum) {
                    j = 0;
                }
            } else {
                Task t = createTask(con, users[i], 'Second End of Contract Call', contactid, phone, EOCCallRT);
                preTask.add(t);
                i++;
                if(i >= usersNum) {
                    i = 0;
                }
            }
        }
        for(Contract con : EOC3contracts) {
            Id contactid = null;
            contactid = accountIdContactId.get(con.accountId);
            List<String> phone = new List<String>();
            phone = accountIdPhone.get(con.accountId);
            if(phone[0] == null && phone[1] == null && phone[2] == null) {
                Task t = createTask(con, RTLusers[j], 'Final End of Contract Call', contactid, phone, EOCCallRT);
                preTask.add(t);
                j++;
                if(j >= RTLusersNum) {
                    j = 0;
                }
            } else {
                Task t = createTask(con, users[i], 'Final End of Contract Call', contactid, phone, EOCCallRT);
                preTask.add(t);
                i++;
                if(i >= usersNum) {
                    i = 0;
                }
            }
        }
        
        try {
            if(preTask.size() > 0) {
                insert preTask;
            }
            if(preContract.size() > 0) {
                update preContract;
            }
        } catch (Exception ex) {
            system.debug('Insert Update Error:' + ex.getMessage());
        }
        
    }
    
    public Task createTask (Contract con, User user, String str, Id conId, List<String> phone, Id RTId) {
        Task task = new Task();
        task.ownerId = user.id;
        task.subject = str;
        task.whatId = con.id;
        task.Reason__c = 'Initial Attempt';
        task.Status = 'Not Started';
        task.ActivityDate = Date.today();
        task.whoId = conId;
        task.Priority = 'Normal';
        task.Description = '';
        task.Home_Phone__c = phone[0];
        task.Work_Phone__c = phone[1];
        task.Mobile__c = phone[2];
        task.RecordTypeId = RTId;
        if(str == 'First End of Contract Call' || str == 'Second End of Contract Call' || str == 'Final End of Contract Call') {
            task.Effective_Date__c = con.Contract_End_Date__c;
        } else {
            task.Effective_Date__c = con.StartDate;
        }
        return task;
    }
}