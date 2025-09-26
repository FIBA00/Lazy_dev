# Simple Python Environment Activator
# This is the ONLY script you need to run to activate your environment

param(
    [switch]$Install,
    [switch]$Update,
    [switch]$Help
)

if ($Help) {
    Write-Host "Simple Python Environment Activator" -ForegroundColor Green
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

# Check for .envrc file to determine environment path
$envrcPath = ".envrc"
$venvPath = "venv"  # Default to local venv

if (Test-Path $envrcPath) {
    $envrcContent = Get-Content $envrcPath -Raw
    if ($envrcContent -match 'VENV_PATH="([^"]+)"') {
        $venvPath = $matches[1]
    }
}

# Check if venv exists
if (Test-Path $venvPath) {
    $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
    
    if (Test-Path $activateScript) {
        Write-Host "Found virtual environment at: $venvPath" -ForegroundColor Green
        
        # Activate the environment
        & $activateScript
        
        # Check if environment is active (VIRTUAL_ENV variable is set)
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
            Write-Host "Ready to code! Your environment is active." -ForegroundColor Cyan
            Write-Host "Type 'deactivate' to exit the environment" -ForegroundColor Yellow
            Write-Host "Type 'python --version' to check Python version" -ForegroundColor Yellow
            
        } else {
            Write-Host "Failed to activate environment" -ForegroundColor Red
        }
    } else {
        Write-Host "Activation script not found in venv\Scripts\" -ForegroundColor Red
    }
} else {
    Write-Host "Virtual environment not found!" -ForegroundColor Red
    Write-Host "Run: .\setup_windows_env.ps1 to create the environment" -ForegroundColor Yellow
}