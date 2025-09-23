#!/bin/bash

# ==============================================================================
# setup.sh: Main entry point for the cross-platform setup system.
#
# This script determines the user's platform and executes the corresponding
# setup script. It acts as the main orchestrator.
# ==============================================================================

# --- Source Utilities ---
# Get the directory of the currently executing script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the logger and platform utility scripts
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/platform.sh"

# --- Main Logic ---
main() {
    log_info "Starting setup..."
    log_info "Detected Platform: $PLATFORM"

    # Source environment variables
    source "$SCRIPT_DIR/env.sh"

    # Execute the appropriate setup script based on the platform
    case "$PLATFORM" in
        linux|macos|windows)
            log_info "Running PC setup..."
            source "$SCRIPT_DIR/pc.sh"
            ;;
        termux)
            log_info "Running Termux setup..."
            source "$SCRIPT_DIR/termux.sh"
            ;;
        *)
            log_error "No setup script available for platform: $PLATFORM" 1
            ;;
    esac

    log_success "All setup scripts completed."
}

# --- Run Main ---
main
