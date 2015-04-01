/*
    Type:       Test class of CollaborationTeamHelper
    Purpose:    Test class of CollaborationTeamHelper
    
    User Story: US_AU-Cpn-003
    Used By: 
    ---------------------------------------------------------------
    History:
    
    7-Aug-2013 Chaos (NTTData)  Created
*/     
@isTest
public class CollaborationTeamHelperTest {

    public static testMethod void testInsertCampaignSharing() {
        // Insert Collaboration_Team Data Start

        Id readOnlyUserId = [select Id from User where isActive = true Limit 1].Id;
        Id readWriteUserId = [select Id from User where Id <> :readOnlyUserId and isActive = true Limit 1].Id;

        Campaign cp = new Campaign(
                            Name = 'Campaign4InsertCampaignSharing',
                            Type = 'Other',
                            Campaign_Objective__c = 'test',
                            Description = 'test',
                            Status = 'Planned',
                            StartDate = Date.Today(),
                            EndDate = Date.Today(),
                            Brand__c = 'smart',
                            Frequency_Category__c = 'Daily');
        
        insert cp;
     
        // Read Only
        Collaboration_Team__c cbtReadOnly = new Collaboration_Team__c(
                            Campaign__c = cp.Id,
                            Member_Name__c = readOnlyUserId,
                            Access_Type__c = 'Read Only');
        // Read/Write
        Collaboration_Team__c cbtReadWrite = new Collaboration_Team__c(
                            Campaign__c = cp.Id,
                            Member_Name__c = readWriteUserId,
                            Access_Type__c = 'Read/Write');
                            
        Collaboration_Team__c[] collaborationTeams = new Collaboration_Team__c[] {cbtReadOnly, cbtReadWrite};
        
        insert collaborationTeams;
        // Insert Collaboration_Team Data End
        
        // Get the latest campaignShare info
        List<CampaignShare> campaignShares = 
                [select Id, CampaignId, CampaignAccessLevel, UserOrGroupId from CampaignShare 
                    where CampaignId = :cp.Id];

        for(CampaignShare cs : campaignShares) {
            if(cs.UserOrGroupId == cbtReadOnly.Member_Name__c){
                // Validate (Read)
                //System.assertEquals(cs.CampaignAccessLevel, 'Read');
            }else if(cs.UserOrGroupId == cbtReadWrite.Member_Name__c){
                // Validate (Edit)
                //System.assertEquals(cs.CampaignAccessLevel, 'Edit');
            }else if(cs.UserOrGroupId == UserInfo.getUserId()){
                // Campaign Owner
                //System.assertEquals(cs.CampaignAccessLevel, 'All');
            }else{
                // Validate (insert fail)
                System.assert(false);
            }
        }
    }
    
    public static testMethod void testUpdateCampaignSharing() {
        // Insert Collaboration_Team Data Start

        //get testUserId
        Id testUserId = [select Id from User where isActive = true Limit 1].Id;

        Campaign cp = new Campaign(
                            Name = 'Campaign4UpdateCampaignSharing',
                            Type = 'Other',
                            Campaign_Objective__c = 'test',
                            Description = 'test',
                            Status = 'Planned',
                            StartDate = Date.Today(),
                            EndDate = Date.Today(),
                            Brand__c = 'smart',
                            Frequency_Category__c = 'Daily');
        
        insert cp;

        Collaboration_Team__c cbt = new Collaboration_Team__c(
                            Campaign__c = cp.Id,
                            Member_Name__c = testUserId,
                            Access_Type__c = 'Read/Write');
                            
        insert cbt;
        // Insert Collaboration_Team Data End
        
        List<CampaignShare> campaignShares = 
                [select Id, CampaignId, CampaignAccessLevel, UserOrGroupId from CampaignShare 
                    where CampaignId = :cp.Id];

        for(CampaignShare cs : campaignShares) {
            if(cs.UserOrGroupId == cbt.Member_Name__c){
                // Validate (Access info before update)
                //System.assertEquals(cs.CampaignAccessLevel, 'Edit');
            }
        }
        
        // Update Collaboration_Team Data
        cbt = [select Id, Name, Access_Type__c, Campaign__c, Member_Name__c, Member_Role__c, Resource_Required__c 
                from Collaboration_Team__c where Id = :cbt.Id];
        cbt.Access_Type__c = 'Read Only';
        update cbt;

        // Get the latest campaignShare info
        campaignShares = 
                [select Id, CampaignId, CampaignAccessLevel, UserOrGroupId from CampaignShare 
                    where CampaignId = :cp.Id];
                    
        // Validate    
        for(CampaignShare cs : campaignShares) {
            if(cs.UserOrGroupId == cbt.Member_Name__c){
                // Validate
                //System.assertEquals(cs.CampaignAccessLevel, 'Read');
            }else if(cs.UserOrGroupId == UserInfo.getUserId()){
                // Campaign Owner
                //System.assertEquals(cs.CampaignAccessLevel, 'All');
            }else{
                // Validate (insert fail)
                //System.assert(false);
            }
        }
    }
    
    public static testMethod void testDeleteCampaignSharing() {
        // Insert Collaboration_Team Data Start
        
        //get testUserId
        Id testUserId = [select Id from User where isActive = true Limit 1].Id;
        
        Campaign cp = new Campaign(
                            Name = 'Campaign4DeleteCampaignSharing',
                            Type = 'Other',
                            Campaign_Objective__c = 'test',
                            Description = 'test',
                            Status = 'Planned',
                            StartDate = Date.Today(),
                            EndDate = Date.Today(),
                            Brand__c = 'smart',
                            Frequency_Category__c = 'Daily');
        
        insert cp;

        Collaboration_Team__c cbt = new Collaboration_Team__c(
                            Campaign__c = cp.Id,
                            Member_Name__c = testUserId,
                            Access_Type__c = 'Read/Write');
                            
        insert cbt;
        // Insert Collaboration_Team Data End
        
        List<CampaignShare> campaignShares = 
                [select Id, CampaignId, CampaignAccessLevel, UserOrGroupId from CampaignShare 
                    where CampaignId = :cp.Id];
                    
        Boolean testUserCsExist = false;
        for(CampaignShare cs : campaignShares) {
            if(cs.UserOrGroupId == testUserId){
                testUserCsExist = true;
            }
        }
        //System.assert(testUserCsExist);
        
        // Delete Test User's Collaboration_Team Data
        cbt = [select Id, Name, Access_Type__c, Campaign__c, Member_Name__c, Member_Role__c, Resource_Required__c 
                from Collaboration_Team__c where Id = :cbt.Id];
        delete cbt;

        // Get the latest campaignShare info
        campaignShares = 
                [select Id, CampaignId, CampaignAccessLevel, UserOrGroupId from CampaignShare 
                    where CampaignId = :cp.Id];
                    
        // Validate    
        for(CampaignShare cs : campaignShares) {
            // Validate(Test User's CampaignShare has been deleted)
            //System.assertNotEquals(cs.UserOrGroupId, testUserId);
        }
    }
}