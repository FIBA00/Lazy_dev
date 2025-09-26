# Main PowerShell Setup Script for Windows
# This script is the primary entry point for Windows users.

# --- Set up environment and import utilities ---
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
. "$PSScriptRoot\windows\utils\Logger.ps1"
. "$PSScriptRoot\windows\utils\PlatformDetect.ps1"

# --- Main Logic ---
Write-Info "Starting Windows setup..."

# Get platform info
$platform = Get-PlatformInfo
if (-not $platform.IsWindows) {
    Write-Error "This script is intended for Windows only."
    exit 1
}

Write-Info "Windows platform detected."
Write-Info "PowerShell Profile: $($platform.ShellProfile)"
Write-Info "Package Manager: $($platform.PackageManager)"


# --- Run Setup Tools ---
$setupScriptPath = "$PSScriptRoot\windows\tools\Setup-WindowsEnv.ps1"
if (Test-Path $setupScriptPath) {
    Write-Info "Executing the main environment setup script..."
    # Execute the script with its own parameters
    & $setupScriptPath
} else {
    Write-Error "Main setup script not found at: $setupScriptPath"
    exit 1
}

Write-Info "Windows setup process complete."
Write-Warning "Please see the final instructions from the setup script to complete your environment configuration."