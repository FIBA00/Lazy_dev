#!/bin/bash

# ==============================================================================
# logger.sh: Provides standardized logging functions.
#
# This script defines a set of functions for logging messages with different
# severity levels (INFO, WARN, ERROR, SUCCESS). It includes color-coding for
# improved readability in terminals that support it.
# ==============================================================================

# --- Color Definitions ---
# Check if the terminal supports colors.
if [[ -t 1 ]] && [[ $(tput colors) -ge 8 ]]; then
    COLOR_RESET="\e[0m"
    COLOR_RED="\e[0;31m"
    COLOR_GREEN="\e[0;32m"
    COLOR_YELLOW="\e[0;33m"
    COLOR_BLUE="\e[0;34m"
else
    COLOR_RESET=""
    COLOR_RED=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_BLUE=""
fi

# --- Logging Functions ---

# Logs an informational message.
# Usage: log_info "Your message here"
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"
}

# Logs a warning message.
# Usage: log_warn "Your message here"
log_warn() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $1"
}

# Logs a success message.
# Usage: log_success "Your message here"
log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $1"
}

# Logs an error message and optionally exits.
# Usage: log_error "Your message here" [exit_code]
log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $1" >&2
    if [[ -n "$2" ]]; then
        exit "$2"
    fi
}
