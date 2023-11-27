#!/bin/bash
# Check if script is being run as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

puppetservername=""
puppetserverip=""


rpm -Uvh https://yum.puppet.com/puppet7-release-el-8.noarch.rpm
yum install puppet puppet-agent -y
source /etc/profile.d/puppet-agent.sh
puppet config set server $puppetserver --section main
puppet ssl bootstrap
echo "$puppetserverip $puppetservername">> /etc/hosts
systemctl start puppet
systemctl enable puppet
