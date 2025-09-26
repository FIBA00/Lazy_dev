#!/bin/bash
source ./logger.sh

# Determine the directory of the current script (repo root)
REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_DIR="$REPO_ROOT/scripts"  # Put your pc.sh and termux.sh here

# Detect platform: Linux or Termux
if [ -d "/data/data/com.termux/files" ]; then
    PLATFORM="termux"
    PACKAGE_MANAGER="pkg"
    SUDO=""
    SETUP_SCRIPT="$SCRIPTS_DIR/termux.sh"
    ENV_SCRIPT="$SCRIPTS_DIR/env.sh"

echo "📱 Running on Termux"
else
    PLATFORM="linux"
    PACKAGE_MANAGER="sudo apt-get"
    SUDO="sudo"
    SETUP_SCRIPT="$SCRIPTS_DIR/pc.sh"
    ENV_SCRIPT="$SCRIPTS_DIR/env.sh"
echo "💻 Running on Linux"
fi

LOG_FILE="$REPO_ROOT/setup.log"
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

# check the internet before continue
check_internet

# Run the platform-specific script
if [ -f "$SETUP_SCRIPT" ]; then
    echo "🚀 Executing $SETUP_SCRIPT ..."
    bash "$SETUP_SCRIPT"
else
    echo "❌ Script $SETUP_SCRIPT not found!"
    exit 1
fi


