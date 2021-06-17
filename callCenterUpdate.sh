if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

#export bamboo_sfUsername=integration_user@adp.com
#export bamboo_sfSandboxName=makkenas

headline "Updating Call Center Changes ($0)";

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
    <members>cc</members>
    <name>CallCenter</name>
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

export list="CCEPMC Sales SystemAdmins"
export CTIAdapter_URL="https://iagentsfc-qat-ord.support.cdk.com:8121/Default.html"

for i in $list
do
	cp ../../manifest/package.xml ../../manifest/package.xml_bkp
	sed -i "s/cc/$i/g" ../../manifest/package.xml
	log "sfdx force:source:retrieve -u ${bamboo_sfUsername}.${bamboo_sfSandboxName} --manifest ../../manifest/package.xml"
	sfdx force:source:retrieve -u ${bamboo_sfUsername}.${bamboo_sfSandboxName} --manifest ../../manifest/package.xml
	cp ../../manifest/package.xml_bkp ../../manifest/package.xml 
done

src=`grep -A 2 "CTI Adapter URL" force-app/main/default/callCenters/CCEPMC.callCenter-meta.xml |tail -1`
sed -i "s#$src#<value>$CTIAdapter_URL</value>#g" force-app/main/default/callCenters/CCEPMC.callCenter-meta.xml
sed -i "s#.*<adapterUrl>.*#<adapterUrl>$CTIAdapter_URL</adapterUrl>#g" force-app/main/default/callCenters/CCEPMC.callCenter-meta.xml

src=`grep -A 2 "CTI Adapter URL" force-app/main/default/callCenters/Sales.callCenter-meta.xml |tail -1`
sed -i "s#$src#<value>$CTIAdapter_URL</value>#g" force-app/main/default/callCenters/Sales.callCenter-meta.xml
sed -i "s#.*<adapterUrl>.*#<adapterUrl>$CTIAdapter_URL</adapterUrl>#g" force-app/main/default/callCenters/Sales.callCenter-meta.xml

src=`grep -A 2 "CTI Adapter URL" force-app/main/default/callCenters/SystemAdmins.callCenter-meta.xml |tail -1`
sed -i "s#$src#<value>$CTIAdapter_URL</value>#g" force-app/main/default/callCenters/SystemAdmins.callCenter-meta.xml
sed -i "s#.*<adapterUrl>.*#<adapterUrl>$CTIAdapter_URL</adapterUrl>#g" force-app/main/default/callCenters/SystemAdmins.callCenter-meta.xml

log "sfdx force:source:deploy -u ${bamboo_sfUsername}.${bamboo_sfSandboxName} -p ./force-app -w 2"
sfdx force:source:deploy -u ${bamboo_sfUsername}.${bamboo_sfSandboxName} -p ./force-app -w 2

cd -

headline "Updated Call Center Changes ($0)" "-";
