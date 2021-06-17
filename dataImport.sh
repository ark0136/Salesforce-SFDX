if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

headline "Starting Load Data (dataImport.sh)";

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

sandboxUsername=${bamboo_sfUsername}.${bamboo_sfSandboxName};
log "sandboxUsername=${sandboxUsername}"

userUpdateFile=config/userData.txt
log "UserDatafile= $userUpdateFile"

if [ -z $bamboo_ManualBuildTriggerReason_userName ]
then
	User=`whoami`
	bamboo_ManualBuildTriggerReason_userName=$User
fi

if [ -z $bamboo_sfSandbox_Dataset ]
then
		
	log "user: $bamboo_ManualBuildTriggerReason_userName"
	if [ `grep $bamboo_ManualBuildTriggerReason_userName $userUpdateFile |wc -l` -ge 1  ]
	then
		temp="base `grep $bamboo_ManualBuildTriggerReason_userName $userUpdateFile|awk -F ";" '{print $4}'`"
		DataTypes=`echo $temp |sed 's/base base/base/g;s/sales implementation/implementation/g;s/implementation/sales implementation/g'`
		log "user with ADID $bamboo_ManualBuildTriggerReason_userName found. Loading data for $DataTypes"
	else
		DataTypes="base"
		log "user not found in $userUpdateFile. Loading data for $DataTypes"
	fi

else
	echo "bamboo_sfSandbox_Dataset : $bamboo_sfSandbox_Dataset"
	temp="base `echo $bamboo_sfSandbox_Dataset|grep -wEoi 'base|sales|implementation'`"
	DataTypes=`echo $temp |sed 's/base base/base/g;s/sales implementation/implementation/g;s/implementation/sales implementation/g'`
	log "Loading data for $DataTypes"
	
fi

DataTypestemp=`echo $DataTypes|tr [A-Z] [a-z]`
DataTypes=`echo $DataTypestemp`
log "Data Set : $DataTypes"

# for each plan file in the data directory, load the plan data into the new sandbox
>data/new-plan.json
for i in $DataTypes
do
cat data/$i-*plan.json>>data/new-plan.json
done

sed -i 's/\]\[/,/g' data/new-plan.json
log "Loading data started";
log "sfdx force:data:tree:import -p data/new-plan.json -u ${sandboxUsername}"
sfdx force:data:tree:import -p data/new-plan.json -u ${sandboxUsername} 2>&1 | tee DataLoadError.txt
if grep -Pq '^ERROR' DataLoadError.txt
then
	count=0
	while [ $count -lt 5 ]
	do
		log "Error Occured while loading the data to Sandbox. Hence Retrying Data Upload."
		sh DeleteData.sh
		sleep 10
		sfdx force:data:tree:import -p data/new-plan.json -u ${sandboxUsername} 2>&1 | tee DataLoadError.txt
		status=$(grep -E 'ERROR running force:data:tree:import' DataLoadError.txt)
		count=`expr $count + 1`
		if [ -z "$status" ] ; then
			echo "Data Populated Succesfully after $count retries"
			break
		fi
		sleep 120
	done
	
	if [ $count -eq 5 ]
	then
		echo "Unable to load test data into Sandbox after 5 retires. Please use \"Sandbox - Data Population\" plan to populate data"
		rm DataLoadError.txt 
		rm data/new-plan.json
		exit 1
	fi
	
fi

rm -f DataLoadError.txt 
rm -f data/new-plan.json

headline "Finished Loading Data (dataImport.sh)" "-";
