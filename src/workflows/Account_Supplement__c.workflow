<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Tax_Email</fullName>
        <ccEmails>PennsylvaniaCertificates@dynegy.com</ccEmails>
        <description>Tax email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dynegy_Email_Templates/Tax_Approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_By</fullName>
        <field>Approved_By__c</field>
        <formula>LastModifiedBy.FirstName + &apos; &apos;+LastModifiedBy.LastName</formula>
        <name>Approval By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Aprroval_Updated</fullName>
        <field>Approval_Date__c</field>
        <formula>NOW()</formula>
        <name>Aprroval Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Aprroval_Updated_By</fullName>
        <field>Approved_By__c</field>
        <formula>$User.LastName &amp;&apos; &apos;&amp;  $User.FirstName</formula>
        <name>Aprroval Updated By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reject_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Reject Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted_for_Approval</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_End_date</fullName>
        <field>End_Date__c</field>
        <formula>IF(
AND(Month(Start_Date__c)=2,Day(Start_Date__c)=29),
DATE(YEAR(Start_Date__c) + 3, Month(Start_Date__c),Day(Start_Date__c)-1),
DATE(YEAR(Start_Date__c) + 3, Month(Start_Date__c),Day(Start_Date__c))
)</formula>
        <name>Update End date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>End date Account Supplement</fullName>
        <actions>
            <name>Update_End_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Supplement__c.End_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Supplement__c.Start_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update End date to default 3 years if it is null ticket 1629</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
