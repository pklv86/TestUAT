<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_for_Tickets</fullName>
        <ccEmails>tonya.d.powell@dynegy.com</ccEmails>
        <description>Email Alert for Tickets</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Affected_User__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Assigned_Developer__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dynegy_Email_Templates/Ticket_Status_Update</template>
    </alerts>
    <alerts>
        <fullName>New_ticket_email</fullName>
        <ccEmails>tonya.d.powell@dynegy.com</ccEmails>
        <description>New ticket email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Affected_User__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Assigned_Developer__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dynegy_Email_Templates/New_Ticket</template>
    </alerts>
    <fieldUpdates>
        <fullName>Status_Date_Update</fullName>
        <description>This field update is to update the status date when ever status is changed</description>
        <field>Status_Date__c</field>
        <formula>LastModifiedDate</formula>
        <name>Status Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>New Ticket</fullName>
        <actions>
            <name>New_ticket_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Tickets__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This Workflow is used to send email for every new ticket</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Ticket_Email</fullName>
        <actions>
            <name>Email_Alert_for_Tickets</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Status_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is created to send the emails and update status date every time status of the ticket is changed</description>
        <formula>ISCHANGED(Status__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
