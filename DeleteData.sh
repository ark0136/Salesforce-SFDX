if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

headline "Starting Data Deletion (DeleteData.sh)";


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

#IFS=';'
for table in `echo $bamboo_table_names`
do
log "Querying for data from Table: $table"
log "sfdx force:data:soql:query -q \"SELECT Id FROM $table\" -u  \"$sandboxUsername\" -r csv"
sfdx force:data:soql:query -q "SELECT Id FROM $table" -u  "$sandboxUsername" -r csv > file1.csv
log "Deleting data from Table: $table"
log "sfdx force:data:bulk:delete -s $table -f file1.csv -w 10 -u \"$sandboxUsername\""
sfdx force:data:bulk:delete -s $table -f file1.csv -w 10 -u "$sandboxUsername"
log "Completed Data deletion from $table"
rm file1.csv

done

headline "Finished  Data Deletion (DeleteData.sh)" "-";