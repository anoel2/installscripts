#!/bin/bash

# Check if script is being run as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

puppetservername=""
puppetserverip=""

# Install Puppet
wget https://apt.puppetlabs.com/puppet7-release-focal.deb
dpkg -i puppet7-release-focal.deb
apt-get update
apt-get install puppet-agent

# Set Puppet server and bootstrap SSL
/opt/puppetlabs/bin/puppet config set server $puppetservername --section main
/opt/puppetlabs/bin/puppet ssl bootstrap

# Update hosts file
echo "$puppetserverip $puppetservername" >> /etc/hosts

# Start and enable Puppet service
systemctl start puppet
systemctl enable puppet
