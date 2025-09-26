# PowerShell Platform Detection Utility
# Detects OS details and provides helper functions for Windows environments.

# --- Core Detection Function ---
function Get-PlatformInfo {
    [CmdletBinding()]
    param()

    # Create a custom object to hold platform details
    $platformInfo = [PSCustomObject]@{
        IsWindows        = $false
        IsLinux          = $false
        IsMac            = $false
        ShellProfile     = ""
        PackageManager   = "Unknown"
        HomeDirectory    = ""
    }

    # --- OS Detection ---
    if ($IsWindows) {
        $platformInfo.IsWindows = $true
    }
    elseif ($IsLinux) {
        $platformInfo.IsLinux = $true
    }
    elseif ($IsMacOS) {
        $platformInfo.IsMac = $true
    }

    # --- Get Shell Profile ---
    # $PROFILE is a built-in variable pointing to the current host's profile
    if ($PROFILE) {
        $platformInfo.ShellProfile = $PROFILE
    }

    # --- Get Home Directory ---
    $platformInfo.HomeDirectory = $HOME

    # --- Package Manager Detection ---
    if ($platformInfo.IsWindows) {
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            $platformInfo.PackageManager = "Winget"
        }
        elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
            $platformInfo.PackageManager = "Chocolatey"
        }
        else {
            $platformInfo.PackageManager = "Manual"
        }
    }

    return $platformInfo
}

# --- Export functions for use in other scripts ---
Export-ModuleMember -Function Get-PlatformInfo

# You can run this script directly to see the output
if ($MyInvocation.MyCommand.Name -eq "PlatformDetect.ps1") {
    $info = Get-PlatformInfo
    Write-Host "--- Platform Information ---"
    $info | Format-List
}