#!/bin/bash

##########################################################################################################################
# Script: MiniFetch
# Autor: ThinkRoot
# Versiune: 4

# Descriere:
#   MiniFetch este un script Bash interactiv care furnizează informații detaliate despre sistemul de operare pe care rulează.
#   Acesta afișează informații precum numele utilizatorului și gazda, sistemul de operare și versiunea kernelului, arhitectura sistemului, timpul de funcționare, numărul total de pachete instalate, spațiul de stocare disponibil și utilizat, memoria utilizată și informații despre procesor. Utilizatorul poate folosi acest script pentru depanare și administrare a sistemului.

# Utilizare:
# 1. Deschide terminalul și navighează în directorul în care ai salvat scriptul.
# 2. Acordă permisiuni de executare pentru script folosind comanda: chmod +x MiniFetch.sh.
# 3. Rulează scriptul fără argumente pentru a afișa informațiile standard sau rulează cu argumentul "-a" pentru a afișa toate informațiile.

##########################################################################################################################

# Definește culorile pentru afișare
LIGHT_BLUE='\033[1;34m'
LIGHT_GREEN='\033[1;32m'
NC='\033[0m' # No Color
RED='\033[0;31m'

# Funcție pentru a afișa informațiile standard
show_standard_info() {
    echo -e "${LIGHT_BLUE}Bun venit la MiniFetch!${NC}"
    echo -e "${LIGHT_GREEN}Utilizator:${NC} $(whoami)"
    echo -e "${LIGHT_GREEN}Gazdă:${NC} $(hostname)"
    echo -e "${LIGHT_GREEN}Sistem de operare:${NC} $(uname -s)"
    echo -e "${LIGHT_GREEN}Versiunea kernelului:${NC} $(uname -r)"
    echo -e "${LIGHT_GREEN}Arhitectura:${NC} $(uname -m)"
    echo -e "${LIGHT_GREEN}Timp de funcționare:${NC} $(uptime -p)"
    echo -e "${LIGHT_GREEN}Pachete instalate:${NC} $(count_packages)"

    show_storage_info

    echo -e "${LIGHT_GREEN}Memorie utilizată:${NC} $(free -h --si | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "${LIGHT_GREEN}Procesor:${NC} $(awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//')"
    echo -e "${LIGHT_BLUE}Mulțumesc că ai folosit MiniFetch!${NC}"
}

# Funcție pentru a afișa informațiile despre pachetele instalate
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

# Funcție pentru a detecta managerul de pachete
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

# Funcție pentru a număra pachetele Flatpak instalate
count_flatpaks() {
    if command -v flatpak &>/dev/null; then
        flatpak list | wc -l
    else
        echo "0"
    fi
}

# Funcție pentru a număra pachetele Snap instalate
count_snaps() {
    if command -v snap &>/dev/null; then
        snap list | tail -n +2 | wc -l
    else
        echo "0"
    fi
}

# Funcție pentru a afișa informațiile despre spațiul de stocare
show_storage_info() {
    echo -e "${LIGHT_GREEN}Spațiu de stocare:${NC}"
    # Obținem informațiile despre spațiul de stocare pentru partițiile / și /home (dacă există)
    while read -r filesystem size used avail percent mountpoint; do
        echo -e "${LIGHT_BLUE}Partiția ${mountpoint}: ${NC} ${used} spațiu utilizat / ${size} spațiu total."
    done < <(df -hP / /home 2>/dev/null | awk 'NR>1')
}


# Funcție pentru a afișa toate informațiile
show_all_info() {
    show_standard_info
    echo -e "${LIGHT_GREEN}Pachete Flatpak instalate:${NC} $(count_flatpaks)"
    echo -e "${LIGHT_GREEN}Pachete Snap instalate:${NC} $(count_snaps)"
}

# Verifică dacă există argumente de linie de comandă
if [ $# -eq 0 ]; then
    show_standard_info
elif [ "$1" == "-a" ]; then
    show_all_info
else
    echo -e "${RED}Eroare: Argument nevalid! Utilizare: ./MiniFetch.sh [-a]${NC}"
fi

