#!/bin/bash

# Check if script is being run as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

authpass=""
cryptopass=""
authalgo="SHA"
cryptoalgo="AES"
snmpuser=""

svcadm disable -t svc:/application/management/sma:default
/usr/bin/net-snmp-config -ro --create-snmpv3-user -a $authalgo -A $authpass -x $cryptoalgo -X $cryptopass $snmpuser
svcadm enable svc:/application/management/net-snmp:default
