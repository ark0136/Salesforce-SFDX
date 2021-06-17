if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

#export bamboo_sfUsername=integration_user@adp.com
#export bamboo_sfSandboxName=makkenas1
#export usr_list="ron.davis@cdk.com lee.gregory@cdk.com maggie.madrzyk@cdk.com"
export usr_list="saradhi.makkena@cdk.com poorna.pemmasani@cdk.com"

headline "Updating Profile and Role ($0)";

for usr in $usr_list
do

log "sfdx force:data:record:update -u $bamboo_sfUsername.$bamboo_sfSandboxName -s User -w Username=$usr.$bamboo_sfSandboxName -v \"ProfileId='00e40000000rAoYAAU' UserRoleId='00E40000000oFd3EAE'\""
sfdx force:data:record:update -u $bamboo_sfUsername.$bamboo_sfSandboxName -s User -w Username=$usr.$bamboo_sfSandboxName -v "ProfileId='00e40000000rAoYAAU' UserRoleId='00E40000000oFd3EAE'"

done
headline "Updated Profile and Role ($0)" "-";
