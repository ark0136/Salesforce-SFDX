if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

headline "Exporting Data (dataExport.sh)";

bamboo_sfUsername="integration_user@adp.com"

# Client ID for Connected App: Sandbox Management (Bamboo) - Sandbox_Management
bamboo_sfClientId="3MVG9iTxZANhwHQsoqht8Ov9RhIvjtDUYwdt.XLlCwUi6uWL1XGcPg6totdrZ1AAqZ_uYxqZg4Q==" 

export bamboo_sfUsername
export bamboo_sfClientId

sh auth.sh

sfdx force:data:tree:export --query \
" \
    SELECT Id, Name, Active__c, Corporation_Flag__c, Display_Code__c, \
    District_Flag__c, Group_Flag__c, Migration_ID__c, Non_Sales_Type__c, \
    OOB_Duplicates_Flag__c, Segment_Code__c, Site_Type_Flag__c, \
    SLX_DealerSite_Type_ID__c, SLX_DealerSiteType_CreateDate__c \
    FROM Site_Type__c \
" \
--prefix base --outputdir data

sfdx force:data:tree:export --query \
" \
    SELECT Id, Name, \
    RecordTypeId, \
    BillingCity, \
    BillingCountry, BillingGeocodeAccuracy, \
    BillingLatitude, BillingLongitude, BillingPostalCode, \
    BillingState, BillingStreet, \
    Location_County__c, Mailing_County__c, \
    ShippingCity, ShippingCountry, \
    ShippingGeocodeAccuracy, ShippingLatitude, \
    ShippingLongitude, ShippingPostalCode, \
    ShippingState, ShippingStreet, \
    Key_Rep__r.Name, Key_Rep__r.Id, Current_DMS__c, \
    Site_Type__r.Name, Site_Type__r.Id, \
    Parent.Name, Parent.Id, PartyID__c, Party_Number__c, Segment_Code__c, \
    Migration_ID__c \
    FROM Account WHERE Name = 'Bowser' OR Parent.Name = 'Bowser'
" \
--prefix base --outputdir data

sfdx force:data:tree:export --query \
" \
    SELECT Id, Name, \
    RecordType.DeveloperName, RecordType.Id, \
    Account.Name, ADP_Opportunity_Owner__r.Username, \
    ADP_Opportunity_Owner__r.Id, CloseDate, \
    StageName, Owner.Name, Owner.Id, Type, \
    Product_Sites__c, \
    Is_any_item_product_that_is_being_sold__c, Add_On_or_Change_to_Prev_Contract__c \
    FROM Opportunity WHERE (Account.Name LIKE '%bowser%' OR Account.Parent.Name LIKE '%bowser%') \
    AND (NOT StageName like '%Closed%') \
    AND (NOT Type like '%Cancellation%') \
" \
--prefix base --outputdir data --plan



headline "Finished Exporting Data (dataExport.sh)" "-";