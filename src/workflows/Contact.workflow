<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Newletter_Signup_Date_Update</fullName>
        <description>This field update is used to update the news letter sign update to today</description>
        <field>Newsletter_Signup_Date__c</field>
        <formula>TODAY()</formula>
        <name>Newletter Signup Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Newletter Update</fullName>
        <actions>
            <name>Newletter_Signup_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This Workflow is created to update the Newsletter signup date</description>
        <formula>IF( Newsletter__c , IF(ISNULL( Newsletter_Signup_Date__c ),TRUE, FALSE), FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
