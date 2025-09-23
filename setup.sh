#!/bin/bash

# ==============================================================================
# setup.sh: Main entry point for cross-platform development environment setup.
#
# This script detects the platform and runs the appropriate setup script.
# It supports Linux, Windows (Git Bash/WSL), macOS, and Termux on Android.
# ==============================================================================

# Determine the directory of the current script (repo root)
REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_DIR="$REPO_ROOT/scripts"

# Source utility scripts
source "$SCRIPTS_DIR/logger.sh"
source "$SCRIPTS_DIR/platform.sh"

# Set up logging
LOG_FILE="$REPO_ROOT/setup.log"
exec > >(tee -i "$LOG_FILE") 2>&1

log_info "🚀 Starting setup process..."
log_info "📂 Repository root: $REPO_ROOT"
log_info "💻 Detected platform: $PLATFORM"

# Function to check internet
check_internet() {
    log_info "🌐 Checking internet connection..."
    
    # Platform-specific internet check
    case "$PLATFORM" in
        windows)
            if ping -n 1 8.8.8.8 > /dev/null 2>&1; then
                log_success "✅ Internet connection OK"
                return 0
            fi
            ;;
        *)  # Linux, macOS, Termux
            if ping -q -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
                log_success "✅ Internet connection OK"
                return 0
            fi
            ;;
    esac
    
    log_error "❌ No internet connection detected"
    exit 1
}

# Check internet connectivity
check_internet

# Determine which script to run based on platform
case "$PLATFORM" in
    termux)
        SCRIPT_TO_RUN="$SCRIPTS_DIR/termux.sh"
        ;;
    windows|linux|macos)
        SCRIPT_TO_RUN="$SCRIPTS_DIR/pc.sh"
        ;;
    *)
        log_error "❌ Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

# Run the platform-specific script
if [ -f "$SCRIPT_TO_RUN" ]; then
    log_info "🚀 Executing $SCRIPT_TO_RUN..."
    bash "$SCRIPT_TO_RUN"
    log_success "✅ Setup completed successfully!"
else
    log_error "❌ Script $SCRIPT_TO_RUN not found!"
    exit 1
fi
