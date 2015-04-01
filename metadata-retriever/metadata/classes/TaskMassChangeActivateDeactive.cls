/*
    Type:       Controller for TaskMassChangeActivateDeactive Visualforce page 
    Purpose:    Mass reassign tasks 
    User Story: CR-000185
    Used By:    TaskMassChangeActivateDeactive.page
    ---------------------------------------------------------------
    History:
    
    1. Barney lai Created on 2014-02-28
*/

public with sharing class TaskMassChangeActivateDeactive {
    public Task task{set;get;}    
    
    public TaskMassChangeActivateDeactive (){        
        //Initalize the variables             
        task = new Task(recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Welcome Call').getRecordTypeId());                     
    }            
        
    public void Activate(){    
        if(task.ownerId == null){            
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'New Owner Cannot be null.'));            
            return;        
        } 
        List<User> user = [select id, Active_Inactive_Flag__c from User where id = :task.ownerId];
        user[0].Active_Inactive_Flag__c = true;
        UserUpdate(user);
    }
    
    public void Deactivate(){    
        if(task.ownerId == null){            
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'New Owner Cannot be null.'));            
            return;        
        }  
        List<User> user = [select id, Active_Inactive_Flag__c from User where id = :task.ownerId];
        user[0].Active_Inactive_Flag__c = false;
        UserUpdate(user);
        List<Task> tasks = new List<Task>();
        List<User> users = new List<User>();
        List<User> RTLusers = new List<User>();
        tasks = [select id, ownerId from Task where ownerId = :user[0].id and status != 'Complete'];
        users = [select id, name from User where Active_Inactive_Flag__c = true and profile.name = 'Customer Retention' and UserRole.name like '%Customer Retention Office%'];
        RTLusers = [select id, name from User where UserRole.name = 'Remarketing Team Lead'];
        Integer usersNum = users.size();
        Integer RTLusersNum = RTLusers.size();
        Integer i = 0;
        for(Task t : tasks) {
            if(usersNum == 0) {
                t.ownerId = RTLusers[i].id;
                i++;
                if(i >= RTLusersNum) {
                    i = 0;
                }
            } else {
                t.ownerId = users[i].id;
                i++;
                if(i >= usersNum) {
                    i = 0;
                }
            }
        }
        if(tasks.size() > 0) {
            UserUpdate(tasks);
        }
    }
    
    public void UserUpdate(List<Sobject> obj){
        try {
            update obj;
            system.debug('-----'+user.Active_Inactive_Flag__c);
        } catch (Exception ex) {
            system.debug('Error message:'+ex.getmessage());
        }
    }
}