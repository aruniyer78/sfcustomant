/*
    Type:       CampaignMemberHistory Visualforce page 
    Purpose:    Search CampaignMemberHistory 
    User Story: CR-000151
    Used By:    CampaignMemberHistory.page
    ---------------------------------------------------------------
    History:
    
    1. Shuang Li Created on 2014-02-24

*/
public class CampaignMemberHistoryController {

    public CampaignMember campaignMemberInfo { get; set; }
    public List<Campaign_Member_History__c> theResults = new List<Campaign_Member_History__c>();
    
    public CampaignMemberHistoryController(ApexPages.StandardController controller) {
        campaignMemberInfo = (CampaignMember)controller.getRecord();
    }
    
    public List<Campaign_Member_History__c> getTheResults () {
        String campaignMemberInfoId = campaignMemberInfo.id;
        theResults  = [SELECT Action__c, Date_of_Change__c, User__r.Name, User__c FROM Campaign_Member_History__c where CampaignMember__c = :campaignMemberInfoId ORDER BY Date_of_Change__c DESC];
        return theResults;
    }      
}