#!/bin/bash

# ==============================================================================
# env.sh: Defines and exports environment variables.
#
# This script is intended to define environment variables that are used across
# the setup scripts. It should source the platform utilities to ensure that
# any platform-specific paths or variables are available.
#
# Example:
# export DEV_PROJECTS_DIR="$USER_HOME/projects"
# ==============================================================================

# --- Source Utilities ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/platform.sh"

log_info "Sourcing environment variables..."

# --- Variable Definitions ---
# Add any custom environment variable exports here.
# For example:
# export MY_CUSTOM_VAR="my_value"

log_success "Environment variables sourced."
