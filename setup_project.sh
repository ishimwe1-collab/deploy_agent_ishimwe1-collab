#!/usr/bin/env bash

# =========================
# Attendance Project Setup
# =========================

# --- Colors ---
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

# --- Trap function for Ctrl+C ---
cleanup() {
    echo -e "\n${RED}⚠️ Script interrupted! Archiving current project...${RESET}"
    if [ -d "$DIR" ]; then
        tar -czf "${DIR}_archive.tar.gz" "$DIR"
        echo -e "${GREEN}📦 Project archived as ${DIR}_archive.tar.gz${RESET}"
        rm -rf "$DIR"
        echo -e "${YELLOW}🗑 Incomplete project folder removed${RESET}"
    fi
    exit 1
}

trap cleanup SIGINT

# =========================
# Functions for each stage
# =========================

create_main_dir() {
    echo -e "${BOLD}${CYAN}Stage 1: Create Main Directory${RESET}"
    read -p "Enter suffix for project directory: " input
    DIR="attendance_tracker_${input}"
    mkdir -p "$DIR"
    echo -e "${GREEN}Directory $DIR created successfully!${RESET}"
}

create_structure() {
    echo -e "${BOLD}${BLUE}Stage 2: Create Internal Structure${RESET}"
    mkdir -p "$DIR/Helpers"
    mkdir -p "$DIR/reports"
    echo -e "${GREEN}Internal folders Helpers/ and reports/ created successfully!${RESET}"
}

copy_files() {
    echo -e "${BOLD}${MAGENTA}Stage 3: Copy Project Files${RESET}"
    # Root files
    cp attendance_checker.py "$DIR/"
    cp image.png "$DIR/"
    # Helpers
    cp assets.csv "$DIR/Helpers/"
    cp config.json "$DIR/Helpers/"
    # Reports
    cp reports.log "$DIR/reports/"
    echo -e "${GREEN}All project files copied successfully!${RESET}"
}

configure_thresholds() {
    echo -e "${BOLD}${YELLOW}Stage 4: Configure Thresholds${RESET}"
    
    read -p "Do you want to update attendance thresholds? (y/n): " update_choice
    
    if [[ "$update_choice" == "y" || "$update_choice" == "Y" ]]; then
        read -p "Enter Warning threshold (default 75): " warning
        read -p "Enter Failure threshold (default 50): " failure
        
        # Set default values if empty
        warning=${warning:-75}
        failure=${failure:-50}
        
        CONFIG_FILE="$DIR/Helpers/config.json"

        # Cross-platform sed: works on Linux and macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS: need empty string for -i
            sed -i '' "s/\"Warning\": *[0-9]\+/\"Warning\": $warning/" "$CONFIG_FILE"
            sed -i '' "s/\"Failure\": *[0-9]\+/\"Failure\": $failure/" "$CONFIG_FILE"
        else
            # Linux/WSL
            sed -i "s/\"Warning\": *[0-9]\+/\"Warning\": $warning/" "$CONFIG_FILE"
            sed -i "s/\"Failure\": *[0-9]\+/\"Failure\": $failure/" "$CONFIG_FILE"
        fi

        echo -e "${GREEN}✅ config.json updated successfully! Warning=$warning%, Failure=$failure%${RESET}"
    else
        echo -e "${CYAN}⚠️ Thresholds left unchanged.${RESET}"
    fi
}


python_check() {
    echo -e "${BOLD}${CYAN}Stage 5: Python Environment Check${RESET}"
    if command -v python3 &>/dev/null; then
        echo -e "${GREEN} Python3 is installed: $(python3 --version)${RESET}"
    else
        echo -e "${RED} Python3 is NOT installed. Please install it to run the application.${RESET}"
    fi
}

# =========================
# Menu / Stage Selection
# =========================

while true; do
    echo ""
    echo -e "${BOLD}${BLUE}===== Attendance Project Setup Menu =====${RESET}"
    echo -e "${CYAN}1) Create main directory${RESET}"
    echo -e "${CYAN}2) Create internal structure${RESET}"
    echo -e "${CYAN}3) Copy project files${RESET}"
    echo -e "${CYAN}4) Configure thresholds${RESET}"
    echo -e "${CYAN}5) Python environment check${RESET}"
    echo -e "${CYAN}6) Run full setup${RESET}"
    echo -e "${YELLOW}0) Exit${RESET}"
    read -p "Select an option [0-6]: " choice

    case $choice in
        1) create_main_dir ;;
        2) create_structure ;;
        3) copy_files ;;
        4) configure_thresholds ;;
        5) python_check ;;
        6)
            create_main_dir
            create_structure
            copy_files
            configure_thresholds
            python_check
            echo -e "${GREEN} Full setup completed successfully!${RESET}"
            ;;
        0) echo -e "${CYAN}Exiting setup.${RESET}"; exit 0 ;;
        *) echo -e "${RED}Invalid option, please choose 0-6.${RESET}" ;;
    esac
done
