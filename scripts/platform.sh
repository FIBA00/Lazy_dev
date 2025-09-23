#!/bin/bash

# ==============================================================================
# platform.sh: Detects the platform and provides helper functions.
#
# This script identifies the operating system (Linux, Windows/Git Bash, Termux)
# and sets environment variables and helper functions to abstract away
# platform-specific differences, such as package managers and file paths.
# ==============================================================================

# --- Platform Detection ---
PLATFORM="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ -n "$ANDROID_ROOT" ]]; then
        PLATFORM="termux"
    else
        PLATFORM="linux"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    PLATFORM="windows"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
else
    log_error "Unsupported platform: $OSTYPE" 1
fi

# --- Expose Platform Variables ---
export PLATFORM

# --- Platform-Specific Variables ---
export USER_HOME="$HOME"
export SHELL_RC_FILE=""

# Determine the correct shell configuration file
case "$(basename "$SHELL")" in
    bash)
        # For Git Bash on Windows, .bashrc is not sourced by default.
        if [[ "$PLATFORM" == "windows" ]]; then
            # .bash_profile is a safer bet for login shells.
            if [ -f "$USER_HOME/.bash_profile" ]; then
                SHELL_RC_FILE="$USER_HOME/.bash_profile"
            else
                # Fallback to .profile if it exists, otherwise create .bash_profile
                [ ! -f "$USER_HOME/.profile" ] && touch "$USER_HOME/.bash_profile"
                SHELL_RC_FILE="$USER_HOME/.bash_profile"
            fi
        else
            SHELL_RC_FILE="$USER_HOME/.bashrc"
        fi
        ;;
    zsh)
        SHELL_RC_FILE="$USER_HOME/.zshrc"
        ;;
    *)
        log_warn "Unsupported shell: $(basename "$SHELL"). Defaulting to .profile."
        SHELL_RC_FILE="$USER_HOME/.profile"
        ;;
esac

export SHELL_RC_FILE

# --- Helper Functions ---

# Checks if a command exists.
# Usage: command_exists "git"
command_exists() {
    command -v "$1" &> /dev/null
}

# Executes a command and logs success or failure.
# Usage: execute_cmd "description" "command_to_run"
execute_cmd() {
    local description="$1"
    local cmd="$2"

    log_info "$description..."
    if eval "$cmd"; then
        log_success "$description completed."
    else
        log_error "$description failed. See output above for details." 1
    fi
}

# Installs packages using the appropriate package manager.
# Usage: install_packages "git" "curl" "jq"
install_packages() {
    if ! command_exists "sudo" && [[ $EUID -ne 0 ]]; then
        log_error "sudo command not found, and not running as root. Cannot install packages." 1
    fi

    local pkgs=("$@")
    log_info "Installing packages: ${pkgs[*]}"

    case "$PLATFORM" in
        linux)
            if command_exists "apt-get"; then
                execute_cmd "System update" "sudo apt-get update -y"
                execute_cmd "Package installation" "sudo apt-get install -y ${pkgs[*]}"
            elif command_exists "pacman"; then
                execute_cmd "Package installation" "sudo pacman -Syu --noconfirm ${pkgs[*]}"
            else
                log_error "Unsupported Linux package manager. Please install packages manually." 1
            fi
            ;;
        termux)
            execute_cmd "System update" "pkg update -y"
            execute_cmd "Package installation" "pkg install -y ${pkgs[*]}"
            ;;
        windows)
            log_warn "Windows package installation is not automated. Please install manually."
            log_info "Required packages: ${pkgs[*]}"
            # Future enhancement: Add Chocolatey or Scoop support here.
            ;;
        macos)
            if ! command_exists "brew"; then
                log_error "Homebrew not found. Please install it first." 1
            fi
            execute_cmd "Homebrew update" "brew update"
            execute_cmd "Package installation" "brew install ${pkgs[*]}"
            ;;
        *)
            log_error "Package installation not supported on this platform." 1
            ;;
    esac
}
