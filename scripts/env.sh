#!/bin/bash

# ==================================================================================================
#
# Title: Lazy_dev Environment Setup
# Description: This script detects the operating system and calls the appropriate
#              environment setup script from the Setup directory.
# Author: Gemini
# Date: 2025-09-26
#
# ==================================================================================================

set -euo pipefail
IFS=$'\n\t'

# Function to detect the operating system
detect_os() {
    if [[ "$(uname)" == "Linux" ]]; then
        if [[ -f "/data/data/com.termux/files/usr/bin/bash" ]]; then
            echo "Termux"
        else
            echo "Linux"
        fi
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "MacOS"
    elif [[ "$(uname)" == "CYGWIN"* || "$(uname)" == "MINGW"* || "$(uname)" == "MSYS"* ]]; then
        echo "Windows"
    else
        echo "Unknown"
    fi
}

# Main script logic
main() {
    OS=$(detect_os)
    echo "===> Detected Operating System for environment setup: $OS"

    case "$OS" in
        "Linux" | "Termux")
            echo "===> Running Linux environment setup..."
            source ../Setup/setup_linux_env.sh
            ;; 
        "MacOS")
            echo "===> MacOS environment setup is not yet implemented."
            # source ../Setup/setup_macos_env.sh
            ;; 
        "Windows")
            echo "===> Windows environment setup is not yet implemented."
            # source ../Setup/setup_windows_env.ps1
            ;; 
        *)
            echo "===> Unsupported operating system for environment setup."
            exit 1
            ;; 
    esac
}

main "$@"