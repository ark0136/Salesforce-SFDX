if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi
headline "Verying user details (validateUser.sh)";


if [ -z $bamboo_ManualBuildTriggerReason_userName ]
then
	User=`whoami`
else
	User=$(echo ${bamboo_ManualBuildTriggerReason_userName})
fi

log "Salesforce user: $User"

FilePath=config/userData.txt #if local, DO NOT use the sandbox prefix
log "User Details File Path = $FilePath"
	    if [ `grep $User $FilePath | wc -l` -ge 1 ]
		then
			log "User:$User present in the $FilePath file"
		else
		   log "User:$User not found.Fetching the details from Salesforce Production"
		   log "sfdx force:data:soql:query -q \"select email from User where ADID__C = '$User'\" -u $bamboo_sfUsername"
		   sfdx force:data:soql:query -q "select email from User where ADID__C = '$User'" -u $bamboo_sfUsername 2>&1 | tee emailaddress.txt
		   
		fi	

headline "Finished Verying user details (validateUser.sh)" "-";
