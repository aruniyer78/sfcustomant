/*
    Type:       Controller for TaskMassChangeOwener Visualforce page 
    Purpose:    Mass reassign tasks 
    User Story: CR-000185
    Used By:    TaskMassChangeOwener.page
    ---------------------------------------------------------------
    History:
    
    1. Barney lai Created on 2014-02-28
*/

public with sharing class TaskMassChangeOwner {
    public Vehicle__c task{set;get;}    
    private String [] arrObjIds;    
    
    public TaskMassChangeOwner(){        
        //Initalize the variables   
             
        task = new Vehicle__c();        
        Map<String, String> params = ApexPages.currentPage().getParameters();        
        String strObjIds = params.get('objIds');        
        arrObjIds = strObjIds.split(',');                  
    }            
        
    public void assignToOwnerClick(){    
        if(task.CROUser__c == null){            
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'New Owner Cannot be null.'));            
            return;        
        }
        List<Task> tasks = [Select Id, OwnerId From Task Where Id=:arrObjIds];        
        for(Task t : tasks){            
            t.OwnerId = task.CROUser__c;       
        }                
        if(tasks.size()>0){                        
            update tasks;         
        }    
    }
}