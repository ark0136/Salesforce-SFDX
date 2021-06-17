source ./utility.sh


export bamboo_sfUsername="integration_user@adp.com"

# Client ID for Connected App: Sandbox Management (Bamboo) - Sandbox_Management
export bamboo_sfSecretClientId="3MVG9iTxZANhwHQsoqht8Ov9RhIvjtDUYwdt.XLlCwUi6uWL1XGcPg6totdrZ1AAqZ_uYxqZg4Q==" 
export bamboo_sfSandboxRefreshApexClassId="01p33000000NQCpAAO"
export bamboo_table_names="Product_at_Site_eLead_Sales__c Product_Checklist__c CDK_Product__c SubProjectSite__c SubProject__c ALL_Contract_Line__c Contract ServiceContract Application_Interface_Mapping__c System_at_Dealership__c Systems__c Lead OpportunityLineItem Opportunity Campaign Department_Equipment__c Department_Area__c Department__c Building__c Account_Team__c Contact CMF_Info__c Account Site_Type__C"

#user override variables
export bamboo_sfSandbox_Dataset=""
export bamboo_sfSandboxName=""
 
echo $bamboo_sfUsername
echo $bamboo_sfSecretClientId
echo $bamboo_sfSandboxName
echo $bamboo_sfSandbox_Dataset

#Validating DataSet value
log "Validating DataSet"
if [ ! -z "$bamboo_sfSandbox_Dataset" ]
then
	if [ `echo $bamboo_sfSandbox_Dataset|grep -wEoi 'base|sales|implementation'|wc -l` -ne 1  ]
	then
		log "Provided DataSet : $bamboo_sfSandbox_Dataset is not valid. Please provide either of base/sales/implementation"
		exit 1	
	fi
fi

#authenticate to the production instance
sh auth.sh
if [ $? -ne 0 ]
then
echo "Issue while authenticating to the production instance, auth.sh failed"
exit 1
fi

#Validating Sandbox existance and create or refresh sandbox
sh createOrRefreshSandbox.sh
if [ $? -ne 0 ]
then
echo "Issue while validating sandbox existance, createOrRefreshSandbox.sh failed"
exit 1
fi


# get sandbox status
sh sandboxStatus.sh

# delete data from the sandbox(OPTIONAL)
#sh DeleteData.sh

# load data to the new sandbox
sh dataImport.sh

# update the email addresses on user records for the new sandbox
# this will send a verification email out and allow users to use [forgot password] functionality
sh updateUsers.sh
