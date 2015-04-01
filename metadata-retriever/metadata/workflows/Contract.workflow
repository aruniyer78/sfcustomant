<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Annual_Call_Task_1</fullName>
        <field>Annual_Call_Task_1_del__c</field>
        <literalValue>1</literalValue>
        <name>Annual Call Task 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Annual_Call_Task_2</fullName>
        <field>Annual_Call_Task_2_del__c</field>
        <literalValue>1</literalValue>
        <name>Annual Call Task 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Annual_Call_Task_3</fullName>
        <field>Annual_Call_Task_3_del__c</field>
        <literalValue>1</literalValue>
        <name>Annual Call Task 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EOC_Call_Task_1</fullName>
        <field>EOC_Call_Task_1_del__c</field>
        <literalValue>1</literalValue>
        <name>EOC Call Task 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EOC_Call_Task_2</fullName>
        <field>EOC_Call_Task_2_del__c</field>
        <literalValue>1</literalValue>
        <name>EOC Call Task 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EOC_Call_Task_3</fullName>
        <field>EOC_Call_Task_3_del__c</field>
        <literalValue>1</literalValue>
        <name>EOC Call Task 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FleetToTrue</fullName>
        <field>Fleet__c</field>
        <literalValue>1</literalValue>
        <name>FleetToTrue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_150_Days_Before_EOC</fullName>
        <description>/*
Created By Polaris Yu 2013-8-22
Function: Auto check the &apos;150 Days Before EOC&apos; on Contract at 150 days before the contract end date
Used By: workflow - Contract Auto Check &apos;150 Days Before EOC&apos;
*/</description>
        <field>X150_Days_Before_EOC__c</field>
        <literalValue>1</literalValue>
        <name>Update 150 Days Before EOC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Annual_Call</fullName>
        <field>Annual_Call__c</field>
        <literalValue>1</literalValue>
        <name>Update Annual Call</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_EOC_Call</fullName>
        <field>EOC_Call__c</field>
        <literalValue>1</literalValue>
        <name>Update EOC Call</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Welcome_Call</fullName>
        <field>Welcome_Call__c</field>
        <literalValue>1</literalValue>
        <name>Update Welcome Call</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Welcome_Call_Task</fullName>
        <field>Welcome_Call_Task__c</field>
        <literalValue>1</literalValue>
        <name>Welcome Call Task</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contract Auto Check %27150 Days Before EOC%27</fullName>
        <active>false</active>
        <description>/*
Created By Polaris Yu 2013-8-22
Function: Auto check the &apos;150 Days Before EOC&apos; field on Contract at 150 days before the end date of the contract
Used By:
*/</description>
        <formula>NOT(X150_Days_Before_EOC__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_150_Days_Before_EOC</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-150</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Contract Auto Check %27150 Days Before EOC%27New</fullName>
        <active>true</active>
        <description>/*
Created By Polaris Yu 2013-8-22
Function: Auto check the &apos;150 Days Before EOC&apos; field on Contract at 150 days before the end date of the contract
Used By:
*/</description>
        <formula>NOT(X150_Days_Before_EOC__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_150_Days_Before_EOC</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.Contract_End_Date__c</offsetFromField>
            <timeLength>-150</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Final End of Contract Call Check</fullName>
        <active>true</active>
        <formula>AND( GFV__c = true, OR(ISPICKVAL( Contract_Status__c , &apos;Current&apos;),  ISPICKVAL( Contract_Status__c , &apos;Default-Collection Officer&apos;), ISPICKVAL( Contract_Status__c , &apos;Default-External Agent&apos;), ISPICKVAL( Contract_Status__c , &apos;Overdue&apos;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EOC_Call_Task_3</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_EOC_Call</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>First End of Contract Call Check</fullName>
        <active>true</active>
        <formula>AND( GFV__c = true, OR(ISPICKVAL( Contract_Status__c , &apos;Current&apos;),  ISPICKVAL( Contract_Status__c , &apos;Default-Collection Officer&apos;), ISPICKVAL( Contract_Status__c , &apos;Default-External Agent&apos;), ISPICKVAL( Contract_Status__c , &apos;Overdue&apos;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EOC_Call_Task_1</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_EOC_Call</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-395</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>First Year Annual Call Check</fullName>
        <active>true</active>
        <formula>AND( GFV__c = true, OR(ISPICKVAL( Contract_Status__c , &apos;Current&apos;),  ISPICKVAL( Contract_Status__c , &apos;Default-Collection Officer&apos;), ISPICKVAL( Contract_Status__c , &apos;Default-External Agent&apos;), ISPICKVAL( Contract_Status__c , &apos;Overdue&apos;)),  livetime__c &gt;= 36)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Annual_Call_Task_1</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Annual_Call</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.StartDate</offsetFromField>
            <timeLength>365</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Second End of Contract Call Check</fullName>
        <active>true</active>
        <formula>AND( GFV__c = true, OR(ISPICKVAL( Contract_Status__c , &apos;Current&apos;),  ISPICKVAL( Contract_Status__c , &apos;Default-Collection Officer&apos;), ISPICKVAL( Contract_Status__c , &apos;Default-External Agent&apos;), ISPICKVAL( Contract_Status__c , &apos;Overdue&apos;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EOC_Call_Task_2</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_EOC_Call</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-181</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Second Year Annual Call Check</fullName>
        <active>true</active>
        <formula>AND( GFV__c = true, OR(ISPICKVAL( Contract_Status__c , &apos;Current&apos;),  ISPICKVAL( Contract_Status__c , &apos;Default-Collection Officer&apos;), ISPICKVAL( Contract_Status__c , &apos;Default-External Agent&apos;), ISPICKVAL( Contract_Status__c , &apos;Overdue&apos;)),   livetime__c &gt;= 48)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Annual_Call_Task_2</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Annual_Call</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.StartDate</offsetFromField>
            <timeLength>730</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Third Year Annual Call Check</fullName>
        <active>true</active>
        <formula>AND( GFV__c = true, OR(ISPICKVAL( Contract_Status__c , &apos;Current&apos;),  ISPICKVAL( Contract_Status__c , &apos;Default-Collection Officer&apos;), ISPICKVAL( Contract_Status__c , &apos;Default-External Agent&apos;), ISPICKVAL( Contract_Status__c , &apos;Overdue&apos;)),   livetime__c &gt;= 60)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Annual_Call_Task_3</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Annual_Call</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.The_Day_After_Start_One_Year__c</offsetFromField>
            <timeLength>730</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Welcome Call Check</fullName>
        <active>true</active>
        <formula>AND( GFV__c = true, OR(ISPICKVAL( Contract_Status__c , &apos;Current&apos;),  ISPICKVAL( Contract_Status__c , &apos;Default-Collection Officer&apos;), ISPICKVAL( Contract_Status__c , &apos;Default-External Agent&apos;), ISPICKVAL( Contract_Status__c , &apos;Overdue&apos;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Welcome_Call</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Welcome_Call_Task</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.StartDate</offsetFromField>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
