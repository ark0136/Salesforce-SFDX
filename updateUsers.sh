if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

headline "Starting Update Users (updateUsers.sh)";

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

sfSandboxUsername="${bamboo_sfUsername}.${bamboo_sfSandboxName}"
log "sfSandboxUsername: $sfSandboxUsername"

userUpdateFile=config/userData.txt
log "User Data file : $userUpdateFile"

if [ -z $bamboo_ManualBuildTriggerReason_userName ]
then
	User=`whoami`
	bamboo_ManualBuildTriggerReason_userName=$User
	
fi
log "User : $bamboo_ManualBuildTriggerReason_userName"
if [ `grep $bamboo_ManualBuildTriggerReason_userName $userUpdateFile |wc -l` -ge 1 ]
then
	IFS=";"
	userArray1=`grep $bamboo_ManualBuildTriggerReason_userName $userUpdateFile|awk -F ";" '{print $2}'`
	userArray2=`grep $bamboo_ManualBuildTriggerReason_userName $userUpdateFile|awk -F ";" '{print $3}'`
else
	log "User:$bamboo_ManualBuildTriggerReason_userName not found in the $userUpdateFile .Fetching the details from Salesforce Production"
	log "sfdx force:data:soql:query -q \"select email from User where ADID__C = '$bamboo_ManualBuildTriggerReason_userName'\" -u $bamboo_sfUsername"
	sfdx force:data:soql:query -q "select email from User where ADID__C = '$bamboo_ManualBuildTriggerReason_userName'" -u $bamboo_sfUsername 2>&1 | tee emailaddress.txt
	
	if grep -Pq 'Your query returned no results' emailaddress.txt
	then
		log "No user found with ADID $bamboo_ManualBuildTriggerReason_userName in Salesforce Production"
		rm emailaddress.txt 
		exit 1
	else
	    email=`grep cdk.com emailaddress.txt`
		rm emailaddress.txt 	
		
		log "email address = $email"
		if [ -z $email ]
		then
			log "No valid email address found ending with cdk.com"
			exit 1
		fi
		userArray1="Username=$email"
		log "userArray1=$userArray1"
		userArray2="Email=$email ProfileId=00e40000000rAoY"
		log "userArray2=$userArray2"
		
	fi
		   
fi

count=0
while [ $count -lt 5 ]
do
	log "Running SFDX Command to update Email and Profile: sfdx force:data:record:update -u $sfSandboxUsername -s User -w ${userArray1}.${bamboo_sfSandboxName} -v \"${userArray2}\""
	sfdx force:data:record:update -u $sfSandboxUsername -s User -w "${userArray1}.${bamboo_sfSandboxName}" -v "${userArray2}" 2>&1 | tee userinfocheck.txt
	status=$(grep -E 'ERROR running force:data:record:update' userinfocheck.txt)
	
	if [ -z "$status" ] ; then
		echo "User Data Updated"
        break
	fi
	sleep 120
	count=`expr $count + 1`
done
rm userinfocheck.txt

headline "Finished Update Users (updateUsers.sh)" "-";
