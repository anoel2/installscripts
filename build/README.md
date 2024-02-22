Build Script Automation

This repository contains two build scripts (deb22_build.sh and rhel9_build.sh) for setting up a development environment on Ubuntu 22 and RHEL 9 systems, respectively. Additionally, there is a script (build_script.sh) that detects the operating system and runs the appropriate build script based on the detected OS.
Script Descriptions. I have written these primarily for use in an HPC environment where the system is going to be used for containerization. Feel free to adapt this to your own needs. 

    deb22_build.sh: This script is designed to set up the development environment on Ubuntu 22 systems. It installs required packages, configures SNMP settings, enables services, installs various tools such as Singularity, Anaconda, Node Exporter, kubectl, Go, Minikube, and updates ClamAV signatures.

    rhel9_build.sh: This script is tailored for setting up the development environment on RHEL 9 systems. It performs similar tasks to the Ubuntu script but is customized for the RHEL environment.

    build_script.sh: This script is a wrapper script that detects the operating system of the host machine and then executes the appropriate build script (deb22_build.sh for Ubuntu and rhel9_build.sh for RHEL).

Usage

To use the build scripts:

    Ensure that all scripts are placed in the same directory.
    Make sure the necessary permissions are set to execute the scripts.
    Run the build_script.sh script, which will automatically detect the operating system and execute the corresponding build script.

Example Usage:

./build_script.sh

The build_script.sh script will detect the operating system and run the appropriate build script (either deb22_build.sh for Ubuntu or rhel9_build.sh for RHEL).
