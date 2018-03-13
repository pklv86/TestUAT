<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Billing_Address_Line_2</fullName>
        <description>This is to update the Billing Address Line 2 from Mailing Address Line 2</description>
        <field>Billing_Address_Line_2__c</field>
        <formula>Mailing_Address_Line_2__c</formula>
        <name>Update Billing Address Line 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_Address_Line_3_ICO</fullName>
        <description>This is to update the Billing Address Line 3 from Mailing Address Line 3</description>
        <field>Billing_Address_Line_3__c</field>
        <formula>Mailing_Address_Line_3__c</formula>
        <name>Update Billing Address Line 3(ICO)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_City</fullName>
        <field>Billing__c</field>
        <formula>Mailing_City__c</formula>
        <name>Update Billing City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_Country</fullName>
        <description>This is to update the Billing country based on mailing country</description>
        <field>Billing_Country__c</field>
        <formula>Mailing_Country__c</formula>
        <name>Update Billing Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_Postal_Code</fullName>
        <description>This is to update the billing postal code based on mailing postal code</description>
        <field>Billing_Zip_Postal_code__c</field>
        <formula>Mailing_Zip_Postal_Code__c</formula>
        <name>Update Billing Postal Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_State</fullName>
        <description>This is to update the billing state from mailing state</description>
        <field>Billing_State_Province__c</field>
        <formula>Mailing_State_Province__c</formula>
        <name>Update Billing State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_Street</fullName>
        <description>This is to update the billing street from Mailing street</description>
        <field>Billing_Street__c</field>
        <formula>Mailing_Street__c</formula>
        <name>Update Billing Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Mailing_Address_2</fullName>
        <description>This is to Update the Mailing Address 2 based on Service Street 2</description>
        <field>Mailing_Address_Line_2__c</field>
        <formula>Service_Street_2__c</formula>
        <name>Update Mailing Address 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Mailing_City</fullName>
        <description>This is to Update the Mailing City based on Service City</description>
        <field>Mailing_City__c</field>
        <formula>Service_City__c</formula>
        <name>Update Mailing City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Mailing_Country</fullName>
        <description>This is to Update the Mailing Country based on Service Country</description>
        <field>Mailing_Country__c</field>
        <formula>&quot;USA&quot;</formula>
        <name>Update Mailing Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Mailing_Postalcode</fullName>
        <description>This is to Update the Mailing Postal Code based on Service Postal Code</description>
        <field>Mailing_Zip_Postal_Code__c</field>
        <formula>Service_Postal_Code__c</formula>
        <name>Update Mailing Postalcode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Mailing_State</fullName>
        <description>This is to Update the Mailing State based on Service State</description>
        <field>Mailing_State_Province__c</field>
        <formula>Service_State__c</formula>
        <name>Update Mailing State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Mailing_Street</fullName>
        <description>This is to Update the Mailing street based on Service Street 1</description>
        <field>Mailing_Street__c</field>
        <formula>Service_Street_1__c</formula>
        <name>Update Mailing Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Address same as above</fullName>
        <actions>
            <name>Update_Mailing_Address_2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Mailing_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Mailing_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Mailing_Postalcode</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Mailing_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Mailing_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Muni_Agg__c.Same_Mailing_Address__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Billing Address From Mailing Address</fullName>
        <actions>
            <name>Update_Billing_Address_Line_2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Billing_Address_Line_3_ICO</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Billing_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Billing_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Billing_Postal_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Billing_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Billing_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7) AND 8 AND 9 AND 10 AND 11 AND 12 AND 13 AND 14</booleanFilter>
        <criteriaItems>
            <field>Muni_Agg__c.Mailing_Street__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Mailing_Address_Line_2__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Mailing_Address_Line_3__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Mailing_City__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Mailing_Country__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Mailing_State_Province__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Mailing_Zip_Postal_Code__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Billing_Zip_Postal_code__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Billing_Address_Line_2__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Billing_Address_Line_3__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Billing__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Billing_Country__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Billing_State_Province__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Muni_Agg__c.Billing_Street__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
