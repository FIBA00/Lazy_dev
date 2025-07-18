#!/bin/bash

# --- Git Remote Uploader Script - On-Demand PAT Handling ---
# This script configures a remote and pushes, prompting for PAT only if authentication fails.

echo "🚀 Git Remote Uploader - On-Demand PAT 🚀"
echo "This script will help you push your local repository to a GitHub remote."
echo "---------------------------------------------------------------"

# 1. Ask for GitHub Username
read -p "Enter your GitHub username: " GITHUB_USERNAME
if [[ -z "$GITHUB_USERNAME" ]]; then
    echo "Error: GitHub username cannot be empty. Exiting."
    exit 1
fi

# 2. Ask for the GitHub Repository Name
read -p "Enter the name of your GitHub repository (e.g., Road-life-driving-game-main.git or just Road-life-driving-game-main): " REPO_NAME
if [[ -z "$REPO_NAME" ]]; then
    echo "Error: Repository name cannot be empty. Exiting."
    exit 1
fi

# Ensure .git suffix if not present
if [[ "$REPO_NAME" != *.git ]]; then
    REPO_NAME="${REPO_NAME}.git"
fi

# Construct the full HTTPS remote URL
REMOTE_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "Constructed Remote URL: $REMOTE_URL"

# 3. Ask for the local branch name to push
read -p "Enter the name of your local branch to push (e.g., main or master): " LOCAL_BRANCH
if [[ -z "$LOCAL_BRANCH" ]]; then
    echo "Error: Local branch name cannot be empty. Exiting."
    exit 1
fi

echo ""
echo "Attempting to configure Git remote and push..."

# Check if 'origin' remote already exists
if git remote get-url origin &>/dev/null; then
    echo "Remote 'origin' already exists."
    read -p "Do you want to (r)emove and re-add or (s)kip adding? (r/s): " CHOICE
    if [[ "$CHOICE" == "r" || "$CHOICE" == "R" ]]; then
        echo "Removing existing remote 'origin'..."
        git remote remove origin
        echo "Adding new remote 'origin' with URL: $REMOTE_URL"
        git remote add origin "$REMOTE_URL"
    elif [[ "$CHOICE" == "s" || "$CHOICE" == "S" ]]; then
        echo "Skipping adding remote. Assuming existing 'origin' is correct."
    else
        echo "Invalid choice. Exiting to prevent unintended actions."
        exit 1
    fi
else
    echo "Adding remote 'origin' with URL: $REMOTE_URL"
    git remote add origin "$REMOTE_URL"
fi

# Verify the remote was added/updated
if git remote get-url origin &>/dev/null; then
    echo "Remote 'origin' successfully configured."
else
    echo "Error: Failed to configure remote 'origin'. Please check the URL and try again."
    exit 1
fi

echo "Attempting initial push..."
# Try pushing without explicit PAT for the first time
# If this succeeds (e.g., due to existing cached credentials or SSH), we're done.
git push -u origin "$LOCAL_BRANCH"

PUSH_STATUS=$? # Capture the exit status of the git push command

# Check if push failed and if it was an authentication issue (common non-zero exits for auth: 1, 128)
if [ "$PUSH_STATUS" -ne 0 ]; then
    echo "❌ Initial push failed. This might be due to an authentication issue."
    echo "   For HTTPS with GitHub, a Personal Access Token (PAT) is required."
    echo "   If you don't have one, create it at: https://github.com/settings/tokens (ensure 'repo' scope)."
    echo "---------------------------------------------------------------"

    read -sp "Enter your GitHub Personal Access Token (PAT): " GITHUB_PAT
    echo "" # Newline after secret input

    if [[ -z "$GITHUB_PAT" ]]; then
        echo "No PAT entered. Cannot proceed with authentication. Exiting."
        exit 1
    fi

    echo ""
    echo "How would you like to use this PAT for the push?"
    echo "1) Temporarily for this specific push (PAT embedded in URL for this command only)."
    echo "2) Configure Git to cache PAT for 15 minutes (local to this repo)."
    echo "3) Configure Git to store PAT permanently (NOT recommended for shared systems)."
    read -p "Enter your choice (1-3): " PAT_USE_CHOICE

    case "$PAT_USE_CHOICE" in
        1)
            # Temporarily embed PAT in the URL for this specific push command
            echo "Attempting push with PAT embedded in URL..."
            git push -u "https://$GITHUB_USERNAME:$GITHUB_PAT@github.com/$GITHUB_USERNAME/$REPO_NAME" "$LOCAL_BRANCH"
            ;;
        2)
            echo "Configuring Git to cache credentials for 15 minutes for this repository..."
            git config --local credential.helper "cache --timeout=900"
            echo "Attempting push with cached PAT. You might be prompted once more."
            git push -u origin "$LOCAL_BRANCH"
            ;;
        3)
            echo "⚠️  WARNING: Storing PAT permanently is generally NOT recommended for security reasons."
            read -p "Are you absolutely sure you want to store your PAT permanently (yes/no)?: " CONFIRM_STORE
            if [[ "$CONFIRM_STORE" == "yes" || "$CONFIRM_STORE" == "YES" ]]; then
                git config --global credential.helper store
                echo "https://$GITHUB_USERNAME:$GITHUB_PAT@github.com" > ~/.git-credentials
                echo "PAT stored permanently. Ensure ~/.git-credentials has restricted permissions (e.g., chmod 600)."
                echo "Attempting push..."
                git push -u origin "$LOCAL_BRANCH"
            else
                echo "Skipping permanent PAT storage. Please choose another option or push manually."
                exit 1
            fi
            ;;
        *)
            echo "Invalid choice. Cannot proceed with authentication. Exiting."
            exit 1
            ;;
    esac

    # Check push status after re-attempt
    if [ $? -eq 0 ]; then
        echo "✅ Successfully re-attempted push with PAT!"
    else
        echo "❌ Re-attempted push with PAT failed. Please verify your PAT, username, and repository details."
        echo "If using option 1, ensure the PAT is correct. If using options 2/3, Git may still prompt if there are issues."
        exit 1
    fi

else
    echo "✅ Initial push successful!"
fi

echo "---------------------------------------------------------------"
echo "Script finished."