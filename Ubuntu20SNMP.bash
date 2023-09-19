#!/bin/bash

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
