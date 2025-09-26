# PowerShell Profile Setup for Auto-Activation
# This script sets up automatic virtual environment activation (Windows equivalent of direnv)

# Source the logger utility
. "$PSScriptRoot\..\utils\Logger.ps1"

Write-Info "Setting up PowerShell profile for auto-activation..."

# Get PowerShell profile path
$profilePath = $PROFILE.CurrentUserCurrentHost

# Create profile directory if it doesn't exist
$profileDir = Split-Path $profilePath -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Check if auto-activation code is already in profile
$profileContent = ""
if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw
}

# Auto-activation code
$autoActivationCode = @"

# === Auto Python Environment Activation (Windows direnv equivalent) ===
# This code automatically activates the shared Python environment when entering Documents/Code

function Test-InCodeDirectory {
    `$currentPath = Get-Location
    `$codePath = "C:\Users\$env:USERNAME\Documents\Code"
    return `$currentPath.Path.StartsWith(`$codePath)
}

function Activate-IfNeeded {
    if (Test-InCodeDirectory) {
        if (-not `$env:VIRTUAL_ENV) {
            `$envrcPath = "C:\Users\$env:USERNAME\Documents\Code\.envrc"
            if (Test-Path `$envrcPath) {
                `$envrcContent = Get-Content `$envrcPath -Raw
                if (`$envrcContent -match 'VENV_PATH="([^"]+)"' ) {
                    `$venvPath = `$matches[1]
                    `$activateScript = Join-Path `$venvPath "Scripts\Activate.ps1"
                    if (Test-Path `$activateScript) {
                        & `$activateScript
                        Write-Host "🐍 Auto-activated Python environment" -ForegroundColor Green
                    }
                }
            }
        }
    } else {
        if (`$env:VIRTUAL_ENV) {
            deactivate
            Write-Host "🐍 Auto-deactivated Python environment" -ForegroundColor Yellow
        }
    }
}

# Hook into directory changes
function prompt {
    Activate-IfNeeded
    return "PS $($executionContext.SessionState.Path.CurrentLocation)> "
}

"@

# Add auto-activation code to profile if not already present
if ($profileContent -notmatch "Auto Python Environment Activation") {
    Write-Info "Adding auto-activation code to PowerShell profile..."
    Add-Content -Path $profilePath -Value $autoActivationCode -Encoding UTF8
    Write-Info "PowerShell profile updated successfully!"
} else {
    Write-Info "Auto-activation code already present in PowerShell profile"
}

Write-Info "`n=== Setup Complete! ==="
Write-Warning "Restart PowerShell or run: . `$PROFILE"
Write-Info "Now the environment will auto-activate when you enter Documents/Code subdirectories!"
