# Windows Environment Setup Script - FIXED VERSION
# This script mirrors the Linux setup_linux_env.sh functionality
# Creates a shared virtual environment for all projects under Documents/Code

# Source the logger utility
. "$PSScriptRoot\..\utils\Logger.ps1"

param(
    [string]$BaseDir = "C:\Users\$env:USERNAME\Documents\Code",
    [string]$PythonVersion = "python",
    [switch]$Force
)

Write-Info "=== Windows Python Environment Setup (Fixed Version) ==="
Write-Info "This script creates a shared environment similar to Linux direnv setup"

# === CONFIG ===
$ENV_DIR = ".SMART_ENV"
$ENV_PATH = Join-Path $BaseDir $ENV_DIR
$COMMON_PACKAGES = @("requests", "psutil", "python-dotenv", "speedtest-cli")

Write-Info "`n=== Configuration ==="
Write-Info "Base Directory: $BaseDir"
Write-Info "Environment Path: $ENV_PATH"
Write-Info "Common Packages: $($COMMON_PACKAGES -join ', ')"

# === Ensure base directory exists ===
Write-Info "`n===> Ensuring base directory exists at $BaseDir..."
if (-not (Test-Path $BaseDir)) {
    New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null
    Write-Info "Created base directory: $BaseDir"
} else {
    Write-Info "Base directory already exists: $BaseDir"
}

# === Check Python ===
Write-Info "`n===> Checking Python installation..."
try {
    $pythonVersionOutput = & $PythonVersion --version 2>&1
    Write-Info "Found Python: $pythonVersionOutput"
} catch {
    Write-Error "Error: Python not found. Please install Python and add it to PATH."
    Write-Warning "Download from: https://www.python.org/downloads/"
    exit 1
}

# === Create Virtual Environment ===
if (-not (Test-Path $ENV_PATH) -or $Force) {
    if ($Force -and (Test-Path $ENV_PATH)) {
        Write-Warning "`n===> Force flag detected, removing existing environment..."
        Remove-Item -Path $ENV_PATH -Recurse -Force
    }
    
    Write-Info "`n===> Creating shared virtual environment at $ENV_PATH"
    & $PythonVersion -m venv $ENV_PATH
    
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Virtual environment created successfully!"
    } else {
        Write-Error "Failed to create virtual environment."
        exit 1
    }
} else {
    Write-Info "`n===> Virtual environment already exists at $ENV_PATH"
}

# === Install common packages ===
Write-Info "`n===> Installing common packages: $($COMMON_PACKAGES -join ', ')"
$activateScript = Join-Path $ENV_PATH "Scripts\Activate.ps1"

if (Test-Path $activateScript) {
    # Activate environment
    & $activateScript
    
    # Upgrade pip
    Write-Info "Upgrading pip..."
    python -m pip install --upgrade pip --quiet
    
    # Install common packages
    Write-Info "Installing common packages..."
    foreach ($package in $COMMON_PACKAGES) {
        Write-Debug "  Installing $package..."
        pip install $package --quiet
    }
    
    Write-Info "Common packages installed successfully!"
    
    # Deactivate environment
    deactivate
} else {
    Write-Error "Error: Could not find activation script at $activateScript"
    exit 1
}

# === Setup .envrc for PowerShell profile ===
$ENVRC_FILE = Join-Path $BaseDir ".envrc"
Write-Info "`n===> Writing simple .envrc to $ENVRC_FILE"

$envrcContent = @"
# Windows .envrc equivalent - Simple version like Linux
# This file is used by PowerShell profile for auto-activation

# Virtual environment path (shared environment)
VENV_PATH="$ENV_PATH"

# Base directory
BASE_DIR="$BaseDir"

# Python executable in venv
PYTHON_EXECUTABLE="$ENV_PATH\Scripts\python.exe"

# Environment type
ENVIRONMENT_TYPE="SHARED"
"@

$envrcContent | Out-File -FilePath $ENVRC_FILE -Encoding UTF8 -Force
Write-Info "Created .envrc file: $ENVRC_FILE"

# === Create PowerShell profile setup script ===
$profileSetupScript = Join-Path $BaseDir "setup_powershell_profile.ps1"
Write-Info "`n===> Creating PowerShell profile setup script..."

$profileSetupContent = @'
# PowerShell Profile Setup for Auto-Activation
# This script sets up automatic virtual environment activation (Windows equivalent of direnv)

Write-Host "Setting up PowerShell profile for auto-activation..." -ForegroundColor Green

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
    `$codePath = "C:\Users\`$env:USERNAME\Documents\Code"
    return `$currentPath.Path.StartsWith(`$codePath)
}

function Activate-IfNeeded {
    if (Test-InCodeDirectory) {
        if (-not `$env:VIRTUAL_ENV) {
            `$envrcPath = "C:\Users\`$env:USERNAME\Documents\Code\.envrc"
            if (Test-Path `$envrcPath) {
                `$envrcContent = Get-Content `$envrcPath -Raw
                if (`$envrcContent -match 'VENV_PATH="([^\"]+)"' ) {
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
    return "PS `$(`$executionContext.SessionState.Path.CurrentLocation)> "
}

"@

# Add auto-activation code to profile if not already present
if ($profileContent -notmatch "Auto Python Environment Activation") {
    Write-Host "Adding auto-activation code to PowerShell profile..." -ForegroundColor Yellow
    Add-Content -Path $profilePath -Value $autoActivationCode -Encoding UTF8
    Write-Host "PowerShell profile updated successfully!" -ForegroundColor Green
} else {
    Write-Host "Auto-activation code already present in PowerShell profile" -ForegroundColor Green
}

Write-Host "`n=== Setup Complete! ===" -ForegroundColor Green
Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Yellow
Write-Host "Now the environment will auto-activate when you enter Documents/Code subdirectories!" -ForegroundColor Cyan
'@

$profileSetupContent | Out-File -FilePath $profileSetupScript -Encoding UTF8 -Force
Write-Info "Created PowerShell profile setup script: $profileSetupScript"

# === Create simple activation script ===
$activateScriptPath = Join-Path $BaseDir "activate.ps1"
Write-Info "`n===> Creating simple activation script..."

$activateContent = @'
# Simple Python Environment Activator - Windows Version
# This is the ONLY script you need to run to activate your environment

param(
    [switch]$Install,
    [switch]$Update,
    [switch]$Help
)

if ($Help) {
    Write-Host "Simple Python Environment Activator (Windows)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\activate.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -Install    Install requirements from requirements.txt" -ForegroundColor White
    Write-Host "  -Update     Update all packages" -ForegroundColor White
    Write-Host "  -Help       Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\activate.ps1                    # Just activate" -ForegroundColor White
    Write-Host "  .\activate.ps1 -Install           # Activate + install packages" -ForegroundColor White
    return
}

Write-Host "Activating Python Environment..." -ForegroundColor Green

# Use the shared environment
$venvPath = "C:\Users\$env:USERNAME\Documents\Code\.SMART_ENV"
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"

if (Test-Path $activateScript) {
    Write-Host "Found shared virtual environment at: $venvPath" -ForegroundColor Green
    
    # Activate the environment
    & $activateScript
    
    # Check if environment is active
    if ($env:VIRTUAL_ENV) {
        Write-Host "Environment activated successfully!" -ForegroundColor Green
        
        # Install requirements if requested
        if ($Install -and (Test-Path "requirements.txt")) {
            Write-Host "Installing requirements..." -ForegroundColor Yellow
            pip install -r requirements.txt
            Write-Host "Requirements installed!" -ForegroundColor Green
        }
        
        # Update packages if requested
        if ($Update) {
            Write-Host "Updating packages..." -ForegroundColor Yellow
            pip list --outdated --format=freeze | ForEach-Object { $_.split('==')[0] } | ForEach-Object { pip install --upgrade $_ }
            Write-Host "Packages updated!" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Ready to code! Your shared environment is active." -ForegroundColor Cyan
        Write-Host "Type 'deactivate' to exit the environment" -ForegroundColor Yellow
        Write-Host "Type 'python --version' to check Python version" -ForegroundColor Yellow
        
    } else {
        Write-Host "Failed to activate environment" -ForegroundColor Red
    }
} else {
    Write-Host "Virtual environment not found at: $venvPath" -ForegroundColor Red
    Write-Host "Run: .\setup_windows_env.ps1 to create the environment" -ForegroundColor Yellow
}
'@

$activateContent | Out-File -FilePath $activateScriptPath -Encoding UTF8 -Force
Write-Info "Created simple activation script: $activateScriptPath"

# === Final message ===
Write-Info "`n=== ALL DONE! ==="
Write-Info "`n🔗 SHARED Environment Setup Complete:"
Write-Info "   Base Directory: $BaseDir"
Write-Info "   Virtual Environment: $ENV_PATH"
Write-Info "   .envrc File: $ENVRC_FILE"
Write-Info "   Activation Script: $activateScriptPath"

Write-Warning "`n📋 Next Steps:"
Write-Warning "1. Run: .\setup_powershell_profile.ps1"
Write-Warning "2. Restart PowerShell"
Write-Warning "3. Navigate to any subdirectory of $BaseDir"
Write-Warning "4. Environment will auto-activate (like Linux direnv)!"

Write-Info "`n🎯 Manual activation: .\activate.ps1"
Write-Info "🎯 Test: cd $BaseDir\test_project; python --version"