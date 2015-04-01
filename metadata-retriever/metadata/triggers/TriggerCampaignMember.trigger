/*
    Type:       Trigger
    Purpose:    Generate CampaignMember History LOG 
    User Story: CR-000151
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1.  Shuang Li Created on 2014-02-24
*/
trigger TriggerCampaignMember on CampaignMember (after insert, after update) {

    if(!CustomSettingUtil.isEnabled('TriggerCampaignMember')){
        return;
    }
    
    Id cId;
    Datetime DateofChange;
    Id us = Userinfo.getUserId();
    String action = '';
    
    for(CampaignMember campaignMember : Trigger.new) {
        if(trigger.isInsert){
            cId = campaignMember.Id;
            DateofChange = campaignMember.LastModifiedDate;
            action = 'Created.';
        }else if(trigger.isUpdate){
            action = 'Changed ';
            if(trigger.oldMap.get(campaignMember.id).Lodgement_Date__c != campaignMember.Lodgement_Date__c){
                cId = campaignMember.Id;
                action = action + 'Lodgement Date to ' + datetime.newInstance(campaignMember.Lodgement_Date__c, time.newInstance(0,0,0,0)).format('yyyy/MM/dd') +'\n';
            }
            if (trigger.oldMap.get(campaignMember.id).Status != campaignMember.Status){
                cId = campaignMember.Id;
                action = action + 'Status to ' + campaignMember.Status;
            }
            DateofChange = campaignMember.LastModifiedDate;
        }
        
        // LOG Record
        Campaign_Member_History__c cmh = new Campaign_Member_History__c();
        cmh.CampaignMember__c = cId;    // CampaignMember id
        cmh.Action__c = action;     // What operation
        cmh.User__c = us;           // Who makes the operation
        cmh.Date_of_Change__c = DateofChange;           // Who makes the operation
        if(cId != null){
            insert cmh;
        }
    }
}