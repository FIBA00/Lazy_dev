#!/bin/bash
source ../../logger.sh

set -euo pipefail
IFS=$'\n\t'

# === CONFIG ===
BASE_DIR="$HOME/Code"
ENV_DIR=".SMART_ENV"
ENV_PATH="$BASE_DIR/$ENV_DIR"
SHELL_CONFIG="$HOME/.bashrc"  # Adjust if needed
COMMON_PACKAGES=(requests psutil dotenv speedtest)  # <--- array here

echo "===> Ensuring base directory exists at $BASE_DIR..."
mkdir -p "$BASE_DIR"

# === Check direnv ===
if ! command -v direnv &> /dev/null; then
    echo "===> direnv not found, installing..."
    sudo apt update && sudo apt install -y direnv
else
    echo "===> direnv is already installed."
fi

# === Add direnv hook to shell config ===
if ! grep -q 'direnv hook' "$SHELL_CONFIG"; then
    echo "===> Adding direnv hook to $SHELL_CONFIG"
    {
        echo -e "\n# direnv hook"
        echo 'eval "$(direnv hook bash)"'
    } >> "$SHELL_CONFIG"
else
    echo "===> direnv hook already present in $SHELL_CONFIG"
fi

# === Create Virtual Environment ===
if [ ! -d "$ENV_PATH" ]; then
    echo "===> Creating shared virtual environment at $ENV_PATH"
    python3 -m venv "$ENV_PATH"
else
    echo "===> Virtual environment already exists at $ENV_PATH"
fi

# === Install common packages ===
echo "===> Activating virtual environment and installing packages: ${COMMON_PACKAGES[*]}"
# shellcheck source=/dev/null
source "$ENV_PATH/bin/activate"
pip install --upgrade pip
pip install "${COMMON_PACKAGES[@]}"  # <---- array expansion here
deactivate

# === Setup .envrc for direnv ===
ENVRC_FILE="$BASE_DIR/.envrc"
echo "===> Writing source activation to $ENVRC_FILE"
echo "source $ENV_PATH/bin/activate" > "$ENVRC_FILE"

# === Allow direnv in base directory ===
cd "$BASE_DIR"
echo "===> Running 'direnv allow' in $BASE_DIR"
direnv allow

# === Final message ===
echo -e "\nALL DONE, DUDE!"
echo "Restart your terminal or run: source $SHELL_CONFIG"
echo "Now, every time you enter any subdirectory of $BASE_DIR, the shared virtual environment will auto-activate."

