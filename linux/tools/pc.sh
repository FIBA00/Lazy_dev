#!/bin/bash
source ../utils/logger.sh

# Inform the user about the script's purpose and warnings
log_info "------------------------------------------------------"
log_info "🔧 Welcome to the Lazy_dev Setup Script"
log_info " / Press Enter to continue..."
read -r

# Function to ask for input with confirmation
input_checkup() {
    local prompt="$1"
    local default_value="$2"
    local variable_name="$3"
    local user_input

    while true; do
        echo -n "$prompt [$default_value]: "
        read user_input
        user_input="${user_input:-$default_value}"  # Use default if input is empty

        # If the prompt is for a yes/no question, validate it
        if [[ "$prompt" == *"(yes/no)"* ]]; then
            case "$user_input" in
                yes|y|no|n)
                    while true; do
                        echo "You entered: '$user_input'. Is this correct? (yes/no)"
                        read confirmation
                        case "$confirmation" in
                            yes|y) eval "$variable_name=\"$user_input\""; return ;; 
                            no|n) echo "😅 Try again!"; break ;; 
                            *) echo "🤨 Type 'yes' or 'no'!";;
                        esac
                    done
                    ;; 
                *) echo "😆 Type 'yes' or 'no'." ;; 
            esac
        else
            # For non-boolean inputs (e.g., Git username, email), just confirm
            while true; do
                echo "You entered: '$user_input'. Is this correct? (yes/no)"
                read confirmation
                case "$confirmation" in
                    yes|y) eval "$variable_name=\"$user_input\""; return ;; 
                    no|n) echo "😅 Try again!"; break ;; 
                    *) echo "🤨 Type 'yes' or 'no'!";;
                esac
            done
        fi
    done
}

# Ensure the script runs as the current user, not root
if [ "$EUID" -eq 0 ]; then
    log_warning "You are running this script as root!"
    log_warning "Some configurations (like Git and SSH keys) should be done as your normal user."
    
    input_checkup "Do you still want to continue? (yes/no)" "no" continue_as_root

    if [[ "$continue_as_root" != "yes" && "$continue_as_root" != "y" ]]; then
        log_error "Exiting script. Please run as a normal user for best results."
        exit 1
    fi
fi

log_info "🔧 Starting setup...."


# Function to check internet connection
check_internet() {
    log_info "🌐 Checking internet connection..."

    local retries=3  # Number of retries before giving up
    local wait_time=2 # Seconds to wait before retrying
    for ((i=1; i<=retries; i++)); do
        if ping -q -c 1 -W 1 8.8.8.8 >/dev/null 2>&1 || \
           curl -s --head https://google.com | grep "200 OK" >/dev/null || \
           wget -q --spider https://google.com; then
            log_info "✅ Internet is available!"
            return 0  # Success
        fi

        log_warning "⚠️ No internet detected. Retrying in $wait_time seconds... ($i/$retries)"
        sleep $wait_time
    done

    log_error "❌ No internet connection detected. Skipping network-dependent tasks."
    return 1  # Continue script but skip network-related tasks
}

check_internet

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        log_info "✅ Completed task successfully."
    else
        log_error "❌ Task Failed: $1"
        exit 1
    fi
}

# Add ~/.local/bin to PATH for the session
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
log_info "✅ Path added to bash successfully."
source ~/.bashrc

# System Update
log_info "🔧 Updating the system...." | tee -a "$LOG_FILE"
sudo apt-get update -y
check_success "System update"

# Task 1: Git Setup
log_info "🔧 SETTING UP GIT CONFIGURATIONS"
sudo apt-get install -y git
check_success "Git installation"

if command -v git &> /dev/null; then
    log_info "✅ Git is Installed: $(git --version)"
else
    log_error "❌ Git not installed"
    exit 1
fi

# Function to configure Git
configure_git() {
    log_info "🔧 Checking existing Git configuration..." | tee -a "$LOG_FILE"

    # Get current git settings
    current_git_username=$(git config --global user.name)
    current_git_email=$(git config --global user.email)
    current_git_editor=$(git config --global core.editor)

    # If settings exist, ask if the user wants to update
    if [[ -n "$current_git_username" || -n "$current_git_email" || -n "$current_git_editor" ]]; then
        log_warning "Git is already configured with:"
        log_info "   👤 Username: $current_git_username"
        log_info "   📧 Email: $current_git_email"
        log_info "   ✏️ Editor: $current_git_editor"
        input_checkup "Do you want to update Git settings? (yes/no)" "no" update_git

        if [[ "$update_git" != "yes" && "$update_git" != "y" ]]; then
            log_info "✅ Keeping existing Git settings."
            return
        fi
    fi

    # Ask user for new settings
    input_checkup "🔧 Enter your Git username" "$current_git_username" git_username
    input_checkup "🔧 Enter your Git email" "$current_git_email" git_email
    input_checkup "🔧 Enter your preferred Git editor" "$current_git_editor" git_editor

    # Apply the Git configuration
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    git config --global core.editor "$git_editor"
    git config --global color.ui "auto"
    git config --global credential.helper cache

    log_info "✅ Git configured!"
}

# Call the function
configure_git

# Task 3: Installing Essential Development Tools
log_info "✅ Installing essential dev tools"
sudo apt-get install -y curl wget unzip jq htop
check_success "Dev tools installation"

# Task 4: SSH Keys Automation
log_info "🔧 Setting up SSH keys automation..."
if [ ! -d "$HOME/.ssh" ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
fi

# Define SSH key path in the correct home directory
SSH_DIR="$HOME/.ssh"
SSH_KEY_PATH="$SSH_DIR/id_ed25519"

# Ensure the .ssh directory exists
log_info "📁 Ensuring $SSH_DIR directory exists..."
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Check if an SSH key already exists
if [ -f "$SSH_KEY_PATH" ]; then
    log_info "✅ An SSH key already exists at $SSH_KEY_PATH"
else
    log_info "🔑 No SSH key found. Generating a new one..."
    
    # Ask the user for their GitHub email
    input_checkup "🔧 Enter your GitHub email: " "" GITHUB_EMAIL

    # Verify email input is not empty
    if [ -z "$GITHUB_EMAIL" ]; then
        log_error "❌ Email cannot be empty. Please run the script again."
        exit 1
    fi

    log_info "🔧 Generating SSH key..."
    ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$SSH_KEY_PATH" -N ""
    if [ $? -ne 0 ]; then
        log_error "❌ SSH key generation failed."
        exit 1
    fi
    log_info "✅ SSH key generated successfully."
   
    # Start SSH agent if not running
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        log_info "🚀 Starting ssh-agent..."
        eval "$(ssh-agent -s)"
        if [ $? -ne 0 ]; then
            log_error "❌ Failed to start ssh-agent."
            exit 1
        fi
    else
        log_info "🔄 ssh-agent is already running."
    fi

    # Add the SSH key to the agent
    log_info "🔑 Adding SSH key to ssh-agent..."
    ssh-add "$SSH_KEY_PATH"
    if [ $? -ne 0 ]; then
        log_error "❌ Failed to add SSH key to ssh-agent."
        exit 1
    fi

    # Display the SSH public key
    log_info "🔑 Your SSH public key:"
    cat "$SSH_KEY_PATH.pub"
    log_info "------------------------------------------------------"
    log_info "📌 Copy the above key and add it to your GitHub account:"
    log_info "  - Go to GitHub → Settings → SSH and GPG Keys"
    log_info "  - Click 'New SSH Key' and paste the copied key"
    log_info "  - Click 'Add SSH Key'"
    log_info "------------------------------------------------------"
    input_checkup "✅ Have you added the SSH key to GitHub? (yes/no): " "yes" github_confirm

    # Wait for user confirmation before testing connection
    while [[ "$github_confirm" != "yes" && "$github_confirm" != "y" ]]; do
        input_checkup "⏳ Please add the key to GitHub and type 'yes' when done: " "yes" github_confirm
    done

    # Test GitHub SSH connection and store output
    log_info "🔄 Testing SSH connection to GitHub..."
    SSH_OUTPUT=$(ssh -T git@github.com 2>&1)

    # Check for "successfully authenticated" in the output (handle dynamic username)
    if echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
        log_info "🎉 SSH authentication successful! You're ready to use GitHub with SSH."
    else
        log_error "❌ SSH authentication failed. Check your GitHub SSH settings."
        log_error "📌 Output received: $SSH_OUTPUT"
        exit 1
    fi

fi
log_info "✅ SSH setup completed!"

# Task 5: Adding Aliases & Custom Functions to Shell Configuration
USER_SHELL=$(basename "$SHELL")

if [[ "$USER_SHELL" == "bash" ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ "$USER_SHELL" == "zsh" ]]; then
    SHELL_RC="$HOME/.zshrc"
else
    log_warning "⚠️ Unsupported shell: $USER_SHELL"
    exit 1
fi

log_info "✅ Shell detected: $USER_SHELL"
log_info "📌 Configuring: $SHELL_RC"
touch "$SHELL_RC"

add_to_shell_rc() {
    local line="$1"
    if ! grep -qxF "$line" "$SHELL_RC"; then
        echo "$line" >> "$SHELL_RC"
        log_info "✅ Added: $line"
    else
        log_warning "❌ Already exists: $line"
    fi
}

log_info "🔧 Adding aliases and functions to $SHELL_RC..."
add_to_shell_rc "alias ll='ls -lah --color=auto'"
add_to_shell_rc "alias gs='git status'"
add_to_shell_rc "alias gp='git pull'"
add_to_shell_rc "alias ga='git add ."'
add_to_shell_rc "alias gc='git commit -m'"
add_to_shell_rc "alias gco='git checkout'"
add_to_shell_rc "alias venv='source venv/bin/activate'"
add_to_shell_rc "alias py='python3'"
add_to_shell_rc "alias pip='pip3'"
add_to_shell_rc "alias up='sudo apt-get update && sudo apt-get upgrade -y'"

# Add the aliases_help function
if ! grep -q "aliases_help()" "$SHELL_RC"; then
    cat <<EOL >> "$SHELL_RC"

# Function to display alias descriptions
alias_help() {
    echo ""
    echo "📌 Custom Aliases Help:"
    echo "---------------------------------------"
    echo "  ll      → List files in long format with hidden files"
    echo "  gs      → Show Git status"
    echo "  gp      → Git pull latest changes"
    echo "  ga      → Git add all changes"
    echo "  gc 'msg' → Git commit with message"
    echo "  gco br  → Git checkout branch"
    echo "  venv    → Activate Python virtual environment"
    echo "  py      → Use Python 3 by default"
    echo "  pip     → Use pip3 by default"
    echo "  up      → Update and upgrade system packages"
    echo "---------------------------------------"
    echo "💡 Type 'aliases_help' anytime to see this list."
}
EOL
    log_info "✅ aliases_help function added."
else
    log_warning "⚠️ aliases_help function already exists."
fi

# Reload shell configuration
log_info "🔄 Reloading $SHELL_RC..."
source "$SHELL_RC"

log_info "🎉 Shell customization complete! Type 'aliases_help' to test."

# Task 2: Python & Virtual Environment Setup
log_info "🔧 SETTING UP PYTHON AND VIRTUAL ENVIRONMENT"
sudo apt-get install -y python3 python3-pip python3-venv
check_success "Python installation"

# Function to create a virtual environment
create_venv() {
    input_checkup "🔧 Enter name of the virtual environment (default: venv): " "venv" venv_name
    
    if [ -d "$venv_name" ]; then
        log_info "✅ Virtual environment '$venv_name' already exists."
    else
        log_info "🔧 Creating a new Python virtual environment..."
        python3 -m venv "$venv_name"
        check_success "Virtual environment creation"
    fi
    
    # Activate the virtual environment
    source "$venv_name/bin/activate"
}


# Ask the user if they want to create a virtual environment
input_checkup "🔧 Do you want to create a new virtual environment? (yes/no): " "yes" should_create_venv

# Global variable to store --break-system-packages flag
break_system_flag=""
if [[ "$should_create_venv" == "yes" || "$should_create_venv" == "y" ]]; then
    create_venv
else
    input_checkup "🔧 Do you want to install packages globally with --break-system-packages? (yes/no): " "no" break_system
    if [[ "$break_system" == "yes" || "$break_system" == "y" ]]; then
        break_system_flag="--break-system-packages"
        log_info "🔧 Installing pip-tools..."
        pip install pip-tools $break_system_flag
        check_success "pip-tools installation"
    else
        log_error "❌ Installation aborted by user."
    fi
fi

# ==================================================================================================
# Triggering Environment Setup
# ==================================================================================================
log_info "===> Triggering environment setup..."
source ./env.sh
