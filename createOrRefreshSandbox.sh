if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

headline "Initiating Sandbox Create/Refresh Process (createOrRefreshSandbox.sh)";

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
log "Sandbox Name : $bamboo_sfSandboxName"
log "sfUsername : $bamboo_sfUsername"

log "Running SFDX Command: sfdx force:data:record:get -t -u $bamboo_sfUsername -s SandboxInfo -w \"SandboxName='$bamboo_sfSandboxName'\""
sfdx force:data:record:get -t -u $bamboo_sfUsername -s SandboxInfo -w "SandboxName='$bamboo_sfSandboxName'" 2>&1 | tee createOrRefreshSandbox.txt
if grep -Pq 'No matching record found' createOrRefreshSandbox.txt
then
   log "No sandbox found with user $bamboo_sfSandboxName. Hence creating new sandbox with $bamboo_sfSandboxName"
   sh createSandbox.sh
	if [ $? -ne 0 ]
	then
		echo "Issue while creating sandbox. Please refer Log for Details"
		rm createOrRefreshSandbox.txt
		exit 1
	fi
   else
   log "sandbox found with user $bamboo_sfSandboxName. Hence refreshing sandbox with name $bamboo_sfSandboxName"
   sh sandboxRefresh.sh
   #log "getting Sandbox Status and Authenticating the sandbox"
   #sh sandboxStatus.sh
fi
rm createOrRefreshSandbox.txt

headline "Finished Sandbox Create/Refresh Process (createOrRefreshSandbox.sh)" "-";
