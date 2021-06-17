if [ ! "$(type -t headline)" = 'function' ] || [ ! "$(type -t log)" = 'function' ]; then
    source ./utility.sh
fi

headline "Starting Sandbox Create (createSandbox.sh)";

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

log "Sandbox Name: $bamboo_sfSandboxName"
log "Username: $bamboo_sfUsername"

sandboxConfigFile=config/developer-sandbox-config.json

log "sandboxConfigFile=$sandboxConfigFile"

log "Running SFDX Command: sfdx force:org:create -t sandbox sandboxName=$bamboo_sfSandboxName -f $sandboxConfigFile -u $bamboo_sfUsername -a $bamboo_sfSandboxName -w 90"
#sfdx force:org:create -t sandbox sandboxName=$bamboo_sfSandboxName -f $sandboxConfigFile -u $bamboo_sfUsername -a $bamboo_sfSandboxName -w 90
sfdx force:org:create -t sandbox sandboxName=$bamboo_sfSandboxName -f $sandboxConfigFile -u $bamboo_sfUsername -a $bamboo_sfSandboxName -w 90 2>&1 | tee createcmdstatus.txt

if grep -Pq 'The name you specified is assigned to a sandbox' createcmdstatus.txt
then 
     log "ERROR running force:org:create:  The name you specified is assigned to a sandbox that's being deleted. You can reuse the name after the deletion process finishes"
	 rm createcmdstatus.txt
   exit 1
fi
rm createcmdstatus.txt
headline "Finished Create Sandbox (createSandbox.sh)" "-";
