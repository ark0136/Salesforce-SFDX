if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

#export bamboo_sfUsername=integration_user@adp.com
#export bamboo_sfSandboxName=makkenas

headline "Retriving site Changes ($0)";

sfdx force:org:list --all
mkdir scripts
rm -rf ./scripts/CHANGES
log "sfdx force:project:create -n ./scripts/CHANGES"
sfdx force:project:create -n ./scripts/CHANGES 2>&1 | tee ./scripts/initError.txt

mkdir manifest
cat >manifest/package.xml <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
    <members>SN</members>
    <name>RemoteSiteSetting</name>
    </types>
    <version>50.0</version>
</Package>
EOF

cd ./scripts/CHANGES
if [ $? -ne 0 ]
then
	echo "Failed to create CHANGES project"
	exit 1
fi

list="DMIURL SalesforceLogin WorkRelay"
export DMIURL_URL="https://cs53.salesforce.com"
export SalesforceLogin_URL="https://test.salesforce.com"
export WorkRelay_URL="https://cdk--$bamboo_sfSandboxName--wr-bpm.visualforce.com"

for siteName in $list
do
	cp ../../manifest/package.xml ../../manifest/package.xml_bkp
	sed -i "s/SN/$siteName/g" ../../manifest/package.xml
	log "sfdx force:source:retrieve -u ${bamboo_sfUsername}.${bamboo_sfSandboxName} --manifest ../../manifest/package.xml"
	sfdx force:source:retrieve -u ${bamboo_sfUsername}.${bamboo_sfSandboxName} --manifest ../../manifest/package.xml
	cp ../../manifest/package.xml_bkp ../../manifest/package.xml 
done

sed -i "s#.*<url>.*#<url>$DMIURL_URL</url>#g" force-app/main/default/remoteSiteSettings/DMIURL.remoteSite-meta.xml
sed -i "s#.*<url>.*#<url>$SalesforceLogin_URL</url>#g" force-app/main/default/remoteSiteSettings/SalesforceLogin.remoteSite-meta.xml
sed -i "s#.*<url>.*#<url>$WorkRelay_URL</url>#g" force-app/main/default/remoteSiteSettings/WorkRelay.remoteSite-meta.xml

log "sfdx force:source:deploy -u ${bamboo_sfUsername}.${bamboo_sfSandboxName} -p ./force-app -w 2"
sfdx force:source:deploy -u ${bamboo_sfUsername}.${bamboo_sfSandboxName} -p ./force-app -w 2

cd -

headline "Retrived site Changes ($0)" "-";
