<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DUNSLDC_UPDATE</fullName>
        <field>DUNSLDC__c</field>
        <formula>LDC_Vendor__r.DUNS__c+LDC_Account_Number__c</formula>
        <name>DUNS LDC UPDATE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Duplicate_Check</fullName>
        <field>Unique_Utility_Name_LDC_Number__c</field>
        <formula>LDC_Account_Number__c  &amp;  LDC_Vendor__r.DUNS__c &amp;  
LEFT( LDC_Vendor__r.Name ,
VALUE(IF(FIND(&apos; &apos;,  LDC_Vendor__r.Name ) &lt;= 0 ,
 TEXT( LEN( LDC_Vendor__r.Name) ) , TEXT(FIND(&apos; &apos;, LDC_Vendor__r.Name )))))</formula>
        <name>Duplicate Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opt_Out_By_User_Update</fullName>
        <description>This workflow field update is used to update the participation status user</description>
        <field>Participation_Status_User__c</field>
        <lookupValue>integration.user@dynegy.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Opt Out By User Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opt_Out_Date_Update</fullName>
        <description>This Workflow field update is used to update the Participation status date field</description>
        <field>Participation_Status_Date__c</field>
        <formula>LastModifiedDate</formula>
        <name>Opt Out Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateAccount</fullName>
        <field>LodeStar_Integration_Status__c</field>
        <literalValue>Not Synchronized</literalValue>
        <name>UpdateAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateAccountValidations</fullName>
        <description>This workflow field update is created to update the Account Validation field</description>
        <field>Validation__c</field>
        <literalValue>Modified</literalValue>
        <name>UpdateAccountValidation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateLDCAccountStatusFinal</fullName>
        <description>This field update will change the LDC Account Status to FINAL</description>
        <field>LDC_Account_Status__c</field>
        <literalValue>FINAL</literalValue>
        <name>UpdateLDCAccountStatusFinal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateParentAccount</fullName>
        <description>Update the Parent Account of an LDC_Account__c record and set the LodeStar_Integration_Status__c to &apos;Not Synchronized&apos;</description>
        <field>LodeStar_Integration_Status__c</field>
        <literalValue>Not Synchronized</literalValue>
        <name>UpdateParentAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Check Duplicate Value</fullName>
        <actions>
            <name>Duplicate_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LDC_Account__c.Unique_Utility_Name_LDC_Number__c</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <description>LDC Number and Utility Name must be unique</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DUNS LDC UPDATE</fullName>
        <actions>
            <name>DUNSLDC_UPDATE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LDC_Account__c.LDC_Account_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow is created to insert the DUNS and LDC Account Number</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LDC_LodeStarIntegration</fullName>
        <actions>
            <name>UpdateAccount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>update Account of an LDC so that synchronization will be triggered</description>
        <formula>( ISCHANGED(Bill_Cycle__c) || ISCHANGED(Service_Street_1__c) || ISCHANGED(LDC_Account_Number__c) || ISCHANGED(Utility_Rate_Class__c) || ISCHANGED(LDC_Account_Status__c) || ISCHANGED(Bill_Method__c) || ISCHANGED(Interval_Usage__c) || ISCHANGED(LDC_End_Date__c) || ISCHANGED(LDC_Vendor__c)) &amp;&amp; Enrolled__c = true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opt Out Status Fields Update</fullName>
        <actions>
            <name>Opt_Out_By_User_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Opt_Out_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This Workflow is used to populate the participation status fields when the opt out value is changed</description>
        <formula>ISCHANGED(Opt_out__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
