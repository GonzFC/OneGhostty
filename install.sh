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

# 3. Install Starship
if ! command -v starship &> /dev/null; then
    echo "Starship not found. Installing..."
    # Distro-agnostic install (works on macOS/Linux/BSD)
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "Starship is already installed."
fi

# 4. Install Nerd Font (JetBrains Mono)
FONT_NAME="JetBrainsMono"
if [ "$(uname)" == "Darwin" ]; then
    FONT_DIR="$HOME/Library/Fonts"
    OS_TYPE="Mac"
else
    FONT_DIR="$HOME/.local/share/fonts"
    OS_TYPE="Linux"
fi

# Check if font seems to be installed (rough check)
if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    echo "Installing JetBrains Mono Nerd Font..."
    mkdir -p "$FONT_DIR"
    # Download a single TTF to save bandwidth/complexity, or a small zip
    # Using a direct link to a reliable patched font release
    curl -fLo "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" \
        "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"
    
    if [ "$OS_TYPE" == "Linux" ]; then
        if command -v fc-cache &> /dev/null; then
            echo "Updating font cache..."
            fc-cache -f "$FONT_DIR"
        fi
    fi
    echo "Font installed. You may need to set 'JetBrainsMono Nerd Font' in your terminal settings."
else
    echo "Nerd Font appears to be installed."
fi

# 5. Configure Shell (Alias + Init)
chmod +x "$INSTALL_DIR/oneghostty.sh"

# Detect Shell
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" = "zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    INIT_CMD='eval "$(starship init zsh)"'
elif [ "$CURRENT_SHELL" = "bash" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
    INIT_CMD='eval "$(starship init bash)"'
else
    # Fallback
    SHELL_CONFIG="$HOME/.profile"
    INIT_CMD='eval "$(starship init bash)"' # Best guess
fi

ALIAS_CMD="alias $BIN_NAME='$INSTALL_DIR/oneghostty.sh'"

if [ -f "$SHELL_CONFIG" ]; then
    echo "Configuring $SHELL_CONFIG..."
    
    # Add Alias
    if ! grep -q "$ALIAS_CMD" "$SHELL_CONFIG"; then
        echo "$ALIAS_CMD" >> "$SHELL_CONFIG"
        echo "Added alias."
    fi
    
    # Add Starship Init
    if ! grep -q "starship init" "$SHELL_CONFIG"; then
        echo "" >> "$SHELL_CONFIG"
        echo "# OneGhostty Starship Init" >> "$SHELL_CONFIG"
        echo "$INIT_CMD" >> "$SHELL_CONFIG"
        echo "Added Starship initialization."
    fi
else
    echo -e "${RED}Could not find shell config ($SHELL_CONFIG).${NC}"
    echo "Please add the following to your shell config manually:"
    echo "  $ALIAS_CMD"
    echo "  $INIT_CMD"
fi

# 6. Run it now
echo -e "${GREEN}Installation complete! Launching OneGhostty...${NC}"

# If running via pipe (curl | bash), stdin is the pipe, not the keyboard.
# We need to explicitly read from /dev/tty to allow user interaction.
if [ -e /dev/tty ]; then
    "$INSTALL_DIR/oneghostty.sh" < /dev/tty
else
    echo "Cannot detect TTY. Please restart your terminal and run 'oneghostty' manually."
fi
