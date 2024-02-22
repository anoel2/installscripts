#!/usr/bin/bash

### Ubuntu Build Script ###

# Instructions:
# 1. Check and set the necessary configuration variables and paths before running the script.
# 2. Provide SNMP_USER, SNMP_AUTH_PASS, and SNMP_PRIV_PASS as arguments when executing the script.
# 3. Review the log file "build_script.log" for detailed execution information.

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
    echo "Usage: ./ubuntu_build_script.sh <SNMP_USER> <SNMP_AUTH_PASS> <SNMP_PRIV_PASS>"
    echo "Instructions for running the Ubuntu Build Script:"
    echo "1. Ensure all necessary configuration variables are set in the script."
    echo "2. Run the script with 'sudo ./ubuntu_build_script.sh SNMP_USER SNMP_AUTH_PASS SNMP_PRIV_PASS'."
    echo "3. Check the log file 'build_script.log' for detailed information."
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

install_required_packages() {
    sudo apt update
    sudo apt install -y \
        vim git wget curl php perl python3 ruby gcc g++ \
        clamav mysql-server rkhunter \
        build-essential libssl-dev uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev pkg-config \
        slurm gparted mlocate snmp snmpd docker-ce docker-ce-cli containerd.io \
        libxcomposite1 libxcursor1 libxi6 libxtst6 libxrandr2 libasound2 libegl1 \
        libxdamage1 libgl1 libxss1
    log_message "Updated system and installed required packages."
}

install_singularity() {
    export VERSION=3.0.3 && # adjust this as necessary \
    mkdir -p $GOPATH/src/github.com/sylabs && \
    cd $GOPATH/src/github.com/sylabs && \
    wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
    tar -xzf singularity-${VERSION}.tar.gz && \
    cd ./singularity && \
    ./mconfig && \
    make -C ./builddir && \
    sudo make -C ./builddir install
    ./mconfig --prefix=/opt/singularity
}

configure_snmp() {
    sudo service snmpd stop
    echo "createUser $1 SHA '$2' $3 'AES'" | sudo tee -a /var/lib/snmp/snmpd.conf
    sudo iptables -A INPUT -p udp --dport 161 -j ACCEPT
    log_message "Configured SNMP settings."
}

enable_services() {
    sudo systemctl enable docker.service clamav-daemon.service snmpd.service
    sudo systemctl start docker.service clamav-daemon.service snmpd.service
    log_message "Enabled and started services."
}

install_anaconda() {
    wget https://repo.anaconda.com/archive/Anaconda3-2023.09-Linux-x86_64.sh
    bash Anaconda3-2023.09-Linux-x86_64.sh -b -p ~/anaconda3
    echo 'export PATH=~/anaconda3/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
    log_message "Installed Anaconda."
}

install_node_exporter() {
    wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
    tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
    log_message "Installed Node Exporter."
}

install_kubectl() {
    sudo snap install kubectl --classic
    log_message "Installed kubectl."
}

install_go() {
    wget https://golang.org/dl/go1.22.2.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    source ~/.bashrc
    log_message "Installed Go."
}

install_minikube() {
    wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    log_message "Installed Minikube."
}

update_clamav_signatures() {
    sudo freshclam --quiet
    log_message "Updated ClamAV signatures."
}

main() {
    install_required_packages
    configure_snmp
    enable_services
    install_singularity
    install_anaconda
    install_node_exporter
    install_kubectl
    install_go
    install_minikube
    update_clamav_signatures
    log_message "Ubuntu build script completed successfully."
    echo "Ubuntu build script completed. Check $LOG_FILE for details."
}

main
