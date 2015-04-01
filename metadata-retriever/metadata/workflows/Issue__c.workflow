<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Issue_Assignment_Notification</fullName>
        <description>Issue Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Assign_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Issue_Assignment_Notification</template>
    </alerts>
    <rules>
        <fullName>Issue Assignment Notification</fullName>
        <actions>
            <name>Issue_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Assign_To__c )||ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
