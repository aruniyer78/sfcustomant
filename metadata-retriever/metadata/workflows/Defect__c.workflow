<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Issue_Assignment_Notification</fullName>
        <description>Issue Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Defect_Assignment_Notification</template>
    </alerts>
    <rules>
        <fullName>Defect Assignment Notification</fullName>
        <actions>
            <name>Issue_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When assign a defect to a user, send a notification email at the same time.</description>
        <formula>ISNEW() || ISCHANGED( Assigned_To__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
