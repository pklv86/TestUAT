<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Start_Date</fullName>
        <field>Start_Date__c</field>
        <formula>contract__r.StartDate</formula>
        <name>Populate Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Stop_Date</fullName>
        <field>Stop_Date__c</field>
        <formula>contract__r.End_Date__c</formula>
        <name>Populate Stop Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Billing Group Start Stop Date</fullName>
        <actions>
            <name>Populate_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Stop_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To Populate Stop Date from contract if it is blank</description>
        <formula>ISBLANK( Stop_Date__c )  ||  ISNULL( Stop_Date__c )  || ISBLANK(  Start_Date__c )  ||  ISNULL(  Start_Date__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Billing Group Stop Date</fullName>
        <actions>
            <name>Populate_Stop_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To Populate Stop Date from contract if it is blank</description>
        <formula>ISBLANK( Stop_Date__c )  ||  ISNULL( Stop_Date__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
