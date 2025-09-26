#!/bin/bash
# Platform detection script for cross-platform compatibility
# This script detects the operating system and sets appropriate variables

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logger.sh"

# Enable debug logging for platform detection
set_log_level "DEBUG"

# Global variable to cache HOME_DIR
CACHED_HOME_DIR=""

# Function to detect platform
detect_platform() {
    # Default to unknown
    PLATFORM="unknown"
    IS_WINDOWS=false
    IS_LINUX=false
    IS_MAC=false

    log_debug "OSTYPE: $OSTYPE"
    log_debug "OS: $OS"

    # Check for Windows (Git Bash, Cygwin, WSL, PowerShell)
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
        PLATFORM="windows"
        IS_WINDOWS=true
        log_debug "Detected Windows via OSTYPE/OS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check for WSL
        if grep -q Microsoft /proc/version 2>/dev/null; then
            PLATFORM="windows-wsl"
            IS_WINDOWS=true
            log_debug "Detected WSL"
        else
            PLATFORM="linux"
            IS_LINUX=true
            log_debug "Detected Linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="mac"
        IS_MAC=true
        log_debug "Detected macOS"
    fi

    # Explicit check for PowerShell
    if command -v powershell.exe &>/dev/null || command -v pwsh &>/dev/null; then
        PLATFORM="windows"
        IS_WINDOWS=true
        log_debug "Detected Windows via PowerShell"
    fi

    # Fallback detection using uname
    if [[ "$PLATFORM" == "unknown" ]]; then
        local uname_result=$(uname -s)
        log_debug "Using uname fallback: $uname_result"
        case "$uname_result" in
            Linux*)     PLATFORM="linux"; IS_LINUX=true ;;
            Darwin*)    PLATFORM="mac"; IS_MAC=true ;;
            CYGWIN*|MINGW*|MSYS*) PLATFORM="windows"; IS_WINDOWS=true ;;
            *)          PLATFORM="unknown" ;;
        esac
    fi

    log_debug "Final platform detection: $PLATFORM"

    # Export variables for use in other scripts
    export PLATFORM
    export IS_WINDOWS
    export IS_LINUX
    export IS_MAC

    # Return platform name
    echo "$PLATFORM"
}

# Function to get appropriate home directory
# Global variable to cache HOME_DIR
CACHED_HOME_DIR=""

function get_home_dir() {
    if [[ -n "$CACHED_HOME_DIR" ]]; then
        echo "$CACHED_HOME_DIR"
        return
    fi

    # Use default HOME directory
    CACHED_HOME_DIR="$HOME"
    log_debug "platform_detect.sh: Using HOME_DIR: $CACHED_HOME_DIR"
    echo "$CACHED_HOME_DIR"
}

# Function to get appropriate config directory
get_shell_config() {
    if [[ "$IS_WINDOWS" == true ]]; then
        # Git Bash typically uses .bashrc in the home directory
        echo "$(get_home_dir)/.bashrc"
    elif [[ "$IS_LINUX" == true ]]; then
        echo "$HOME/.bashrc"
    elif [[ "$IS_MAC" == true ]]; then
        # macOS typically uses .bash_profile or .zshrc
        if [[ -f "$HOME/.zshrc" ]]; then
            echo "$HOME/.zshrc"
        else
            echo "$HOME/.bash_profile"
        fi
    else
        # Default fallback
        echo "$HOME/.bashrc"
    fi
}

# Function to get appropriate package manager command
get_package_manager_cmd() {
    if [[ "$IS_WINDOWS" == true ]]; then
        echo "echo 'Package installation not supported in Windows. Please install manually.'"
    elif [[ "$IS_LINUX" == true ]]; then
        if command -v apt &> /dev/null; then
            echo "sudo apt update && sudo apt install -y"
        elif command -v dnf &> /dev/null; then
            echo "sudo dnf install -y"
        elif command -v yum &> /dev/null; then
            echo "sudo yum install -y"
        else
            echo "echo 'Unsupported Linux distribution. Please install manually.'"
        fi
    elif [[ "$IS_MAC" == true ]]; then
        if command -v brew &> /dev/null; then
            echo "brew install"
        else
            echo "echo 'Homebrew not found. Please install manually.'"
        fi
    else
        echo "echo 'Unsupported platform. Please install manually.'"
    fi
}

# Detect platform when script is sourced
log_debug "Starting platform detection..."
detect_platform
log_debug "Platform detection result: $PLATFORM"
log_debug "PLATFORM variable: $PLATFORM"
log_debug "IS_LINUX variable: $IS_LINUX"
HOME_DIR=$(get_home_dir)
SHELL_CONFIG=$(get_shell_config)
PKG_MANAGER_CMD=$(get_package_manager_cmd)

# Output platform information if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log_info "Detected platform: $PLATFORM"
    log_info "Is Windows: $IS_WINDOWS"
    log_info "Is Linux: $IS_LINUX"
    log_info "Is Mac: $IS_MAC"
    log_info "Home directory: $HOME_DIR"
    log_info "Shell config file: $SHELL_CONFIG"
    log_info "Package manager command: $PKG_MANAGER_CMD"
fi