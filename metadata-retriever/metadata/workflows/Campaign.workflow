<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Campaign_has_been_approved</fullName>
        <description>Campaign has been approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Campaign_approved_notification</template>
    </alerts>
    <alerts>
        <fullName>Campaign_has_been_rejected</fullName>
        <description>Campaign has been rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Campaign_rejected_notification</template>
    </alerts>
    <alerts>
        <fullName>Campaign_not_approved_Notification</fullName>
        <description>Campaign not approved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Campaign_approval_notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_to_Approved</fullName>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Update to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Rejected</fullName>
        <field>Status</field>
        <literalValue>Rejected</literalValue>
        <name>Update to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Submit_for_approval</fullName>
        <field>Status</field>
        <literalValue>Submit for approval</literalValue>
        <name>Update to Submit for approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Notification for not approval</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>equals</operation>
            <value>Submit for approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Creative Brief,Data Brief,Internal Campaign Brief</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Campaign_not_approved_Notification</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Campaign_not_approved_Notification</name>
                <type>Alert</type>
            </actions>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
