<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_to_alert_to_notify_IL_user_s_when_Contract_is_Activated</fullName>
        <description>Email to alert to notify IL user&apos;s when Contract is Activated</description>
        <protected>false</protected>
        <recipients>
            <recipient>amey.h.stortzum@dynegy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>angie.ward@dynegy.com.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>blaire.bartimo@dynegy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>christopher.sill@dynegy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>debra.lucas@dynegy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>john.dreusicke@dynegy.com.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jordan.presberry@dynegy.com.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kristin.m.bono@dynegy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lauren.sciuto@dynegy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael.grimes@dynegy.com.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tamika.cole@dynegy.com.prod</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Dynegy_Email_Templates/IL_Contract_Activated</template>
    </alerts>
    <alerts>
        <fullName>Email_to_alert_to_notify_OH_user_s_when_Contract_is_Activated</fullName>
        <description>Email to alert to notify OH user&apos;s when Contract is Activated</description>
        <protected>false</protected>
        <recipients>
            <recipient>brooke.lantry@dynegy.com.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>derek.king@dynegy.com.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>don.schierenbeck@dynegy.com.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eileen.morgan@dynegy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jessica.collins@dynegy.com.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>katie.kiefer@dynegy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lauren.matson@dynegy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>raymond.culver@dynegy.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>todd.frank@dynegy.com.prod</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Dynegy_Email_Templates/OH_Contract_Activated</template>
    </alerts>
    <fieldUpdates>
        <fullName>Contract_Status_Update</fullName>
        <description>Change the status to expired when the contract end date is passed</description>
        <field>Status</field>
        <literalValue>Expired</literalValue>
        <name>Contract Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Validation_Field</fullName>
        <field>Validation__c</field>
        <literalValue>Modified</literalValue>
        <name>Contract Validation Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contract Lodestar Validation</fullName>
        <actions>
            <name>Contract_Validation_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates contract validation on any updates to LS fields</description>
        <formula>ISCHANGED( StartDate )|| ISCHANGED( Contract_Type__c ) ||  ISCHANGED( Description )  ||  ISCHANGED( Contract_Counter_Signed_Date__c ) ||  ISCHANGED( Supplier__c )  ||  ISCHANGED( Offer_Code__c )  ||  ISCHANGED( LodeStar_Identifier__c )  ||  ISCHANGED( Parent_Contract__c )  ||  ISCHANGED( Product_Name__c )  ||  ISCHANGED( BillingStreet )  ||  ISCHANGED( BillingCity )  ||  ISCHANGED( BillingState )  ||  ISCHANGED( BillingCountry )  ||  ISCHANGED( BillingPostalCode )  ||  ISCHANGED( End_Date__c )||ISCHANGED(  Referral_Broker__c )||ISCHANGED(  Bill_Method__c )||ISCHANGED(  Rate_Code__c )||ISCHANGED(  Service_Territory__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contract Status Update</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contract.End_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When the Contract end date is passed the status is changed to expired</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Contract_Status_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>IL Contract Activated</fullName>
        <actions>
            <name>Email_to_alert_to_notify_IL_user_s_when_Contract_is_Activated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule is designed for IL when Contract status is Activated</description>
        <formula>IF((ISPICKVAL( Service_Territory__c , &apos;ComEd-IL&apos;) || ISPICKVAL( Service_Territory__c ,&apos;Ameren-IL&apos;))&amp;&amp; ISPICKVAL( Status,&apos;Activated&apos; ),true,false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OH Contract Activated</fullName>
        <actions>
            <name>Email_to_alert_to_notify_OH_user_s_when_Contract_is_Activated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule is designed for OH when Contract status is Activated</description>
        <formula>IF((ISPICKVAL( Service_Territory__c , &apos;AEPOHIO&apos;) || ISPICKVAL( Service_Territory__c ,&apos;DAYTON&apos;)|| ISPICKVAL( Service_Territory__c ,&apos;DEOHIO&apos;)|| ISPICKVAL( Service_Territory__c ,&apos;FEOHIO&apos;))&amp;&amp; ISPICKVAL( Status,&apos;Activated&apos; ),true,false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
