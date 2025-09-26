# PowerShell Logger Utility
# Provides centralized, leveled, and colored logging for PowerShell scripts.

# --- Configuration ---
# Ensure the output directory exists
$LogDirectory = Join-Path $PSScriptRoot "..\..\output"
if (-not (Test-Path $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory | Out-Null
}

$scriptName = $MyInvocation.MyCommand.Name -replace '\.ps1$'
$DefaultLogFile = Join-Path $LogDirectory "${scriptName}.log"
$Global:LogFile = $DefaultLogFile
$Global:LogLevel = "INFO" # Default log level

# --- Log Levels ---
$LogLevels = @{
    "DEBUG" = 0
    "INFO"  = 1
    "WARN"  = 2
    "ERROR" = 3
}

# --- Core Logging Function ---
function Write-Log {
    param(
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$Level = "INFO",
        [string]$Message
    )

    # Check if the message should be logged based on the current log level
    if ($LogLevels[$Level] -ge $LogLevels[$Global:LogLevel]) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $formattedMessage = "[$timestamp] [$Level] $Message"

        # --- Console Output ---
        $color = switch ($Level) {
            "DEBUG"   { "Cyan" }
            "INFO"    { "Green" }
            "WARN"    { "Yellow" }
            "ERROR"   { "Red" }
            default   { "White" }
        }
        Write-Host $formattedMessage -ForegroundColor $color

        # --- File Output ---
        if ($Global:LogFile) {
            try {
                Add-Content -Path $Global:LogFile -Value $formattedMessage
            }
            catch {
                Write-Host "[$timestamp] [ERROR] Failed to write to log file: $($Global:LogFile)" -ForegroundColor Red
            }
        }
    }
}

# --- Convenience Functions ---
function Write-Debug   { param([string]$Message) Write-Log -Level "DEBUG" -Message $Message }
function Write-Info    { param([string]$Message) Write-Log -Level "INFO"  -Message $Message }
function Write-Warning { param([string]$Message) Write-Log -Level "WARN"  -Message $Message }
function Write-Error   { param([string]$Message) Write-Log -Level "ERROR" -Message $Message }

# --- Configuration Functions ---
function Set-LogLevel {
    param(
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$Level
    )
    $Global:LogLevel = $Level
    Write-Info "Log level set to: $Level"
}

function Set-LogFile {
    param([string]$Path)
    $Global:LogFile = $Path
    # Ensure directory exists
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Write-Info "Log file set to: $Path"
}

# --- Export functions for use in other scripts ---
Export-ModuleMember -Function Write-Log, Write-Debug, Write-Info, Write-Warning, Write-Error, Set-LogLevel, Set-LogFile

Write-Info "Logger initialized."