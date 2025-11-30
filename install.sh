#!/bin/bash

# OneGhostty Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/GonzFC/OneGhostty/main/install.sh | bash

REPO_URL="https://github.com/GonzFC/OneGhostty.git"
INSTALL_DIR="$HOME/.config/oneghostty"
BIN_NAME="oneghostty"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Installing OneGhostty...${NC}"

# 1. Clone/Update Repository
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating OneGhostty..."
    cd "$INSTALL_DIR"
    git pull origin main
else
    echo "Cloning OneGhostty..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# 2. Make executable
chmod +x "$INSTALL_DIR/oneghostty.sh"

# 3. Add to PATH (via alias in zshrc)
SHELL_CONFIG="$HOME/.zshrc"
ALIAS_CMD="alias $BIN_NAME='$INSTALL_DIR/oneghostty.sh'"

if ! grep -q "$ALIAS_CMD" "$SHELL_CONFIG"; then
    echo "Adding alias to $SHELL_CONFIG..."
    echo "" >> "$SHELL_CONFIG"
    echo "# OneGhostty" >> "$SHELL_CONFIG"
    echo "$ALIAS_CMD" >> "$SHELL_CONFIG"
    echo -e "${GREEN}Alias added! Restart your terminal or run 'source $SHELL_CONFIG' to use '$BIN_NAME' command.${NC}"
else
    echo "Alias already exists in $SHELL_CONFIG."
fi

# 4. Run it now
echo -e "${GREEN}Installation complete! Launching OneGhostty...${NC}"
"$INSTALL_DIR/oneghostty.sh"
