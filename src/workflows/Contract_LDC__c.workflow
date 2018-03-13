<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateLDCStatus</fullName>
        <field>IsSynchronized__c</field>
        <literalValue>0</literalValue>
        <name>UpdateLDCStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ContractLDCIntegration</fullName>
        <actions>
            <name>UpdateLDCStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISCHANGED(IsSynchronized__c)=false)&amp;&amp;(ISCHANGED(Term_Start_Date__c)||ISCHANGED(Term_Stop_Date__c)||(ISCHANGED(Bill_Method__c)||ISCHANGED(Rate_Code__c)))&amp;&amp;(LastModifiedBy.FirstName &lt;&gt; &apos;Integration&apos; &amp;&amp; LastModifiedBy.LastName &lt;&gt; &apos;User&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
