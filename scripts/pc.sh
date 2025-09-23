#!/bin/bash

# ==============================================================================
# pc.sh: PC-specific setup tasks (Linux, Windows, macOS).
#
# This script orchestrates the setup process for a standard PC environment.
# It sources utility scripts for logging and platform detection, ensuring
# that all operations are cross-platform compatible.
# ==============================================================================

# --- Source Utilities ---
# Get the directory of the currently executing script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the logger and platform utility scripts
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/platform.sh"

# --- Main Setup Logic ---

# Function to handle Git configuration
setup_git() {
    log_info "Starting Git setup..."
    if ! command_exists "git"; then
        install_packages "git"
    else
        log_success "Git is already installed."
    fi

    local current_username=$(git config --global user.name)
    local current_email=$(git config --global user.email)

    log_info "Current Git user: $current_username <$current_email>"
    read -p "Do you want to update Git configuration? (y/N): " -r choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        read -p "Enter your Git username: " git_username
        read -p "Enter your Git email: " git_email

        execute_cmd "Git username configuration" "git config --global user.name \"$git_username\""
        execute_cmd "Git email configuration" "git config --global user.email \"$git_email\""
        execute_cmd "Git UI color configuration" "git config --global color.ui auto"
        log_success "Git has been configured."
    else
        log_info "Skipping Git configuration update."
    fi
}

# Function to set up the development environment
setup_dev_env() {
    log_info "Setting up essential development tools..."
    # Define a list of packages to install. This can be expanded.
    local dev_tools=("curl" "wget" "unzip" "jq" "htop")
    install_packages "${dev_tools[@]}"
}

# Function to handle SSH key generation
setup_ssh_keys() {
    log_info "Starting SSH key setup..."
    local ssh_dir="$USER_HOME/.ssh"
    local ssh_key_path="$ssh_dir/id_ed25519"

    if [ -f "$ssh_key_path" ]; then
        log_success "SSH key already exists at $ssh_key_path. Skipping generation."
        return
    fi

    log_info "Generating a new SSH key."
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

    read -p "Enter the email for your SSH key: " ssh_email
    if [ -z "$ssh_email" ]; then
        log_error "Email cannot be empty. Aborting SSH key generation." 1
    fi

    execute_cmd "SSH key generation" "ssh-keygen -t ed25519 -C \"$ssh_email\" -f \"$ssh_key_path\" -N ''"

    log_info "To use this key with GitHub, add the following public key to your account:"
    cat "$ssh_key_path.pub"
    log_info "Press Enter to continue after adding the key to GitHub..."
    read -r
    
    execute_cmd "Testing GitHub SSH connection" "ssh -T git@github.com"
}

# Function to add shell aliases
setup_shell_aliases() {
    log_info "Configuring shell aliases..."
    if [ -z "$SHELL_RC_FILE" ] || [ ! -f "$SHELL_RC_FILE" ]; then
        log_error "Could not determine shell configuration file. Skipping alias setup."
        return
    fi

    # Use a marker to prevent adding aliases multiple times
    if grep -q "# LAZY_DEV_ALIASES" "$SHELL_RC_FILE"; then
        log_success "Aliases already configured. Skipping."
        return
    fi

    log_info "Adding aliases to $SHELL_RC_FILE..."
    cat <<EOL >> "$SHELL_RC_FILE"

# LAZY_DEV_ALIASES - Added by setup script
alias ll='ls -alh --color=auto'
alias gs='git status'
alias gp='git pull'
alias ga='git add .'
alias gc='git commit -m'
alias gco='git checkout'
alias py='python3'
alias up='sudo apt-get update && sudo apt-get upgrade -y' # Note: This is Linux-specific.
# A cross-platform update alias would need more logic in platform.sh

EOL
    log_success "Aliases added. Please run 'source $SHELL_RC_FILE' or restart your shell."
}


# --- Script Entry Point ---
main() {
    log_info "Starting PC setup for platform: $PLATFORM"

    setup_git
    setup_dev_env
    setup_ssh_keys
    setup_shell_aliases

    log_success "PC setup completed successfully!"
}

# Run the main function
main