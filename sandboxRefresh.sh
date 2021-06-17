if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi
headline "Initiating sandbox Refresh process (sandboxRefresh.sh)";
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
log "sfSandboxName= $bamboo_sfSandboxName"
log "sfUsername= $bamboo_sfUsername"
log "sfApexClassId= $bamboo_sfSandboxRefreshApexClassId"
Curr_Date=`date '+%d%h%Y'`
log "Refreshing sandbox:sfdx force:data:record:update -t -u $bamboo_sfUsername -s SandboxInfo -w \"SandboxName='$bamboo_sfSandboxName'\" -v \"Description='Refreshed on $Curr_Date' AutoActivate='true' LicenseType='DEVELOPER' ApexClassId='$bamboo_sfSandboxRefreshApexClassId'\""
sfdx force:data:record:update -t -u $bamboo_sfUsername -s SandboxInfo -w "SandboxName='$bamboo_sfSandboxName'" -v "Description='Refreshed on $Curr_Date' AutoActivate='true' LicenseType='DEVELOPER' ApexClassId='$bamboo_sfSandboxRefreshApexClassId'"

#log "Getting status :sfdx force:data:soql:query -q \"select SandboxName, Description, CopyProgress, Status from Sandboxprocess where SandboxName='$bamboo_sfSandboxName' order by LastModifiedDate desc limit 1\" -u $bamboo_sfUsername -t"
log "sfdx force:data:soql:query -q \"select SandboxName, Description, CopyProgress, Status from Sandboxprocess where SandboxName='$bamboo_sfSandboxName' and Description='Refreshed on $Curr_Date'\" -u $bamboo_sfUsername -t"

while true ;do
	#sfdx force:data:soql:query -q "select SandboxName, Description, CopyProgress, Status from Sandboxprocess where SandboxName='$bamboo_sfSandboxName' order by LastModifiedDate desc limit 1" -u $bamboo_sfUsername -t | tee refreshStatus.txt
	sfdx force:data:soql:query -q "select SandboxName, Description, CopyProgress, Status from Sandboxprocess where SandboxName='$bamboo_sfSandboxName' and Description='Refreshed on $Curr_Date'" -u $bamboo_sfUsername -t | tee refreshStatus.txt
	status=$(grep -E 'Completed' refreshStatus.txt)
	
	if [ ! -z "$status" ] ; then
		rm refreshStatus.txt
		echo "Refresh Completed"
        break
	fi
	sleep 120
done

headline "Finished sandbox refresh. (sandboxRefresh.sh)" "-";




