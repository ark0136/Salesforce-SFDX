if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

headline "Starting Sandbox Status and Auth (sandboxStatus.sh)";

if [ -z $bamboo_sfSandboxName ]
then
	if [ -z $bamboo_ManualBuildTriggerReason_userName ]
	then
		User=`whoami`
		bamboo_sfSandboxName=$User
	else
		bamboo_sfSandboxName=$bamboo_ManualBuildTriggerReason_userName
	fi
fi

log "Running SFDX Command: sfdx force:org:status -n $bamboo_sfSandboxName -u $bamboo_sfUsername -a $bamboo_sfSandboxName -w 90"
sfdx force:org:status -n $bamboo_sfSandboxName -u $bamboo_sfUsername -a $bamboo_sfSandboxName -w 90
log " Listing all the Orgs: sfdx force:org:list --all"
sfdx force:org:list --all

headline "Finished Sandbox Status (sandboxStatus.sh)" "-";
