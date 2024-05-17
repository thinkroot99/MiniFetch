#!/bin/bash

##########################################################################################################################
# Script: MiniFetch
# Author: ThinkRoot
# Version: 4.1

# Description:
#   MiniFetch is an interactive Bash script that provides detailed information about the operating system it runs on.
#   It displays information such as the username and hostname, operating system and kernel version, system architecture, uptime, total number of installed packages, available and used storage space, memory usage, and processor information. Users can use this script for system troubleshooting and administration.

# Usage:
# 1. Open the terminal and navigate to the directory where you saved the script.
# 2. Grant execution permissions to the script using the command: chmod +x MiniFetch.sh.
# 3. Run the script without arguments to display standard information or run with the "-a" argument to display all information.

##########################################################################################################################

# Define colors for display
LIGHT_BLUE='\033[1;34m'
LIGHT_GREEN='\033[1;32m'
NC='\033[0m' # No Color
RED='\033[0;31m'

# Function to display standard information
show_standard_info() {
    echo -e "${LIGHT_BLUE}Welcome to MiniFetch!${NC}"
    echo -e "${LIGHT_GREEN}User:${NC} $(whoami)"
    echo -e "${LIGHT_GREEN}Hostname:${NC} $(hostname)"
    echo -e "${LIGHT_GREEN}Operating System:${NC} $(uname -s)"
    echo -e "${LIGHT_GREEN}Kernel Version:${NC} $(uname -r)"
    echo -e "${LIGHT_GREEN}Architecture:${NC} $(uname -m)"
    echo -e "${LIGHT_GREEN}Uptime:${NC} $(uptime -p)"
    echo -e "${LIGHT_GREEN}Installed Packages:${NC} $(count_packages)"

    show_storage_info

    echo -e "${LIGHT_GREEN}Memory Usage:${NC} $(free -h --si | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "${LIGHT_GREEN}Processor:${NC} $(awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//')"
    echo -e "${LIGHT_BLUE}Thank you for using MiniFetch!${NC}"
}

# Function to display information about installed packages
count_packages() {
    local package_count
    case "$(get_package_manager)" in
        "rpm") package_count=$(rpm -qa --qf "%{NAME}\n" | wc -l) ;;
        "dpkg") package_count=$(dpkg -l | grep '^ii' | wc -l) ;;
        "pacman") package_count=$(pacman -Qq | wc -l) ;;
        "apk") package_count=$(apk info | wc -l) ;;
        *) package_count="N/A" ;;
    esac
    echo "$package_count RPM $(count_flatpaks) Flatpak $(count_snaps) Snap"
}

# Function to detect the package manager
get_package_manager() {
    if command -v rpm &>/dev/null; then
        echo "rpm"
    elif command -v dpkg &>/dev/null; then
        echo "dpkg"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v apk &>/dev/null; then
        echo "apk"
    else
        echo "N/A"
    fi
}

# Function to count installed Flatpak packages
count_flatpaks() {
    if command -v flatpak &>/dev/null; then
        flatpak list | wc -l
    else
        echo "0"
    fi
}

# Function to count installed Snap packages
count_snaps() {
    if command -v snap &>/dev/null; then
        snap list | tail -n +2 | wc -l
    else
        echo "0"
    fi
}

# Function to display storage information
show_storage_info() {
    echo -e "${LIGHT_GREEN}Storage Space:${NC}"
    # Get storage space information for the / and /home partitions (if they exist)
    while read -r filesystem size used avail percent mountpoint; do
        echo -e "${LIGHT_BLUE}Partition ${mountpoint}: ${NC} ${used} used space / ${size} total space."
    done < <(df -hP / /home 2>/dev/null | awk 'NR>1')
}


# Function to display all information
show_all_info() {
    show_standard_info
    echo -e "${LIGHT_GREEN}Installed Flatpak Packages:${NC} $(count_flatpaks)"
    echo -e "${LIGHT_GREEN}Installed Snap Packages:${NC} $(count_snaps)"
}

# Check for command line arguments
if [ $# -eq 0 ]; then
    show_standard_info
elif [ "$1" == "-a" ]; then
    show_all_info
else
    echo -e "${RED}Error: Invalid argument! Usage: ./MiniFetch.sh [-a]${NC}"
fi
