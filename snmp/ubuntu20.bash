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

apt-get -y install snmp snmpd libsnmp-dev
service snmpd stop
net-snmp-config --create-snmpv3-user -A $authpass -X $cryptopass -a $authalgo -x $cryptoalgo $snmpuser
ufw allow snmp
systemctl start snmpd
systemctl enable snmpd
