/*
    Type:       Page Controller
    ---------------------------------------------------------------
    History:
    
    1. 2014-2-18 Created By Justin Yu
*/
trigger PreOrderBeforeTrigger on PreOrder__c (before insert, before update) {
    for(PreOrder__c preOrder : Trigger.new){
        if(preOrder.Status__c == 'Closed'){
            preOrder.ClosedDate__c = System.today();
        }
    }
}