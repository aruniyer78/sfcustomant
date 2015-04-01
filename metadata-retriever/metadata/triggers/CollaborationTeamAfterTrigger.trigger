/*
    Type:       Trigger
    Purpose:    1. Login as the user added as Collaboration Team member, the Campaign can be viewed and searched.
                  If the user is added with Read/Write access, the user can edit the campaign as well.(US_AU-Cpn-003)
    User Story: US_AU-Cpn-003
    Used By:    
    ---------------------------------------------------------------
    History:
    
    02-Aug-2013 Chaos Huang (NTTData)  Created
*/
trigger CollaborationTeamAfterTrigger on Collaboration_Team__c  (after insert, after update, after delete) {
    
    if(!CustomSettingUtil.isEnabled('CollaborationTeamAfterTrigger')){
        return;
    }
        
    //List all CollaborationTeams for insert
    List<Collaboration_Team__c> newCollaborationTeams = new List<Collaboration_Team__c>();
    //List all CollaborationTeams for update
    List<Collaboration_Team__c> updatedCollaborationTeams = new List<Collaboration_Team__c>();
    //List all CollaborationTeams for delete
    List<Collaboration_Team__c> deletedCollaborationTeams = new List<Collaboration_Team__c>();

    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Collaboration_Team__c cbteam : Trigger.new) {
            if(Trigger.isInsert) {
                newCollaborationTeams.add(cbteam);
            }
            
            if(Trigger.isUpdate &&
                ((cbteam.Member_Name__c != Trigger.oldMap.get(cbteam.Id).Member_Name__c)
                || (cbteam.Access_Type__c != Trigger.oldMap.get(cbteam.Id).Access_Type__c))){
                updatedCollaborationTeams.add(cbteam);
            }
        }
    }
    
    if(Trigger.isDelete) {
        for(Collaboration_Team__c cbt : Trigger.old) {
            deletedCollaborationTeams.add(cbt);
        }
    }
    
    if(newCollaborationTeams.size() > 0) {
        CollaborationTeamHelper.insertCampaignSharing(newCollaborationTeams);
    }
    
    if(updatedCollaborationTeams.size() > 0) {
        CollaborationTeamHelper.updateCampaignSharing(updatedCollaborationTeams);
    }
    
    if(deletedCollaborationTeams.size() > 0) {
        CollaborationTeamHelper.deleteCampaignSharing(deletedCollaborationTeams);
    }
}