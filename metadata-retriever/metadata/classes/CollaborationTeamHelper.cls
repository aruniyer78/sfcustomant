/*
    Type:       Utility for CollaborationTeamAfterInsertUpdate
    Purpose:    1. Login as the user added as Collaboration Team member, the Campaign can be viewed and searched.
                  If the user is added with Read/Write access, the user can edit the campaign as well.(US_AU-Cpn-003)
    User Story: US_AU-Cpn-003
    Used By:    TriggerCollaborationTeamAfterInsertUpdateDelete
    ---------------------------------------------------------------
    History:
    
    02-Aug-2013 Chaos Huang (NTTData)  Created
*/
public class CollaborationTeamHelper {

    // Insert CampaignShare records
    public static void insertCampaignSharing(List<Collaboration_Team__c> collaborationTeams) {
        //List all CollaborationTeams for insert
        List<CampaignShare> campaignShareToInsert = cbTeamsToCampaignShares(collaborationTeams);
        
        if(campaignShareToInsert.size() > 0) {
            DBUtil.insertSobjects(campaignShareToInsert);
        }
    }
    
    // Update CampaignShare records
    public static void updateCampaignSharing(List<Collaboration_Team__c> collaborationTeams) {

        //List all CollaborationTeams for insert
        List<CampaignShare> campaignShareToInsert = cbTeamsToCampaignShares(collaborationTeams);
        
        if(campaignShareToInsert.size() > 0) {
            deleteCampaignSharing(collaborationTeams);
            DBUtil.insertSobjects(campaignShareToInsert);
        }
    }

    // Delete CampaignShare records
    public static void deleteCampaignSharing(List<Collaboration_Team__c> collaborationTeams) {
    
        //List all CollaborationTeams for delete
        List<CampaignShare> campaignShareToDelete = new List<CampaignShare>();
        // Get all Campaign ids for update CampaignShare
        Set<Id> campaignIds = new Set<Id>();
        // Get all User ids for update CampaignShare
        Set<Id> userIds = new Set<Id>();
        
        for(Collaboration_Team__c cbteam : collaborationTeams) {
            campaignIds.add(cbteam.Campaign__c);
            userIds.add(cbteam.Member_Name__c);
        }
        
        List<CampaignShare> campaignShareToUpdateTmp = 
                [select Id, CampaignId, UserOrGroupId from CampaignShare 
                    where CampaignId in :campaignIds and UserOrGroupId in :userIds];
                    
        for(Collaboration_Team__c cbteam : collaborationTeams) {
            for(CampaignShare cs : campaignShareToUpdateTmp) {
                if(cbteam.Campaign__c == cs.CampaignId && cbteam.Member_Name__c == cs.UserOrGroupId){
                    campaignShareToDelete.add(cs);
                }
            }
        }
        
        if(campaignShareToDelete.size() > 0) {
            DBUtil.deleteSobjects(campaignShareToDelete);
        }
    }

    private static List<CampaignShare> cbTeamsToCampaignShares(List<Collaboration_Team__c> collaborationTeams) {
        List<CampaignShare> campaignShares = new List<CampaignShare>();
        
        Set<ID> campaignOwnerid = new Set<ID>();
        Set<ID> ctCampaignid = new Set<ID>();
        List<Campaign> campaigns = new List<Campaign>();
        for(Collaboration_Team__c ct : collaborationTeams) {
            ctCampaignid.add(ct.Campaign__c);
        }
        campaigns = [select id, ownerid from Campaign where id in :ctCampaignid];
        for(Campaign c : campaigns) {
            campaignOwnerid.add(c.ownerid);
        }
        
        String campaignAccessLevel = 'Read';
        
        for(Collaboration_Team__c cbteam : collaborationTeams) {
            if(cbteam.Access_Type__c.equals('Read/Write')){
                campaignAccessLevel = 'Edit';
            }else{
                campaignAccessLevel = 'Read';
            }
            if(!campaignOwnerid.contains(cbteam.Member_Name__c)) {
                campaignShares.add(
                    new CampaignShare(CampaignId = cbteam.Campaign__c, 
                                  CampaignAccessLevel = campaignAccessLevel, 
                                  UserOrGroupId = cbteam.Member_Name__c));
            }
        }
        return campaignShares;
    }
}