#!/bin/bash

# OneGhostty Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/GonzFC/OneGhostty/main/install.sh | bash

REPO_RAW_URL="https://raw.githubusercontent.com/GonzFC/OneGhostty/main"
INSTALL_DIR="$HOME/.config/oneghostty"
BIN_NAME="oneghostty"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Installing OneGhostty...${NC}"

# 1. Create Directories
mkdir -p "$INSTALL_DIR/configs"

# 2. Download Files (using curl)
echo "Downloading scripts and configs..."

download_file() {
    local url="$1"
    local dest="$2"
    if curl -fsSL "$url" -o "$dest"; then
        echo "  - Downloaded $(basename "$dest")"
    else
        echo -e "${RED}Error downloading $(basename "$dest")${NC}"
        exit 1
    fi
}

download_file "$REPO_RAW_URL/oneghostty.sh" "$INSTALL_DIR/oneghostty.sh"
download_file "$REPO_RAW_URL/configs/starship-ghostty.toml" "$INSTALL_DIR/configs/starship-ghostty.toml"
download_file "$REPO_RAW_URL/configs/starship-gruv.toml" "$INSTALL_DIR/configs/starship-gruv.toml"
download_file "$REPO_RAW_URL/configs/starship-badger.toml" "$INSTALL_DIR/configs/starship-badger.toml"

# 3. Make executable
chmod +x "$INSTALL_DIR/oneghostty.sh"

# 4. Add to PATH (via alias)
# Detect Shell
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    # Fallback detection based on file existence
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    else
        SHELL_CONFIG="$HOME/.profile"
    fi
fi

ALIAS_CMD="alias $BIN_NAME='$INSTALL_DIR/oneghostty.sh'"

if [ -f "$SHELL_CONFIG" ]; then
    if ! grep -q "$ALIAS_CMD" "$SHELL_CONFIG"; then
        echo "Adding alias to $SHELL_CONFIG..."
        echo "" >> "$SHELL_CONFIG"
        echo "# OneGhostty" >> "$SHELL_CONFIG"
        echo "$ALIAS_CMD" >> "$SHELL_CONFIG"
        echo -e "${GREEN}Alias added! Restart your terminal or run 'source $SHELL_CONFIG' to use '$BIN_NAME' command.${NC}"
    else
        echo "Alias already exists in $SHELL_CONFIG."
    fi
else
    echo -e "${RED}Could not find a shell config file (.zshrc or .bashrc).${NC}"
    echo "Please manually add this alias to your shell config:"
    echo "  $ALIAS_CMD"
fi

# 5. Run it now
echo -e "${GREEN}Installation complete! Launching OneGhostty...${NC}"

# If running via pipe (curl | bash), stdin is the pipe, not the keyboard.
# We need to explicitly read from /dev/tty to allow user interaction.
if [ -e /dev/tty ]; then
    "$INSTALL_DIR/oneghostty.sh" < /dev/tty
else
    echo "Cannot detect TTY. Please restart your terminal and run 'oneghostty' manually."
fi
