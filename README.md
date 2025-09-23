# Lazy  Setup me Script
- One line command if you dont want to read the entire README.
```bash
git clone https://github.com/FIBA00/Lazy_dev.git && cd Lazy_dev && chmod +x setup.sh && ./setup.sh
```

      


## Overview

 This script automates the setup of a development environment by installing necessary packages, setting up Git, Python, virtual environments, SSH keys, and configuring your shell with useful aliases and functions.

---

## Features

- **System Update**: Updates the system with the latest packages.
- **Git Setup**: Installs and configures Git.
- **Python Setup**: Installs Python, pip, and optionally sets up a virtual environment.
- **Development Tools**: Installs tools like `curl`, `wget`, `jq`, `htop`.
- **Python Setup**: Installs Python, pip, and optionally sets up a Python virtual environment for your projects.
- **Essential Development Tools**: Installs common tools like `curl`, `wget`, `jq`, `htop`.
- **SSH Key Setup**: Automatically generates SSH keys and adds them for GitHub integration.
- **Shell Customization**: Adds useful aliases and custom functions to your shell configuration for an enhanced terminal experience.

---

## Prerequisites

Before running the script, ensure the following:

- You are using a Linux-based OS (Ubuntu or similar).
- You have a stable internet connection.
- You should **not** run the script as root; it must be run as a normal user, there are commands already have sudo attached so dont add another sudo on top.
  
---

## Getting Started

Follow these steps to set up the development environment:

1. **Download the repository as zip**:

   - Extract the repository.
   - Replace the empty requirements.txt file with your own requirements file if you have one.
   - or Move the scripts to your project directory.
   - Make the script executable:
    
    ```chmod +x setup.sh```

2. **Run the script:**

    Execute the script using:
    
    ```./setup.sh```

Follow the on-screen prompts for the setup. The script will guide you through the entire process and ask you for necessary inputs when needed.


## What the Script Does
### 1. System Update
The script starts by updating your system's package list. This ensures that you are installing the latest versions of available software packages.
The sudo apt-get update -y command is used to fetch the latest package information.


### 2. Git Setup
The script installs Git and configures it with your user information (name and email).
It sets default behaviors like choosing your preferred text editor and enabling colorized output for Git commands.

### 3. Python & Virtual Environment Setup
The script installs Python 3, pip (Python’s package manager), and the venv module (for creating isolated Python environments).
You are prompted to choose whether to create a virtual environment for your projects. A virtual environment helps keep dependencies isolated per project.

### 4. Installing Required Python Packages
If you opt to use a virtual environment, the script will attempt to install the Python packages specified in a requirements.txt file.
If the file is missing, it will download it from a GitHub URL or allow you to provide one manually.


### 5. Essential Development Tools
The script installs some commonly used development tools, such as:
 - curl: Used for transferring data from or to a server.
 - wget: Command-line utility to download files from the web.
 - jq: A tool for working with JSON data.
 - htop: A more interactive process viewer than the standard top command.

### 6. SSH Key Setup
The script generates SSH keys on your machine and sets them up for GitHub access.
It adds the public key to the GitHub SSH keys section, allowing you to clone repositories and push code securely without needing to enter your password repeatedly.

#### 7. Shell Customization
The script adds helpful aliases and functions to your shell configuration file (.bashrc, .zshrc, etc.).

    - For example, alias ll='ls -lah --color=auto' provides a colored output for ls, making it easier to read directory contents.
Other aliases include common Git commands like gs for git status and gc for git commit -m.


## Configuration Options
1. **Virtual Environment**: You will be prompted to choose whether to create a new virtual environment. If you choose to skip it, the script will install Python packages globally.
Global Package Installation: If you choose to skip the virtual environment setup, the script will ask if you want to install packages globally with the --break-system-packages flag.

2. **Customizing the Script**
The script is flexible and can be modified to suit your needs:

    - Git Configuration: You can change the Git username, email, or editor by editing the git config lines in the script.
    - Development Tools: Add or remove any tools you wish to install in the "Essential Development Tools" section.
    - Aliases and Functions: Modify or add more aliases and functions by editing the relevant section of the script.

3. **Troubleshooting**

    - **Issues with Package Installation**
    
        If a command fails, the script will print an error message, and you can debug it using the output log file (new_install_setup.log).
        Make sure you have an active internet connection. The script fetches external resources from GitHub.
    - **SSH Key Setup Issues**
        If the SSH setup fails, manually add the generated public key (~/.ssh/id_rsa.pub) to your GitHub account under "SSH and GPG keys" settings.

        You can test your SSH connection with:

        ```ssh -T git@github.com ```
