#!/bin/bash

# Check if script is being run as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

puppetservername=""
puppetserverip=""

# Install Puppet
pkgadd -d https://downloads.puppetlabs.com/solaris/puppet7-release-7.12-1.noarch.pkg.gz
pkg install puppet-agent

# Set Puppet server and bootstrap SSL
/opt/puppetlabs/bin/puppet config set server $puppetservername --section main
/opt/puppetlabs/bin/puppet ssl bootstrap

# Update hosts file
echo "$puppetserverip $puppetservername" >> /etc/hosts

# Enable and start Puppet service
svcadm enable puppet
svcadm restart puppet
