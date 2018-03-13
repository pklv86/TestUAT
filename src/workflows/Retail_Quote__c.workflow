<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_to_retail_Quote_Owner</fullName>
        <description>Email alert to retail Quote Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>retailintgservices@dynegy.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Dynegy_Email_Templates/Email_for_DOA_check</template>
    </alerts>
    <alerts>
        <fullName>Email_to_alert_to_notify_user_when_a_quote_has_been_generated_with_Price_Complet</fullName>
        <description>Email to alert to notify user when a quote has been generated with Price Complete Status</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Dynegy_Email_Templates/Price_Complete_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Quote_Expired</fullName>
        <field>Request_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Quote Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unlock_Record</fullName>
        <description>Unlock record for editing.</description>
        <field>Locked__c</field>
        <literalValue>0</literalValue>
        <name>Unlock Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Product_and_Term</fullName>
        <field>Unique_Product_with_Term__c</field>
        <formula>Opportunity__c  &amp;  Product__c   &amp;  TEXT(Term__c)</formula>
        <name>Update Product and Term</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <field>Request_Status__c</field>
        <literalValue>New</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_date_10</fullName>
        <description>This field update is to add 10 days to the received date</description>
        <field>Pricing_Valid_Date_Time__c</field>
        <formula>LastModifiedDate + 11</formula>
        <name>Update date +10</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email Alert For DOA field</fullName>
        <actions>
            <name>Email_alert_to_retail_Quote_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Retail_Quote__c.Notional_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>10000000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.DOA_Approved__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Retail_Quote__c.LastModifiedById</field>
            <operation>equals</operation>
            <value>Integration User</value>
        </criteriaItems>
        <description>Email alert to opportunity owner if retailquote notional value is &gt; 10M and not approved by DOA</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Expire Quote</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Retail_Quote__c.Request_Status__c</field>
            <operation>equals</operation>
            <value>Pricing Complete</value>
        </criteriaItems>
        <description>Expire Quote based on Price Valid Date time</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Quote_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Unlock_Record</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Retail_Quote__c.Pricing_Valid_Date_Time__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Price Complete notification</fullName>
        <actions>
            <name>Email_to_alert_to_notify_user_when_a_quote_has_been_generated_with_Price_Complet</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Retail_Quote__c.Request_Status__c</field>
            <operation>equals</operation>
            <value>Pricing Complete,Request Rejected,Error-Invalid Account</value>
        </criteriaItems>
        <description>Send an email to owner of quote record when &quot;Price Complete&quot; status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pricing Valid Date Update</fullName>
        <actions>
            <name>Update_date_10</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Pricing_Type__c</field>
            <operation>equals</operation>
            <value>Renewal Evergreen,Renewal MTM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Retail_Quote__c.LastModifiedById</field>
            <operation>equals</operation>
            <value>Integration User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Amendment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Retail_Quote__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Executable</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Request Status When Cloned</fullName>
        <actions>
            <name>Update_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Request Status to New when we clone an existing record</description>
        <formula>AND(ISCLONE(), RecordType.Name = &apos;Indicative&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
