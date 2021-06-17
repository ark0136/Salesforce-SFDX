if [ ! "$(type -t headline)" = 'function' ]; then
    source ./utility.sh
fi

headline "Creating a new Certificate (createCert.sh)";

cwd=$(pwd)
passphrase="SalesforceSandboxManagement";

#if the keys directory does not exist, create it
if ! [ -d "keys" ]; then
    mkdir keys
    log "Created keys/ directory"
fi

cd keys
openssl genrsa -des3 -passout pass:$passphrase -out server.pass.key 2048
openssl rsa -passin pass:$passphrase -in server.pass.key -out server.key
rm server.pass.key
openssl req -new -passin pass:word -key server.key -out server.csr -subj "/C=US/O=CDK Global, LLC/OU=CDK GLOBAL Validated/CN=*.cdkglobal.com/L=Hoffman Estates/ST=Illinois, "
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
cd $cwd

headline "Certificate Created." "-";
headline "Please upload server.crt to Salesforce Connected App." "-";