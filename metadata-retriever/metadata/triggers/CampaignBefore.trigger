/*
    Purpose:    Update Approver field when Campaign is created.
    User Story: Qick wins - Campaign Brief 
    ---------------------------------------------------------------
    History:
        1. Sinow Created on 2015-Feb-03
*/
trigger CampaignBefore on Campaign (before insert, before update) {

    //Start  --- Update Approver field when Campaign is created or updated. 
    Set<Id> CamOwnerIds = new Set<Id>();
    
    for(Campaign cam : Trigger.new) {
        if(Trigger.isInsert) {
            CamOwnerIds.add(cam.OwnerId);
        }
        if(Trigger.isUpdate && cam.OwnerId != Trigger.oldMap.get(cam.Id).OwnerId) {
            CamOwnerIds.add(cam.OwnerId);
        }
    }
    Map<Id, User> OwnerId_MangerId = new Map<Id, User>([select Id, ManagerId from User where id in :CamOwnerIds]);
    for(Campaign cam : Trigger.new) {
        if(Trigger.isInsert && OwnerId_MangerId.containsKey(cam.OwnerId)) {
            cam.Approver__c = OwnerId_MangerId.get(cam.OwnerId).ManagerId;
        }
        if(Trigger.isUpdate && cam.OwnerId != Trigger.oldMap.get(cam.Id).OwnerId && OwnerId_MangerId.containsKey(cam.OwnerId)) {
            cam.Approver__c = OwnerId_MangerId.get(cam.OwnerId).ManagerId;
        }
    }
}