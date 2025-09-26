#!/bin/bash
source ./linux/utils/logger.sh
source ./linux/utils/platform_detect.sh

# Determine the directory of the current script (repo root)
REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TOOLS_DIR="$REPO_ROOT/linux/tools"

# Detect platform: Linux or Termux
if [ "$PLATFORM" == "termux" ]; then
    SETUP_SCRIPT="$TOOLS_DIR/termux.sh"
    log_info "📱 Running on Termux"
else
    SETUP_SCRIPT="$TOOLS_DIR/pc.sh"
    log_info "💻 Running on Linux"
fi

# Function to check internet
check_internet() {
    log_info "🌐 Checking internet..."
    if ping -q -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        log_info "✅ Internet OK"
    else
        log_error "❌ No internet connection"
        exit 1
    fi
}

# check the internet before continue
check_internet

# Run the platform-specific script
if [ -f "$SETUP_SCRIPT" ]; then
    log_info "🚀 Executing $SETUP_SCRIPT ..."
    bash "$SETUP_SCRIPT"
else
    log_error "❌ Script $SETUP_SCRIPT not found!"
    exit 1
fi


