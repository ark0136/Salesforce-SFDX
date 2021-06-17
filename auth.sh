if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

headline "Authorizing SFDX to Production Connected App (auth.sh)";

log "Salesforce Username: $bamboo_sfUsername"

if test -f "sfdx_sandbox/keys/server.key"; then
    keyFile=sfdx_sandbox/keys/server.key #if on bamboo, use the sandbox prefix
else
    if test -f "keys/server.key"; then
        keyFile=keys/server.key #if local, DO NOT use the sandbox prefix
    fi
fi

log "keyFile=$keyFile"

masked_bamboo_sfSecretClientId=$(mask $bamboo_sfSecretClientId 10)
log "masked sfClientId= $masked_bamboo_sfSecretClientId"

log "Running logout sfdx command : sfdx force:auth:logout -ap"
sfdx force:auth:logout -ap
log "Logged out from all the Salesforce Orgs"

log "Running SFDX Command: sfdx force:auth:jwt:grant --username $bamboo_sfUsername --jwtkeyfile $keyFile --clientid $masked_bamboo_sfSecretClientId -a prod"
sfdx force:auth:jwt:grant --setalias adminProd --username $bamboo_sfUsername --jwtkeyfile $keyFile --clientid $bamboo_sfSecretClientId 

log "Running SFDX Command: sfdx force:config:set defaultusername=$bamboo_sfUsername"
sfdx force:config:set defaultusername=$bamboo_sfUsername

log "Listing Currently Connected Orgs:sfdx force:org:list --all"
sfdx force:org:list --all

headline "Finished Authorizing (auth.sh)" "-";
