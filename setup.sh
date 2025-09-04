#!/bin/bash

# Detect platform: Linux or Termux
if [ -d "/data/data/com.termux/files" ]; then
    PLATFORM="termux"
    PACKAGE_MANAGER="pkg"
    SUDO=""
    echo "📱 Running on Termux"
else
    PLATFORM="linux"
    PACKAGE_MANAGER="sudo apt-get"
    SUDO="sudo"
    echo "💻 Running on Linux"
fi

LOG_FILE="setup.log"
exec > >(tee -i "$LOG_FILE") 2>&1

# Function to check internet
check_internet() {
    echo "🌐 Checking internet..."
    if ping -q -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        echo "✅ Internet OK"
    else
        echo "❌ No internet connection"
        exit 1
    fi
}

check_internet

# Update system
echo "🔄 Updating packages..."
$SUDO $PACKAGE_MANAGER update -y
$SUDO $PACKAGE_MANAGER upgrade -y

# Install Git
echo "🔧 Installing Git..."
$SUDO $PACKAGE_MANAGER install git -y

# Install Python
echo "🐍 Installing Python and pip..."
$SUDO $PACKAGE_MANAGER install python -y
$SUDO $PACKAGE_MANAGER install python-pip -y || echo "✅ pip comes with Python in Termux"

# Install extra tools
echo "🔧 Installing dev tools..."
$SUDO $PACKAGE_MANAGER install curl wget unzip jq htop -y

# Configure Git
echo "🔧 Git configuration..."
read -p "Enter Git username: " git_username
read -p "Enter Git email: " git_email
git config --global user.name "$git_username"
git config --global user.email "$git_email"

# Virtual environment
read -p "Do you want to create a virtual environment? (yes/no): " create_venv
if [[ "$create_venv" =~ ^(yes|y)$ ]]; then
    python3 -m venv venv
    source venv/bin/activate
fi

# SSH setup
echo "🔐 Setting up SSH..."
$SUDO $PACKAGE_MANAGER install openssh -y
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
    read -p "Enter your GitHub email: " github_email
    ssh-keygen -t ed25519 -C "$github_email" -f "$SSH_KEY" -N ""
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY"
    cat "$SSH_KEY.pub"
    echo "📌 Add this key to GitHub"
fi

# Aliases
echo "🔧 Adding aliases..."
SHELL_RC="$HOME/.bashrc"
echo "alias ll='ls -lah'" >> "$SHELL_RC"
echo "alias gs='git status'" >> "$SHELL_RC"
echo "alias py='python3'" >> "$SHELL_RC"
echo "alias pip='pip3'" >> "$SHELL_RC"

source "$SHELL_RC"
echo "✅ Done! Restart your shell or run: source $SHELL_RC"
