# Project Refactor TODO

This file tracks the progress of restructuring the project for cross-platform support.

## Phase 1: Directory Restructuring for Linux

- [x] Create top-level directories: `linux` and `windows`.
- [x] Create subdirectories within `linux`: `linux/utils` and `linux/tools`.
- [x] Move existing Bash scripts to the new `linux` subdirectories.
- [x] Remove the now-empty `scripts` and `Setup` directories.
- [x] Update paths within the moved scripts to reflect the new directory structure.
- [x] Update the root `setup.sh` to call the scripts from their new `linux/tools` location.

## Phase 2: Scaffolding for Windows

- [x] Create subdirectories within `windows`: `utils` and `tools`.
- [x] Create placeholder PowerShell scripts in the `windows` directory.
- [x] Create the main `setup.ps1` entry point in the project root.

## Phase 3: PowerShell Script Implementation

- [x] **Implement `windows/utils/Logger.ps1`**
- [x] **Implement `windows/utils/PlatformDetect.ps1`**
- [x] **Implement Windows Setup Logic in `windows/tools/Setup-WindowsEnv.ps1`**
- [x] **Implement Auto-Activation Hook in `windows/tools/Setup-PowerShellProfile.ps1`**
- [x] **Finalize and Document**
    - [x] Update the main `setup.ps1` to properly call the new tools.
    - [x] Clean up and remove the `temp_win` directory.
    - [ ] Update the main `README.md` with clear, separate instructions for running `setup.sh` on Linux/macOS and `setup.ps1` on Windows.

## Phase 4: Testing and Validation

- [ ] **Linux Environment Test Plan:**
    - [ ] Run `setup.sh` on a clean Linux environment.
    - [ ] Verify that the shared virtual environment is created in `$HOME/Code/.SMART_ENV`.
    - [ ] Verify that `direnv` is installed and the hook is added to `.bashrc`.
    - [ ] Verify that the `.envrc` file is created in `$HOME/Code`.
    - [ ] Test auto-activation by `cd`-ing into a subdirectory of `$HOME/Code`.
    - [ ] Confirm the virtual environment is active (`which python`).

- [ ] **Windows Environment Test Plan:**
    - [ ] Run `setup.ps1` on a clean Windows environment.
    - [ ] Verify that the shared virtual environment is created in `Documents\Code\.SMART_ENV`.
    - [ ] Verify that the `.envrc` file is created.
    - [ ] Run the `windows/tools/Setup-PowerShellProfile.ps1` script as prompted.
    - [ ] Restart PowerShell and verify the auto-activation hook works by `cd`-ing into a subdirectory of `Documents\Code`.
    - [ ] Confirm the virtual environment is active (`Get-Command python`).

- [ ] **Final Code Cleanup:**
    - [ ] Remove the `resource` directory.
    - [ ] Review and remove any other temporary or unnecessary files.