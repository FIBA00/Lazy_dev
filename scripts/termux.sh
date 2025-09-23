#!/bin/bash

# ==============================================================================
# termux.sh: Termux-specific setup tasks.
#
# This script handles the setup process for the Termux environment on Android.
# It sources utility scripts for logging and platform detection to ensure
# operations are robust and maintainable.
# ==============================================================================

# --- Source Utilities ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/platform.sh"

# --- Main Setup Logic ---

# Function to install Termux-specific packages
setup_termux_packages() {
    log_info "Installing essential Termux packages..."
    # Termux uses 'pkg' as its package manager, which is handled by platform.sh
    # 'openssh' is needed for SSH functionality.
    local termux_tools=("git" "python" "openssh" "curl" "wget" "unzip" "jq" "htop")
    install_packages "${termux_tools[@]}"
}

# Function to handle Git configuration (same as in pc.sh, but can be customized)
setup_git() {
    log_info "Starting Git setup for Termux..."
    if ! command_exists "git"; then
        log_error "Git is not installed. Please run package setup first."
        return
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
        log_success "Git has been configured for Termux."
    else
        log_info "Skipping Git configuration update."
    fi
}

# Function to handle SSH key generation (same as in pc.sh)
setup_ssh_keys() {
    log_info "Starting SSH key setup for Termux..."
    local ssh_dir="$USER_HOME/.ssh"
    local ssh_key_path="$ssh_dir/id_ed25519"

    if [ -f "$ssh_key_path" ]; then
        log_success "SSH key already exists. Skipping generation."
        return
    fi

    log_info "Generating a new SSH key."
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

    read -p "Enter the email for your SSH key: " ssh_email
    if [ -z "$ssh_email" ]; then
        log_error "Email cannot be empty. Aborting." 1
    fi

    execute_cmd "SSH key generation" "ssh-keygen -t ed25519 -C \"$ssh_email\" -f \"$ssh_key_path\" -N ''"

    log_info "To use this key with GitHub, copy the public key below:"
    cat "$ssh_key_path.pub"
    log_info "Press Enter to continue after adding the key..."
    read -r

    # Termux may require starting the agent manually
    if ! pgrep -u "$(whoami)" ssh-agent > /dev/null; then
        execute_cmd "Starting ssh-agent" "eval \$(ssh-agent -s)"
    fi

    execute_cmd "Adding SSH key to agent" "ssh-add $ssh_key_path"
    execute_cmd "Testing GitHub SSH connection" "ssh -T git@github.com"
}

# Function to add shell aliases
setup_shell_aliases() {
    log_info "Configuring shell aliases for Termux..."
    if [ -z "$SHELL_RC_FILE" ] || [ ! -f "$SHELL_RC_FILE" ]; then
        log_error "Could not determine shell config file. Skipping alias setup."
        return
    fi

    if grep -q "# LAZY_DEV_ALIASES_TERMUX" "$SHELL_RC_FILE"; then
        log_success "Termux aliases already configured. Skipping."
        return
    fi

    log_info "Adding aliases to $SHELL_RC_FILE..."
    cat <<EOL >> "$SHELL_RC_FILE"

# LAZY_DEV_ALIASES_TERMUX - Added by setup script
alias ll='ls -lah --color=auto'
alias gs='git status'
alias py='python3'
# Add any other Termux-specific aliases here

EOL
    log_success "Aliases added. Please run 'source $SHELL_RC_FILE' or restart your shell."
}

# --- Script Entry Point ---
main() {
    log_info "Starting Termux-specific setup..."

    setup_termux_packages
    setup_git
    setup_ssh_keys
    setup_shell_aliases

    log_success "Termux setup completed successfully!"
}

# Run the main function
main
