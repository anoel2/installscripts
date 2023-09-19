#!/bin/bash

authpass=""
cryptopass=""
authalgo="SHA"
cryptoalgo="AES"
snmpuser=""

yum install net-snmp net-snmp-utils net-snmp-devel -y
systemctl stop snmpd
net-snmp-config --create-snmpv3-user -A $authpass -X $cryptopass -a $authalgo -x $cryptoalgo $snmpuser
firewall-cmd --permanent --add-port=161/udp
yum firewall-cmd --add-port=161/udp
firewall-cmd --reload
systemctl enable snmpd
systemctl start snmpd
