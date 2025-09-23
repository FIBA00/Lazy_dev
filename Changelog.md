# Lazy Dev Setup – Changelog

## \[Unreleased] – 2025-09-23

### Added

* **Multiplatform support**: The setup system now automatically detects the platform and executes the correct initialization script (`pc.sh` for Linux desktops and `termux.sh` for Termux on Android).
* **Repo-relative script execution**: Platform-specific scripts are now executed from a central `scripts/` directory within the repository, ensuring consistent behavior regardless of the current working directory.
* **Centralized logging**: All output is logged to `setup.log` in the repository root for easier debugging and audit purposes.
* **Internet connectivity check**: Automatic verification of network availability before proceeding with setup to prevent failures.

### Changed

* Main bootstrap script updated to detect platform and dynamically choose the corresponding script, replacing previous single-platform logic.
* Refactored platform detection logic for reliability across Linux and Android Termux environments.

### Fixed

* Improved robustness of script path resolution to correctly locate platform-specific scripts relative to the main repository.
