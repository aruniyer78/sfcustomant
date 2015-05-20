/*
 * Daimler CRM - Extension Platform
 */
package task.handler.configuration;

import java.util.ArrayList;
import java.util.List;

import task.handler.configuration.custom.Settings;

import com.sforce.soap.metadata.AccountCriteriaBasedSharingRule;
import com.sforce.soap.metadata.AccountOwnerSharingRule;
import com.sforce.soap.metadata.AccountSharingRules;
import com.sforce.soap.metadata.ApexClass;
import com.sforce.soap.metadata.ApexComponent;
import com.sforce.soap.metadata.ApexPage;
import com.sforce.soap.metadata.ApexTrigger;
import com.sforce.soap.metadata.AppMenu;
import com.sforce.soap.metadata.ApprovalProcess;
import com.sforce.soap.metadata.AssignmentRule;
import com.sforce.soap.metadata.AssignmentRules;
import com.sforce.soap.metadata.AutoResponseRule;
import com.sforce.soap.metadata.AutoResponseRules;
import com.sforce.soap.metadata.BusinessProcess;
import com.sforce.soap.metadata.CallCenter;
import com.sforce.soap.metadata.CampaignCriteriaBasedSharingRule;
import com.sforce.soap.metadata.CampaignOwnerSharingRule;
import com.sforce.soap.metadata.CampaignSharingRules;
import com.sforce.soap.metadata.CaseCriteriaBasedSharingRule;
import com.sforce.soap.metadata.CaseOwnerSharingRule;
import com.sforce.soap.metadata.CaseSharingRules;
import com.sforce.soap.metadata.Community;
import com.sforce.soap.metadata.CustomApplication;
import com.sforce.soap.metadata.CustomApplicationComponent;
import com.sforce.soap.metadata.CustomField;
import com.sforce.soap.metadata.CustomLabel;
import com.sforce.soap.metadata.CustomLabels;
import com.sforce.soap.metadata.CustomObject;
import com.sforce.soap.metadata.CustomObjectCriteriaBasedSharingRule;
import com.sforce.soap.metadata.CustomObjectOwnerSharingRule;
import com.sforce.soap.metadata.CustomObjectSharingRules;
import com.sforce.soap.metadata.CustomObjectTranslation;
import com.sforce.soap.metadata.CustomPageWebLink;
import com.sforce.soap.metadata.CustomPermission;
import com.sforce.soap.metadata.CustomTab;
import com.sforce.soap.metadata.Dashboard;
import com.sforce.soap.metadata.DataCategoryGroup;
import com.sforce.soap.metadata.Document;
import com.sforce.soap.metadata.EmailTemplate;
import com.sforce.soap.metadata.EscalationRule;
import com.sforce.soap.metadata.EscalationRules;
import com.sforce.soap.metadata.ExternalDataSource;
import com.sforce.soap.metadata.FieldSet;
import com.sforce.soap.metadata.Flow;
import com.sforce.soap.metadata.Group;
import com.sforce.soap.metadata.HomePageComponent;
import com.sforce.soap.metadata.HomePageLayout;
import com.sforce.soap.metadata.Layout;
import com.sforce.soap.metadata.Letterhead;
import com.sforce.soap.metadata.ListView;
import com.sforce.soap.metadata.Metadata;
import com.sforce.soap.metadata.Network;
import com.sforce.soap.metadata.PermissionSet;
import com.sforce.soap.metadata.Portal;
import com.sforce.soap.metadata.Profile;
import com.sforce.soap.metadata.Queue;
import com.sforce.soap.metadata.QuickAction;
import com.sforce.soap.metadata.RemoteSiteSetting;
import com.sforce.soap.metadata.Report;
import com.sforce.soap.metadata.ReportType;
import com.sforce.soap.metadata.Role;
import com.sforce.soap.metadata.SamlSsoConfig;
import com.sforce.soap.metadata.SharingReason;
import com.sforce.soap.metadata.StaticResource;
import com.sforce.soap.metadata.SynonymDictionary;
import com.sforce.soap.metadata.Translations;
import com.sforce.soap.metadata.ValidationRule;
import com.sforce.soap.metadata.WebLink;
import com.sforce.soap.metadata.Workflow;
import com.sforce.soap.metadata.WorkflowAlert;
import com.sforce.soap.metadata.WorkflowFieldUpdate;
import com.sforce.soap.metadata.WorkflowKnowledgePublish;
import com.sforce.soap.metadata.WorkflowOutboundMessage;
import com.sforce.soap.metadata.WorkflowRule;
import com.sforce.soap.metadata.WorkflowSend;
import com.sforce.soap.metadata.WorkflowTask;

/**
 * Manual Steps:
 * 1. remove quick actions from layouts and delete quick actions:
 *    a) Task Layout: "UpdatePriority", "UpdateStatus", "Defer", "EditDescription"
 *    b) Case (Support) Layout: "NewChildCase"
 *    c) "NewGroupMember" ???  
 * 2. delete weblinks from layouts:
 *    a) WebLink.Case.UpsellCrosssellOpportunity (Case (Support) Layout)
 *    b) WebLink.Campaign.ViewCampaignInfluenceReport (Campaign Layout)
 *    c) WebLink.Account.Billing (Account (Support) Layout)
 *    d) WebLink.Opportunity.DeliveryStatus (Opportunity (Support) Layout)
 *    e) WebLink.EpAdapterUnitOfWork__c.Delete_Multiple (???)
 * # 3. remove button "Delete_Multiple" from search layout "Units of Work List View" of customer object "EpAdapterUnitOfWork__c"
 * 
 * @author  xlehmf
 */
public class DeploymentConfiguration
{

  public List<DeploymentUnit> getConfigurations()
  {
    List<DeploymentUnit> duList = new ArrayList<>();
    duList.add(new DeploymentUnit(ApprovalProcess.class, "approvalProcesses"));

    List<Class<? extends Metadata>> escalationRuleChilds = new ArrayList<>();
    escalationRuleChilds.add(EscalationRule.class);
    duList.add(new DeploymentUnit(EscalationRules.class, escalationRuleChilds));
    
    List<Class<? extends Metadata>> assignmentRuleChilds = new ArrayList<>();
    assignmentRuleChilds.add(AssignmentRule.class);
    duList.add(new DeploymentUnit(AssignmentRules.class, assignmentRuleChilds));

    // sharing rules
    List<Class<? extends Metadata>> customObjectSharingRuleChilds = new ArrayList<>();
    customObjectSharingRuleChilds.add(CustomObjectOwnerSharingRule.class);
    customObjectSharingRuleChilds.add(CustomObjectCriteriaBasedSharingRule.class);
    duList.add(new DeploymentUnit(CustomObjectSharingRules.class, customObjectSharingRuleChilds, "customObjectSharingRules", "sharingRules") {

      /* 
       * The metadata entry is something like "smart_SSI__c.Sinotrust_to_Sinotrust". So just return "smart_SSI__c".
       */
      @Override
      public String getEntityName(String metadataEntry)
      {
        int idx = metadataEntry.indexOf(".");
        if (-1 != idx) {
          return metadataEntry.substring(0, idx);
        }
        return metadataEntry;
      }
      
    });
    
    List<Class<? extends Metadata>> campaignSharingRuleChilds = new ArrayList<>();
    campaignSharingRuleChilds.add(CampaignCriteriaBasedSharingRule.class);
    campaignSharingRuleChilds.add(CampaignOwnerSharingRule.class);
    duList.add(new DeploymentUnit(CampaignSharingRules.class, campaignSharingRuleChilds, "campaignSharingRules", "sharingRules") {

      /* 
       * The entity name is always "Campaign".
       */
      @Override
      public String getEntityName(String metadataEntry)
      {
        return "Campaign";
      }
      
    });

    List<Class<? extends Metadata>> caseSharingRuleChilds = new ArrayList<>();
    caseSharingRuleChilds.add(CaseOwnerSharingRule.class);
    caseSharingRuleChilds.add(CaseCriteriaBasedSharingRule.class);
    duList.add(new DeploymentUnit(CaseSharingRules.class, caseSharingRuleChilds, "caseSharingRules", "sharingRules") {

      /* 
       * The entity name is always "Case".
       */
      @Override
      public String getEntityName(String metadataEntry)
      {
        return "Case";
      }
      
    });
    
    List<Class<? extends Metadata>> accountSharingRuleChilds = new ArrayList<>();
    accountSharingRuleChilds.add(AccountCriteriaBasedSharingRule.class);
    accountSharingRuleChilds.add(AccountOwnerSharingRule.class);
    duList.add(new DeploymentUnit(AccountSharingRules.class, accountSharingRuleChilds, "accountSharingRules", "sharingRules") {

      /* 
       * The entity name is always "Account".
       */
      @Override
      public String getEntityName(String metadataEntry)
      {
        return "Account";
      }
      
    });

    List<Class<? extends Metadata>> workflowChilds = new ArrayList<>();
    workflowChilds.add(WorkflowRule.class);
    workflowChilds.add(WorkflowOutboundMessage.class);
    workflowChilds.add(WorkflowFieldUpdate.class);
    workflowChilds.add(WorkflowAlert.class);
    workflowChilds.add(WorkflowTask.class);
    workflowChilds.add(WorkflowKnowledgePublish.class);
    workflowChilds.add(WorkflowSend.class);
    duList.add(new DeploymentUnit(Workflow.class, workflowChilds, "workflows", "workflow"));

    duList.add(new DeploymentUnit(Layout.class, "layouts"));

    // -> Layout
    duList.add(new DeploymentUnit(QuickAction.class, "quickActions"));

    duList.add(new DeploymentUnit(CustomApplication.class, "applications", "app"));
    duList.add(new DeploymentUnit(CustomTab.class, "tabs", "tab"));

    duList.add(new DeploymentUnit(RemoteSiteSetting.class, "remoteSiteSettings", "remoteSite"));
    duList.add(new DeploymentUnitWithContent(ApexTrigger.class, "triggers", "trigger"));
    duList.add(new DeploymentUnitWithContent(ApexPage.class, "pages", "page"));
    duList.add(new DeploymentUnitWithContent(ApexComponent.class, "components", "component"));
    duList.add(new DeploymentUnitWithContentAndZoning(ApexClass.class, "classes", "cls"));

    duList.add(new DeploymentUnit(Profile.class, "profiles"));

    // need to be deleted from bottom up -> roles cannot be deleted if other roles report to it or users are assigned to that role
    duList.add(new DeploymentUnit(Role.class, "roles", "role"));

    duList.add(new DeploymentUnit(ExternalDataSource.class, "dataSources", "dataSource"));

    List<Class<? extends Metadata>> customerLabelChilds = new ArrayList<>();
    customerLabelChilds.add(CustomLabel.class);
    duList.add(new DeploymentUnit(CustomLabels.class, customerLabelChilds, "labels", "labels") {

      /* 
       * The entity name is always "CustomLabels".
       */
      @Override
      public String getEntityName(String metadataEntry)
      {
        return "CustomLabels";
      }
      
    });

    // -> customer objects
    duList.add(new DeploymentUnit(ReportType.class, "reportTypes"));

    // -> CustomObjects
    duList.add(new DeploymentUnit(CustomObjectTranslation.class, "objectTranslations", "objectTranslation"));
    
    List<Class<? extends Metadata>> customObjectChildren = new ArrayList<>();
    customObjectChildren.add(CustomField.class);
    customObjectChildren.add(BusinessProcess.class);
    customObjectChildren.add(WebLink.class);
    customObjectChildren.add(ValidationRule.class);
    customObjectChildren.add(SharingReason.class);
    customObjectChildren.add(ListView.class);
    customObjectChildren.add(FieldSet.class);
    duList.add(new DeploymentUnit(CustomObject.class, customObjectChildren, "objects", "object"));

    duList.add(new DeploymentUnit(Translations.class, "translations", "translation"));

    // -> HomePageComponent
    duList.add(new DeploymentUnit(HomePageLayout.class, "homePageLayouts"));
    // -> CustomPageWebLink
    duList.add(new DeploymentUnit(HomePageComponent.class, "homePageComponents"));
    duList.add(new DeploymentUnit(CustomPageWebLink.class, "weblinks", "weblink"));

    duList.add(new DeploymentUnitFolder(Report.class, "reports", "report", true));
    
    duList.add(new DeploymentUnit(Flow.class, "flows"));
    
    duList.add(new DeploymentUnitFolder(Dashboard.class, "dashboards", "dashboard"));
    
    duList.add(new DeploymentUnit(Queue.class, "queues"));

    List<Class<? extends Metadata>> autoResponseRulesChildren = new ArrayList<>();
    autoResponseRulesChildren.add(AutoResponseRule.class);
    duList.add(new DeploymentUnit(AutoResponseRules.class, autoResponseRulesChildren));
    
    duList.add(new DeploymentUnitFolderWithContent(EmailTemplate.class, "email", "email", true));


     duList.add(new DeploymentUnit(Settings.class));
    duList.add(new DeploymentUnit(CustomPermission.class, "customPermissions", "customPermission"));
    duList.add(new DeploymentUnit(Network.class, "networks"));
    duList.add(new DeploymentUnit(CallCenter.class, "callCenters"));
    duList.add(new DeploymentUnit(DataCategoryGroup.class, "datacategorygroups"));
    duList.add(new DeploymentUnit(PermissionSet.class, "permissionsets", "permissionset"));
    duList.add(new DeploymentUnit(CustomApplicationComponent.class, "customApplicationComponents"));
    duList.add(new DeploymentUnit(Group.class, "groups"));
    duList.add(new DeploymentUnit(SynonymDictionary.class, "synonymDictionaries"));
    duList.add(new DeploymentUnit(SamlSsoConfig.class, "samlssoconfigs", "samlssoconfig"));

    // -> Documents
    duList.add(new DeploymentUnit(Portal.class, "portals"));
    
    // -> Documents
    duList.add(new DeploymentUnit(Letterhead.class, "letterhead", "letter"));
    duList.add(new DeploymentUnit(AppMenu.class, "appMenus"));

    // -> DocumentFolder
    duList.add(new DeploymentUnitFolderWithContent(Document.class, "documents", null));

    duList.add(new DeploymentUnitWithContent(StaticResource.class, "staticresources", "resource"));

    duList.add(new DeploymentUnit(Community.class, "communities"));
    
    // Not handled metadata
    //    duList.add(new DeploymentUnit("AnalyticSnapshot", true));
    //    duList.add(new DeploymentUnit("SharingSet", true));
    //    duList.add(new DeploymentUnit("AuthProvider", true));
    // duList.add(new DeploymentUnit(CustomSite.class, "sites", "site")); // should be a manual task -> siteAdmin and subdomain need to be adjusted for target sandbox
    //    duList.add(new DeploymentUnit("ConnectedApp", true));
    //    duList.add(new DeploymentUnit("UiPlugin", true));
    // duList.add(new DeploymentUnit("InstalledPackage"));
    //    duList.add(new DeploymentUnit("UserSharingRules.UserMembershipSharingRule"));
    //    duList.add(new DeploymentUnit("UserSharingRules.UserCriteriaBasedSharingRule"));
    //        duList.add(new DeploymentUnit("UserSharingRules"));
    
    //    duList.add(new DeploymentUnit("ContactSharingRules.ContactOwnerSharingRule"));
    //    duList.add(new DeploymentUnit("ContactSharingRules.ContactCriteriaBasedSharingRule"));
    //        duList.add(new DeploymentUnit("ContactSharingRules"));
    //    duList.add(new DeploymentUnit("OpportunitySharingRules.OpportunityOwnerSharingRule"));
    //    duList.add(new DeploymentUnit("OpportunitySharingRules.OpportunityCriteriaBasedSharingRule"));
    //        duList.add(new DeploymentUnit("OpportunitySharingRules"));
    //    duList.add(new DeploymentUnit("LeadSharingRules.LeadCriteriaBasedSharingRule"));
    //    duList.add(new DeploymentUnit("LeadSharingRules.LeadOwnerSharingRule"));
    //        duList.add(new DeploymentUnit("LeadSharingRules"));
    // MatchingRules (MatchingRule)
    //    duList.add(new DeploymentUnit("PostTemplate", true));
    //    duList.add(new DeploymentUnit("FlexiPage", true));
    //    duList.add(new DeploymentUnit("SiteDotCom", true));
    //    duList.add(new DeploymentUnit("XOrgHub", true));
    //    duList.add(new DeploymentUnit("Scontrol", true));
    //    duList.add(new DeploymentUnit("ManagedTopics.ManagedTopic"));
    //    duList.add(new DeploymentUnit("ManagedTopics"));
    // AccountSettings, SecuritySettings, OpportunitySettings...
    
    return duList;
  }

}
