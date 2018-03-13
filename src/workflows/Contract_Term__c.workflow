<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Contract_Validation_Update</fullName>
        <field>Validation__c</field>
        <literalValue>Modified</literalValue>
        <name>Contract Validation Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contract__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Contract Term Lodestar</fullName>
        <actions>
            <name>Contract_Validation_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update contract validation on any updates at contract terms</description>
        <formula>AND(ISCHANGED(Term_Type__c )||   ISCHANGED( Term_Category__c )||  ISCHANGED( Contract_Term_Value__c ) ||  ISCHANGED(Term_Start_Date__c) ||  ISCHANGED(Term_Stop_Date__c) ||  ISCHANGED( Value_String__c),   (ISPICKVAL(Contract__r.Status, &apos;Activated&apos;)||ISPICKVAL(Contract__r.Status, &apos;Expired&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
