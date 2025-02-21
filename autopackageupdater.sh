#!/bin/bash

# Function to detect the package manager
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        if command -v yay &> /dev/null; then
            echo "yay"
        elif command -v paru &> /dev/null; then
            echo "paru"
        else
            echo "pacman"
        fi
    elif command -v emerge &> /dev/null; then
        echo "emerge"
    else
        echo "unsupported"
    fi
}

# Function to update all packages
update_packages() {
    case $1 in
        apt)
            echo "Updating packages using apt..."
            sudo apt update && sudo apt upgrade -y
            ;;
        dnf)
            echo "Updating packages using dnf..."
            sudo dnf upgrade -y
            ;;
        pacman)
            echo "Updating packages using pacman..."
            sudo pacman -Syu --noconfirm
            ;;
        yay)
            echo "Updating packages using yay..."
            yay -Syu --noconfirm
            ;;
        paru)
            echo "Updating packages using paru..."
            paru -Syu --noconfirm
            ;;
        emerge)
            echo "Updating packages using emerge..."
            sudo emerge --sync
            sudo emerge -auDN @world
            ;;
        *)
            echo "Unsupported package manager. Exiting..."
            exit 1
            ;;
    esac
}

# Function to remove orphaned packages
remove_orphans() {
    case $1 in
        apt)
            echo "Removing orphaned packages using apt..."
            sudo apt autoremove -y
            ;;
        dnf)
            echo "Removing orphaned packages using dnf..."
            sudo dnf autoremove -y
            ;;
        pacman)
            echo "Removing orphaned packages using pacman..."
            sudo pacman -Rns $(pacman -Qdtq) --noconfirm 2>/dev/null
            ;;
        yay)
            echo "Removing orphaned packages using yay..."
            yay -Rns $(yay -Qdtq) --noconfirm 2>/dev/null
            ;;
        paru)
            echo "Removing orphaned packages using paru..."
            paru -Rns $(paru -Qdtq) --noconfirm 2>/dev/null
            ;;
        emerge)
            echo "Removing orphaned packages using emerge..."
            sudo emerge --depclean
            ;;
        *)
            echo "Unsupported package manager. Exiting..."
            exit 1
            ;;
    esac
}

# Function to clean package cache
clean_cache() {
    case $1 in
        apt)
            echo "Cleaning package cache using apt..."
            sudo apt clean
            ;;
        dnf)
            echo "Cleaning package cache using dnf..."
            sudo dnf clean all
            ;;
        pacman)
            echo "Cleaning package cache using pacman..."
            sudo pacman -Sc --noconfirm
            ;;
        yay)
            echo "Cleaning package cache using yay..."
            yay -Sc --noconfirm
            ;;
        paru)
            echo "Cleaning package cache using paru..."
            paru -Sc --noconfirm
            ;;
        emerge)
            echo "Cleaning package cache using emerge..."
            sudo eclean-dist --deep
            ;;
        *)
            echo "Unsupported package manager. Exiting..."
            exit 1
            ;;
    esac
}

# Function to perform a full system update
full_update() {
    update_packages "$1"
    remove_orphans "$1"
    clean_cache "$1"
}

# Function to display the menu
show_menu() {
    echo "===================================="
    echo "  Universal Auto Updater            "
    echo "===================================="
    echo "1. Update all packages"
    echo "2. Remove orphaned packages"
    echo "3. Clean package cache"
    echo "4. Full system update (update + remove orphans + clean cache)"
    echo "5. Exit"
    echo "===================================="
}

# Main script logic
package_manager=$(detect_package_manager)
if [[ "$package_manager" == "unsupported" ]]; then
    echo "Unsupported distribution or package manager. Exiting..."
    exit 1
fi

while true; do
    show_menu
    read -p "Enter your choice (1-5): " choice
    case $choice in
        1)
            update_packages "$package_manager"
            ;;
        2)
            remove_orphans "$package_manager"
            ;;
        3)
            clean_cache "$package_manager"
            ;;
        4)
            full_update "$package_manager"
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice! Please select a valid option."
            ;;
    esac
    read -p "Press Enter to return to the menu..."
done
