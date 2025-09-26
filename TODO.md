# Project Refactor TODO

This file tracks the progress of restructuring the project for cross-platform support.

## Phase 1: Directory Restructuring for Linux

- [x] Create top-level directories: `linux` and `windows`.
- [x] Create subdirectories within `linux`: `linux/utils` and `linux/tools`.
- [x] Move existing Bash scripts to the new `linux` subdirectories:
    - [x] Move `logger.sh` to `linux/utils/logger.sh`.
    - [x] Move `platform_detect.sh` to `linux/utils/platform_detect.sh`.
    - [x] Move `scripts/pc.sh` to `linux/tools/pc.sh`.
    - [x] Move `scripts/termux.sh` to `linux/tools/termux.sh`.
    - [x] Move `scripts/env.sh` to `linux/tools/env.sh`.
    - [x] Move `Setup/setup_linux_env.sh` to `linux/tools/setup_linux_env.sh`.
- [x] Remove the now-empty `scripts` and `Setup` directories.
- [x] Update paths within the moved scripts to reflect the new directory structure (e.g., `source ../utils/logger.sh`).
- [x] Update the root `setup.sh` to call the scripts from their new `linux/tools` location.

## Phase 2: Scaffolding for Windows

- [x] Create subdirectories within `windows`: `windows/utils` and `windows/tools`.
- [x] Create placeholder PowerShell scripts in the `windows` directory:
    - [x] Create `windows/utils/Logger.ps1`.
    - [x] Create `windows/utils/PlatformDetect.ps1`.
    - [x] Create `windows/tools/Setup-WindowsEnv.ps1`.
- [x] Create the main `setup.ps1` entry point in the project root.

## Phase 3: PowerShell Script Implementation

- [x] **Implement `windows/utils/Logger.ps1`**
    - [x] Create a core `Write-Log` function that handles different log levels (INFO, WARN, ERROR).
    - [x] Implement colored console output using `Write-Host`.
    - [x] Implement log-to-file functionality, writing to a file in the `output/` directory.
    - [x] Add convenience functions (`Write-Info`, `Write-Error`, etc.) that call the core function.

- [x] **Implement `windows/utils/PlatformDetect.ps1`**
    - [x] Create a function `Get-PlatformInfo` that returns an object with platform details.
    - [x] Use the built-in `$IsWindows` variable for OS detection.
    - [x] Add logic to find the correct PowerShell profile path (`$PROFILE`).
    - [x] Add logic to detect common package managers like `Winget` and `Chocolatey`.

- [x] **Implement Windows Setup Logic**
    - [x] Adapt the core logic from `temp_win/setup_windows_env.ps1` into `windows/tools/Setup-WindowsEnv.ps1`.
    - [x] The script should create a shared virtual environment in a standard Windows location (e.g., `$HOME\Documents\Code\.SMART_ENV`).
    - [x] It should install common Python packages into the new environment.
    - [x] It should create a simple `.envrc` file in the base directory (`$HOME\Documents\Code`) to store the venv path, similar to `win.envrc.fixed`.

- [x] **Implement Auto-Activation Hook**
    - [x] Create a new, static script: `windows/tools/Setup-PowerShellProfile.ps1`.
    - [x] This script will contain the logic to append the auto-activation function to the user's PowerShell profile, mimicking `direnv` functionality as described in the `README_WINDOWS_FIX.md`.
    - [x] The `Setup-WindowsEnv.ps1` script will instruct the user to run this script as a final, one-time step.

- [x] **Finalize and Document**
    - [x] Update the main `setup.ps1` to properly dot-source the new utilities and call the `Setup-WindowsEnv.ps1` tool.
    - [x] Clean up and remove the `temp_win` directory.
    - [x] Update the main `README.md` with clear, separate instructions for running `setup.sh` on Linux/macOS and `setup.ps1` on Windows.
