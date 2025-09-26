# Simple Python Environment Activator - Windows Version
# This script can be used for manual activation of the shared environment.

param(
    [switch]$Install,
    [switch]$Update,
    [switch]$Help
)

if ($Help) {
    Write-Host "Simple Python Environment Activator (Windows)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\Activate.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -Install    Install requirements from a local requirements.txt" -ForegroundColor White
    Write-Host "  -Update     Update all packages in the shared environment" -ForegroundColor White
    Write-Host "  -Help       Show this help" -ForegroundColor White
    return
}

Write-Host "Activating Python Environment..." -ForegroundColor Green

# Define the path to the shared environment
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
        
    } else {
        Write-Host "Failed to activate environment" -ForegroundColor Red
    }
} else {
    Write-Host "Virtual environment not found at: $venvPath" -ForegroundColor Red
    Write-Host "Run 'setup.ps1' to create the environment" -ForegroundColor Yellow
}
