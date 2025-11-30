#!/bin/bash

# OneGhostty - The Ultimate Starship Prompt Manager
# https://github.com/yourusername/OneGhostty

# --- Configuration ---
CONFIG_DIR="$HOME/.config/oneghostty"
THEME_DIR="$CONFIG_DIR/configs"
TARGET_CONFIG="$HOME/.config/starship.toml"
PREFS_FILE="$CONFIG_DIR/prefs"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- OS Detection ---
OS="$(uname -s)"
case "$OS" in
    Darwin*)    MACHINE="Mac";;
    Linux*)     MACHINE="Linux";;
    *)          MACHINE="UNKNOWN";;
esac

# --- Helper Functions ---
load_prefs() {
    if [ -f "$PREFS_FILE" ]; then
        source "$PREFS_FILE"
    fi
}

save_prefs() {
    echo "CURRENT_THEME=\"$1\"" > "$PREFS_FILE"
}

print_header() {
    clear
    echo -e "${CYAN}"
    echo "   ____             ________              __  __       "
    echo "  / __ \____  ___  / ____/ /_  ____  ____/ /_/ /___  __"
    echo " / / / / __ \/ _ \/ / __/ __ \/ __ \/ ___/ __/ __/ / / /"
    echo "/ /_/ / / / /  __/ /_/ / / / / /_/ (__  ) /_/ /_/ /_/ / "
    echo "\____/_/ /_/\___/\____/_/ /_/\____/____/\__/\__/\__, /  "
    echo "                                               /____/   "
    echo -e "${NC}"
    echo -e "OS: ${YELLOW}$MACHINE${NC} | Current Theme: ${GREEN}${CURRENT_THEME:-None}${NC}"
    echo "--------------------------------------------------------"
}

apply_theme() {
    local theme_name=$1
    local theme_file=$2

    if [ -f "$theme_file" ]; then
        # Ensure target directory exists
        mkdir -p "$(dirname "$TARGET_CONFIG")"
        
        # Copy the config
        cp "$theme_file" "$TARGET_CONFIG"
        
        # Save preference
        save_prefs "$theme_name"
        CURRENT_THEME="$theme_name"
        
        echo -e "\n${GREEN}✔ Successfully switched to $theme_name!${NC}"
        echo -e "Press ${YELLOW}Enter${NC} in your terminal to see the change."
    else
        echo -e "\n${RED}✘ Error: Theme file not found at $theme_file${NC}"
        read -p "Press Enter to continue..."
    fi
}

# --- Main Logic ---

# Ensure config dir exists
mkdir -p "$CONFIG_DIR"

# Resolve script directory to find configs (if running locally/symlinked)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# If configs aren't in ~/.config/oneghostty/configs, try to find them relative to script
if [ ! -d "$THEME_DIR" ]; then
    if [ -d "$SCRIPT_DIR/configs" ]; then
        THEME_DIR="$SCRIPT_DIR/configs"
    else
        echo -e "${RED}Error: Could not find 'configs' directory.${NC}"
        exit 1
    fi
fi

load_prefs

while true; do
    print_header
    echo "Select a Starship prompt style:"
    echo
    echo "1) Ghostty (Original)"
    echo "2) Gruvbox (Retro)"
    echo "3) Badger (Blue/Cool)"
    echo
    echo "q) Quit"
    echo
    read -p "Enter choice [1-3]: " choice

    case $choice in
        1) apply_theme "Ghostty" "$THEME_DIR/starship-ghostty.toml" ;;
        2) apply_theme "Gruvbox" "$THEME_DIR/starship-gruv.toml" ;;
        3) apply_theme "Badger" "$THEME_DIR/starship-badger.toml" ;;
        q|Q) echo "Bye!"; exit 0 ;;
        *) echo -e "${RED}Invalid choice.${NC}"; sleep 1 ;;
    esac
    
    # Optional: Pause to let user see success message
    if [[ "$choice" =~ ^[1-3]$ ]]; then
        sleep 1
    fi
done
