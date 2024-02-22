#!/bin/bash

### RHEL9.3 Build Script ###

# Instructions:
# 1. Set SNMP configuration variables before running the script.
# 2. Make sure to provide SNMP_USER, SNMP_AUTH_PASS, and SNMP_PRIV_PASS as arguments when executing the script.
# 3. Check the log file "build_script.log" for details on the script execution.

# Initialize log file
LOG_FILE="build_script.log"
echo "Build script started at $(date)" > "$LOG_FILE"

# Function to log messages
log_message() {
    local message=$1
    echo "$message" >> "$LOG_FILE"
}

# Function to display help
display_help() {
    echo "Usage: ./build_script.sh <SNMP_USER> <SNMP_AUTH_PASS> <SNMP_PRIV_PASS>"
    echo "Set SNMP configuration variables before running the script."
    echo "Check the log file 'build_script.log' for details on the script execution."
}

# Function to handle errors
handle_error() {
    local rc=$?
    local lineno=$1
    local command=$2

    if [ $rc -ne 0 ]; then
        log_message "Error occurred in command: $command at line $lineno."
        echo "Error occurred in command: $command at line $lineno. Check $LOG_FILE for details."
        exit 1
    else
        log_message "Warning: Non-critical issue encountered in command: $command at line $lineno. Continuing..."
        echo "Warning: Non-critical issue encountered in command: $command at line $lineno."
    fi
}

# Function to run commands with error handling and logging
run_command() {
    local command=$1
    $command
    handle_error $LINENO "$command"
}

# Set SNMP configuration variables
SNMP_USER="$1"
SNMP_AUTH_PASS="$2"
SNMP_PRIV_PASS="$3"

subscribe_and_update() {
    run_command "subscription-manager --refresh --activationkey=End_User --org=3585003 --pool=2c94dfc48bd4a8f6018bdf3d3f213604"
    log_message "Subscribed and updated."
}

enable_epel_repository() {
    run_command "subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms"
    run_command "sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y"
    log_message "Enabled EPEL repository."
    log_message "Installed EPEL repository package."
}

install_required_packages() {
    sudo yum update -y
    sudo yum groupinstall -y 'Development Tools'
    echo "Updated system and installed development tools"
    
    dnf install -y \
        vim git wget curl php perl python3 ruby gcc g++ \
        clamav clamav-freshclam mysql mysql-server rkhunter \
        openssl-devel libuuid-devel libseccomp-devel squashfs-tools \
        slurm gparted make mlocate net-snmp net-snmp-utils \
        net-snmp-devel docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin libXcomposite \
        libXcursor libXi libXtst libXrandr alsa-lib mesa-libEGL \
        libXdamage mesa-libGL libXScrnSaver
}

install_singularity() {
    VERSION=3.0.3
    curl -L https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz | tar -xzf -
    cd singularity-${VERSION}
    make -C builddir install --prefix=/opt/singularity
    . /usr/local/etc/bash_completion.d/singularity
}

configure_snmp() {
    systemctl stop snmpd
    net-snmp-config --create-snmpv3-user -A "$SNMP_AUTH_PASS" -X "$SNMP_PRIV_PASS" -a SHA -x AES "$SNMP_USER"
    firewall-cmd --permanent --add-port=161/udp
}

enable_services() {
    systemctl enable docker clamav-daemon snmpd
    systemctl start snmpd docker clamav-daemon
}

install_anaconda() {
    curl -O https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
    bash Anaconda3-2023.09-0-Linux-x86_64.sh -b -p ~/anaconda3 > /dev/null
    export PATH=~/anaconda3/bin:$PATH
}

install_node_exporter() {
    wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
    tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
}

install_kubectl() {
    curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl completion bash >> ~/.bashrc
    . ~/.bashrc
}

install_go() {
    wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
}

install_minikube() {
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
}

update_clamav_signatures() {
    sudo freshclam --quiet
}

main() {
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        display_help
        exit 0
    }

    subscribe_and_update
    enable_epel_repository
    install_required_packages
    install_singularity
    configure_snmp
    enable_services
    install_anaconda
    install_node_exporter
    install_kubectl
    install_go
    install_minikube
    update_clamav_signatures
    log_message "RHEL 9.3 build script completed successfully."
    echo "RHEL 9.3 build script completed. Check $LOG_FILE for details."
}

main "$@"
