#!/bin/bash
source ../utils/logger.sh

# ==================================================================================================
#
# Title: Lazy_dev Environment Setup
# Description: This script detects the operating system and calls the appropriate
#              environment setup script.
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
    log_info "===> Detected Operating System for environment setup: $OS"

    case "$OS" in
        "Linux" | "Termux")
            log_info "===> Running Linux environment setup..."
            source ./setup_linux_env.sh
            ;;
        "MacOS")
            log_warning "===> MacOS environment setup is not yet implemented."
            ;;
        "Windows")
            log_warning "===> Windows environment setup is not yet implemented."
            ;;
        *)
            log_error "===> Unsupported operating system for environment setup."
            exit 1
            ;;
    esac
}

main "$@"
