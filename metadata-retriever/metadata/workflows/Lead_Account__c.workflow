<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Close_Date_Update</fullName>
        <field>Close_Date__c</field>
        <formula>Today()</formula>
        <name>Close Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_24H_Untouched</fullName>
        <description>/*
Created By Polaris Yu 2013-8-27
Function: Checked the &apos;*24H Untouched&apos; field for Qualified Vehicle Leads and Service/Parts Leads if they haven&apos;t been updated for 24 hours
Used By: Workflow Rule - Lead Auto Check &apos;*24H Untouched&apos;
*/</description>
        <field>X24H_Untouched__c</field>
        <literalValue>1</literalValue>
        <name>Update 24H Untouched</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_72H_Untouched</fullName>
        <description>/* 
Created By Polaris Yu 2013-8-29
Function: Checked the &apos;*72H Untouched&apos; field for Qualified Vehicle Leads and Service/Parts Leads if they haven&apos;t been updated for 72 hours 
Used By: Workflow Rule - Lead Auto Check &apos;*72H Untouched&apos; 
*/</description>
        <field>X72H_Untouched__c</field>
        <literalValue>1</literalValue>
        <name>Update 72H Untouched</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Finance_Send_Email_Before_15_Days</fullName>
        <field>Is_Finance_Send_Email_Before_15_Days__c</field>
        <literalValue>1</literalValue>
        <name>Update Finance Send Email Before 15 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Finance_Send_Email_Before_20_Days</fullName>
        <field>Is_Finance_Send_Email_Before_20_Days__c</field>
        <literalValue>1</literalValue>
        <name>Update Finance Send Email Before 20 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Finance_Send_Email_Before_45_Days</fullName>
        <field>Is_Fleet_Send_Email_Before_45_Days__c</field>
        <literalValue>1</literalValue>
        <name>Update Finance Send Email Before 45 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Finance_Send_Email_Before_60_Days</fullName>
        <field>Is_Finance_Send_Email_Before_60_Days__c</field>
        <literalValue>1</literalValue>
        <name>Update Finance Send Email Before 60 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Fleet_Send_Email_Before_15_Days</fullName>
        <field>Is_Fleet_Send_Email_Before_15_Days__c</field>
        <literalValue>1</literalValue>
        <name>Update Fleet Send Email Before 15 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Fleet_Send_Email_Before_20_Days</fullName>
        <field>Is_Fleet_Send_Email_Before_20_Days__c</field>
        <literalValue>1</literalValue>
        <name>Update Fleet Send Email Before 20 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Fleet_Send_Email_Before_60_Days</fullName>
        <field>Is_Fleet_Send_Email_Before_60_Days__c</field>
        <literalValue>1</literalValue>
        <name>Update Fleet Send Email Before 60 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Finance Send Notification Email To Dealer Recipients Before 15 Days</fullName>
        <actions>
            <name>Update_Finance_Send_Email_Before_15_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  RecordType.DeveloperName = &apos;Finance_Lead&apos;,   Status_Category__c = &apos;Open&apos;,   ISPICKVAL(Lead_Source__c, &apos;End of Contract&apos;), Existing_Contract__r.EndDate = TODAY() + 15 ,  Is_Finance_Send_Email_Before_15_Days__c = FALSE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Finance Send Notification Email To Dealer Recipients Before 20 Days</fullName>
        <actions>
            <name>Update_Finance_Send_Email_Before_20_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  RecordType.DeveloperName = &apos;Finance_Lead&apos;,   Status_Category__c = &apos;Open&apos;,   ISPICKVAL(Lead_Source__c, &apos;End of Contract&apos;), Existing_Contract__r.EndDate = TODAY() + 20 ,  Is_Finance_Send_Email_Before_20_Days__c = FALSE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Finance Send Notification Email To Dealer Recipients Before 45 Days</fullName>
        <actions>
            <name>Update_Finance_Send_Email_Before_45_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  RecordType.DeveloperName = &apos;Finance_Lead&apos;,   Status_Category__c = &apos;Open&apos;,   ISPICKVAL(Lead_Source__c, &apos;End of Contract&apos;), Existing_Contract__r.EndDate = TODAY() + 45 ,  Is_Fleet_Send_Email_Before_45_Days__c = FALSE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Finance Send Notification Email To Dealer Recipients Before 60 Days</fullName>
        <actions>
            <name>Update_Finance_Send_Email_Before_60_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  RecordType.DeveloperName = &apos;Finance_Lead&apos;,   Status_Category__c = &apos;Open&apos;,   ISPICKVAL(Lead_Source__c, &apos;End of Contract&apos;), Existing_Contract__r.EndDate = TODAY() + 60 ,  Is_Finance_Send_Email_Before_60_Days__c = FALSE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Fleet Send Notification Email To Dealer Recipients Before 15 Days</fullName>
        <actions>
            <name>Update_Fleet_Send_Email_Before_15_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  RecordType.DeveloperName = &apos;Fleet_Lead&apos;,   Status_Category__c = &apos;Open&apos;,   ISPICKVAL(Lead_Source__c, &apos;End of Contract&apos;), Existing_Contract__r.EndDate = TODAY() + 15 ,  Is_Fleet_Send_Email_Before_15_Days__c = FALSE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Fleet Send Notification Email To Dealer Recipients Before 20 Days</fullName>
        <actions>
            <name>Update_Fleet_Send_Email_Before_20_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  RecordType.DeveloperName = &apos;Fleet_Lead&apos;,   Status_Category__c = &apos;Open&apos;,   ISPICKVAL(Lead_Source__c, &apos;End of Contract&apos;), Existing_Contract__r.EndDate = TODAY() + 20 ,  Is_Fleet_Send_Email_Before_20_Days__c = FALSE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Fleet Send Notification Email To Dealer Recipients Before 60 Days</fullName>
        <actions>
            <name>Update_Fleet_Send_Email_Before_60_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(  RecordType.DeveloperName = &apos;Fleet_Lead&apos;,   Status_Category__c = &apos;Open&apos;,   ISPICKVAL(Lead_Source__c, &apos;End of Contract&apos;), Existing_Contract__r.EndDate = TODAY() + 60 ,  Is_Fleet_Send_Email_Before_60_Days__c = FALSE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Auto Check %27*24%2F72H Untouched%27</fullName>
        <active>true</active>
        <booleanFilter>(1 AND 2) OR (3 AND 4)</booleanFilter>
        <criteriaItems>
            <field>Lead_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Vehicle Lead,Service/Parts Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead_Account__c.Lead_Status__c</field>
            <operation>equals</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Finance Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead_Account__c.Lead_Status__c</field>
            <operation>equals</operation>
            <value>New Enquiry</value>
        </criteriaItems>
        <description>/*
Created By Polaris Yu 2013-8-27
Function: Checked the &apos;*24H Untouched&apos; field for Qualified Vehicle Leads and Service/Parts Leads if they haven&apos;t been updated for 24 hours
Used By:
Modified By Polaris Yu 2013-8-29 Added &apos;*72H Untouched&apos;
*/</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_72H_Untouched</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead_Account__c.LastModifiedDate</offsetFromField>
            <timeLength>72</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Update_24H_Untouched</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead_Account__c.LastModifiedDate</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Close Date With Status Category Closed Won</fullName>
        <actions>
            <name>Close_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead_Account__c.Status_Category__c</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
