#!/bin/bash

# Check if script is being run as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

puppetservername=""
puppetserverip=""

# Install Puppet
rpm -Uvh https://yum.puppet.com/puppet7-release-el-7.noarch.rpm
yum install puppet-agent -y

# Set Puppet server and bootstrap SSL
/opt/puppetlabs/bin/puppet config set server $puppetservername --section main
/opt/puppetlabs/bin/puppet ssl bootstrap

# Update hosts file
echo "$puppetserverip $puppetservername" >> /etc/hosts

# Enable and start Puppet service
systemctl enable puppet
systemctl start puppet
