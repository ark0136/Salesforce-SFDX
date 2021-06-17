## This repository is to be used by the "GlobalIT > SFNA_Active_Sandboxes " Bamboo plan to List all the Active Sandboxes in the Salesforce Organization.
	Bamboo Plan:http://bamboo.cdk.com/browse/GLOB-SFNAAC
	Open the Bamboo Plan and Click on Run,  It will list all the Active sandboxes in the Salesforce Organization.
    Confluence : https://confluence.cdk.com/display/GLOBIT/Listing+Sandboxes

## This repository is to be used by the "GlobalIT > SFNA_Create Sandbox " Bamboo plan to Create/Refresh the Developer Sandbox.
	Bamboo Plan:http://bamboo.cdk.com/browse/GLOB-SFNAS
	Open the Bamboo Plan and Click on Run,  ADID will be Considered as Sandbox Name and The Dataset Present in the Userdata.txt will be Uploaded.  
	Open the Bamboo Plan and Click on Run Customized and Override sandbox Name/Data set with  desire Values. 
    Confluence : https://confluence.cdk.com/pages/viewpage.action?pageId=273337944

## This repository is to be used by the "GlobalIT > SFNA_Data_Population " Bamboo plan to Populate the Data to Developer Sandbox.
	Bamboo Plan:http://bamboo.cdk.com/browse/GLOB-SFNAT
	Open the Bamboo Plan and Click on Run,  ADID will be Considered as Sandbox Name and The Dataset Present in the Userdata.txt will be Uploaded.  
	Open the Bamboo Plan and Click on Run Customized and Override sandbox Name/Data set with  desire Values.  
    Confluence : https://confluence.cdk.com/display/GLOBIT/Data+Population+to+Sandboxes
    
## This repository is to be used by the "GlobalIT > SFNA_Sandbox_Deletion " Bamboo plan to Delete the Developer Sandbox.
	Bamboo Plan: http://bamboo.cdk.com/browse/GLOB-SFNASD
	Open the Bamboo Plan and Click on Run Customized and Override sandbox Name with  desired Sandbox Name to Delete.  
    Confluence : https://confluence.cdk.com/display/GLOBIT/Delete+Sandbox

## If you checkout and run any of the shell script commands locally, start with runLocal.sh.

### Note :
	To upload the data other than base please update https://stash.cdk.com/projects/QD/repos/sfdx_sandbox/browse/config/userData.txt file as below. <br /> 
	Format : ADID;UserName=firstname.lastname@cdk.com;Email=firstname.lastname@cdk.com ProfileId=********;Dataset1 Dataset2(optional) <br />
	Example:pemmasap; UserName=Poorna.pemmasani@cdk.com;Email=Poorna.pemmasani@cdk.com ProfileId= 00e40000000rAoY;sales <br />  

### Data Sets Information :

#### Base :
Site_Type__c,Account,CMF_Info__c,Contact,Account_Team__c,Building__c,Department__c,Department_Area__c,Department_Equipment__c

#### Sales :
Campaign,Opportunity,OpportunityLineItem,Lead,Systems__c,System_at_Dealership__c,Application_Interface_Mapping__c,Contract,SubProject__c,ALL_Contract_Line__c

#### Implementation:
SubProject__c,SubProjectSite__c,CDK_Product__c,Product_Checklist__c,Product_at_Site_eLead_Sales__c

