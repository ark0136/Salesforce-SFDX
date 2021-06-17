if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

#export bamboo_sfUsername=integration_user@adp.com
#export bamboo_sfSandboxName=makkenas
#export Tests=DSC_AccountSetup_Test

headline "Running 'compiling and code coverage' of Apex classes ($0)";
rm -rf ./TESTS_RESULTS
mkdir ./TESTS_RESULTS
log "sfdx force:apex:test:run -n $bamboo_sfTests  -d ./TESTS_RESULTS -u $bamboo_sfUsername.$bamboo_sfSandboxName -w 2"
sfdx force:apex:test:run -n $bamboo_sfTests  -d ./TESTS_RESULTS -u $bamboo_sfUsername.$bamboo_sfSandboxName -w 2
TestID=`cat ./TESTS_RESULTS/test-run-id.txt`
log "sfdx force:apex:test:report -i $TestID -u $bamboo_sfUsername.$bamboo_sfSandboxName -c"
log "################################################################################################"
sfdx force:apex:test:report -i $TestID -u $bamboo_sfUsername.$bamboo_sfSandboxName -c
log "################################################################################################"

headline "Completed 'compiling and code coverage' of Apex classes ($0)" "-";
