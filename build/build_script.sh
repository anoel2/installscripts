#!/usr/bin/bash

# Function to check the operating system
check_os() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ $ID == "ubuntu" ]]; then
            echo "Detected Ubuntu. Running deb22_build.sh..."
            ./deb22_build.sh
        elif [[ $ID == "rhel" ]]; then
            echo "Detected RHEL. Running rhel9_build.sh..."
            ./rhel9_build.sh
        else
            echo "Unsupported operating system."
            exit 1
        fi
    else
        echo "Unable to determine the operating system."
        exit 1
    fi
}

# Main execution
check_os
