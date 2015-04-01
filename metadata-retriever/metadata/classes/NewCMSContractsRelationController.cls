/*
    Purpose:    Return to Case detail when save the new CMS record
    User Story: quick wins FOS Complaint

    Used By:    
    ---------------------------------------------------------------
    History:

    2015-02-26 Sinow Created
*/
public class NewCMSContractsRelationController {
    
    public CMS_Contracts_Relation__c CMSContractsRelationInfo {get; set;}
    
    public NewCMSContractsRelationController(ApexPages.StandardController stdController) {
        
        CMSContractsRelationInfo = (CMS_Contracts_Relation__c)stdController.getRecord();
        CMSContractsRelationInfo.OwnerId = UserInfo.getUserId();
    }
    
    public pageReference saveCMS() {
        try {
            insert CMSContractsRelationInfo;
        }
        catch(exception ex) {
            return null;
        }
        return new PageReference('/' + CMSContractsRelationInfo.CRM1_Case_No__c);
    }
    
    public pageReference cancelCMS() {
        return new PageReference('/' + CMSContractsRelationInfo.CRM1_Case_No__c);
    }
}