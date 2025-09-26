#!/bin/bash

# Data Forge Dispatcher System Logger Script
# Centralized logging functionality for all shell scripts
# Provides consistent logging format, levels, and output destinations

# Configuration
DEFAULT_LOG_FILE="/tmp/dispatcher_system.log"
DEFAULT_LOG_LEVEL="INFO"
LOG_TIMESTAMP_FORMAT="%Y-%m-%d %H:%M:%S"

# Built-in configuration - no external files needed

# Log levels (numeric for comparison)
declare -A LOG_LEVELS=(
    ["DEBUG"]=0
    ["INFO"]=1
    ["WARNING"]=2
    ["ERROR"]=3
    ["CRITICAL"]=4
)

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
CURRENT_LOG_LEVEL=${LOG_LEVELS[$DEFAULT_LOG_LEVEL]}
CURRENT_LOG_FILE="$DEFAULT_LOG_FILE"
ENABLE_CONSOLE_OUTPUT=true
ENABLE_FILE_OUTPUT=true
ENABLE_SYSLOG_OUTPUT=false

# Function to set log level
set_log_level() {
    local level="$1"
    if [[ -n "${LOG_LEVELS[$level]}" ]]; then
        CURRENT_LOG_LEVEL=${LOG_LEVELS[$level]}
        log_info "Log level set to: $level"
    else
        echo "Invalid log level: $level. Valid levels: ${!LOG_LEVELS[@]}" >&2
        return 1
    fi
}

# Function to set log file
set_log_file() {
    local file="$1"
    if [[ -n "$file" ]]; then
        CURRENT_LOG_FILE="$file"
        # Ensure directory exists
        local dir=$(dirname "$file")
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" 2>/dev/null || {
                echo "Failed to create log directory: $dir" >&2
                return 1
            }
        fi
        log_info "Log file set to: $file"
    fi
}

# Function to enable/disable console output
set_console_output() {
    local enable="$1"
    if [[ "$enable" == "true" || "$enable" == "1" ]]; then
        ENABLE_CONSOLE_OUTPUT=true
        log_info "Console output enabled"
    else
        ENABLE_CONSOLE_OUTPUT=false
        log_info "Console output disabled"
    fi
}

# Function to enable/disable file output
set_file_output() {
    local enable="$1"
    if [[ "$enable" == "true" || "$enable" == "1" ]]; then
        ENABLE_FILE_OUTPUT=true
        log_info "File output enabled"
    else
        ENABLE_FILE_OUTPUT=false
        log_info "File output disabled"
    fi
}

# Function to enable/disable syslog output
set_syslog_output() {
    local enable="$1"
    if [[ "$enable" == "true" || "$enable" == "1" ]]; then
        ENABLE_SYSLOG_OUTPUT=true
        log_info "Syslog output enabled"
    else
        ENABLE_SYSLOG_OUTPUT=false
        log_info "Syslog output disabled"
    fi
}

# Function to get current timestamp
get_timestamp() {
    date +"$LOG_TIMESTAMP_FORMAT"
}

# Function to format log message
format_log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(get_timestamp)
    echo "[$timestamp] [$level] $message"
}

# Function to write to log file
write_to_file() {
    local message="$1"
    if [[ "$ENABLE_FILE_OUTPUT" == "true" && -n "$CURRENT_LOG_FILE" ]]; then
        echo "$message" >> "$CURRENT_LOG_FILE" 2>/dev/null || {
            echo "Failed to write to log file: $CURRENT_LOG_FILE" >&2
        }
    fi
}

# Function to write to syslog
write_to_syslog() {
    local level="$1"
    local message="$2"
    if [[ "$ENABLE_SYSLOG_OUTPUT" == "true" ]]; then
        if command -v logger &> /dev/null; then
            # Map log levels to syslog priorities
            local priority="info"
            case "$level" in
                "DEBUG") priority="debug" ;;
                "INFO") priority="info" ;;
                "WARNING") priority="warning" ;;
                "ERROR") priority="err" ;;
                "CRITICAL") priority="crit" ;;
            esac
            logger -p "user.$priority" "$message" 2>/dev/null || true
        fi
    fi
}

# Function to output to console with colors
write_to_console() {
    local level="$1"
    local message="$2"
    if [[ "$ENABLE_CONSOLE_OUTPUT" == "true" ]]; then
        local color="$NC"
        case "$level" in
            "DEBUG") color="$CYAN" ;;
            "INFO") color="$GREEN" ;;
            "WARNING") color="$YELLOW" ;;
            "ERROR") color="$RED" ;;
            "CRITICAL") color="$PURPLE" ;;
        esac
        echo -e "${color}$message${NC}"
    fi
}

# Core logging function
log_message() {
    local level="$1"
    local message="$2"
    
    # Check if we should log this level
    if [[ ${LOG_LEVELS[$level]} -ge $CURRENT_LOG_LEVEL ]]; then
        local formatted_message=$(format_log_message "$level" "$message")
        
        # Output to all enabled destinations
        write_to_console "$level" "$formatted_message"
        write_to_file "$formatted_message"
        write_to_syslog "$level" "$message"
    fi
}

# Convenience logging functions
log_debug() {
    log_message "DEBUG" "$1"
}

log_info() {
    log_message "INFO" "$1"
}

log_warning() {
    log_message "WARNING" "$1"
}

log_error() {
    log_message "ERROR" "$1"
}

log_critical() {
    log_message "CRITICAL" "$1"
}

# Function to log with context
log_with_context() {
    local level="$1"
    local context="$2"
    local message="$3"
    local full_message="[$context] $message"
    log_message "$level" "$full_message"
}

# Function to log job-related information
log_job() {
    local level="$1"
    local job_name="$2"
    local action="$3"
    local details="$4"
    local message="JOB[$job_name] $action: $details"
    log_message "$level" "$message"
}

# Function to log file operations
log_file_operation() {
    local level="$1"
    local operation="$2"
    local file_path="$3"
    local details="$4"
    local message="FILE[$operation] $file_path: $details"
    log_message "$level" "$message"
}

# Function to log system events
log_system_event() {
    local level="$1"
    local event_type="$2"
    local event_details="$3"
    local message="SYSTEM[$event_type] $event_details"
    log_message "$level" "$message"
}

# Function to log performance metrics
log_performance() {
    local level="$1"
    local operation="$2"
    local duration="$3"
    local details="$4"
    local message="PERF[$operation] Duration: $duration - $details"
    log_message "$level" "$message"
}

# Function to log errors with stack trace (if available)
log_error_with_trace() {
    local error_message="$1"
    local error_code="${2:-$?}"
    
    log_error "$error_message (Exit code: $error_code)"
    
    # Log stack trace if available (bash 4.0+)
    if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
        local frame=0
        while caller $frame; do
            ((frame++))
        done 2>/dev/null | while read -r line func file; do
            log_debug "  at $func ($file:$line)"
        done
    fi
}

# Function to rotate log file if it gets too large
rotate_log_if_needed() {
    local max_size_mb="${1:-100}"
    local max_size_bytes=$((max_size_mb * 1024 * 1024))
    
    if [[ -f "$CURRENT_LOG_FILE" ]]; then
        local current_size=$(stat -c%s "$CURRENT_LOG_FILE" 2>/dev/null || echo 0)
        if [[ $current_size -gt $max_size_bytes ]]; then
            local backup_file="${CURRENT_LOG_FILE}.$(date +%Y%m%d_%H%M%S)"
            mv "$CURRENT_LOG_FILE" "$backup_file" 2>/dev/null && {
                log_info "Log file rotated: $backup_file"
                # Compress old log file
                gzip "$backup_file" 2>/dev/null || true
            }
        fi
    fi
}

# Function to get log statistics
get_log_stats() {
    if [[ -f "$CURRENT_LOG_FILE" ]]; then
        local total_lines=$(wc -l < "$CURRENT_LOG_FILE" 2>/dev/null || echo 0)
        local file_size=$(du -h "$CURRENT_LOG_FILE" 2>/dev/null | cut -f1 || echo "0")
        
        echo "Log Statistics:"
        echo "  File: $CURRENT_LOG_FILE"
        echo "  Total lines: $total_lines"
        echo "  Size: $file_size"
        
        # Count by log level
        echo "  Breakdown by level:"
        for level in "${!LOG_LEVELS[@]}"; do
            local count=$(grep -c "\[$level\]" "$CURRENT_LOG_FILE" 2>/dev/null || echo 0)
            echo "    $level: $count"
        done
    else
        echo "Log file not found: $CURRENT_LOG_FILE"
    fi
}

# Function to clean old log files
cleanup_old_logs() {
    local days_to_keep="${1:-30}"
    local log_dir=$(dirname "$CURRENT_LOG_FILE")
    
    if [[ -d "$log_dir" ]]; then
        find "$log_dir" -name "*.log.*" -mtime +$days_to_keep -delete 2>/dev/null && {
            log_info "Cleaned up log files older than $days_to_keep days"
        }
    fi
}

# Function to initialize logger with configuration
# Note: This function is kept for backward compatibility but is no longer needed
# The logger now auto-configures itself when sourced
init_logger() {
    log_info "Logger auto-configured - no external config needed"
}

# Function to show logger help
show_logger_help() {
    echo "Data Forge Logger - Usage Examples:"
    echo ""
    echo "🚀 SIMPLE USAGE (Just copy logger.sh anywhere!):"
    echo "  source ./logger.sh"
    echo "  log_info 'Script started'"
    echo "  log_error 'Something went wrong'"
    echo ""
    echo "📝 Basic logging:"
    echo "  log_debug 'Debug info'"
    echo "  log_info 'Information'"
    echo "  log_warning 'Warning'"
    echo "  log_error 'Error'"
    echo "  log_critical 'Critical error'"
    echo ""
    echo "🔧 Contextual logging:"
    echo "  log_job 'INFO' 'JobName' 'action' 'details'"
    echo "  log_file_operation 'INFO' 'operation' '/path/file' 'details'"
    echo "  log_system_event 'INFO' 'Startup' 'Service initialized'"
    echo ""
    echo "⚙️  Optional configuration (not required):"
    echo "  set_log_level 'DEBUG'"
    echo "  set_log_file '/var/log/myapp.log'"
    echo "  set_console_output false"
    echo ""
    echo "🛠️  Utilities:"
    echo "  rotate_log_if_needed 100"
    echo "  get_log_stats"
    echo "  cleanup_old_logs 30"
}

# Auto-initialization when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is being sourced, initialize with defaults
    log_info "Logger script sourced and initialized"
fi

# Export functions for use in other scripts
export -f log_debug log_info log_warning log_error log_critical
export -f log_with_context log_job log_file_operation log_system_event log_performance
export -f log_error_with_trace set_log_level set_log_file
export -f set_console_output set_file_output set_syslog_output
export -f rotate_log_if_needed get_log_stats cleanup_old_logs init_logger

# Auto-detect and set sensible defaults based on environment
# This makes the logger work anywhere without configuration files

# Set log file to a sensible location based on script name
if [[ -z "${CURRENT_LOG_FILE:-}" || "$CURRENT_LOG_FILE" == "$DEFAULT_LOG_FILE" ]]; then
    # Try to use script name for log file
    script_name=$(basename "${BASH_SOURCE[1]:-unknown_script}" .sh)
    if [[ "$script_name" != "unknown_script" ]]; then
        # Create logs directory if it doesn't exist
        LOG_DIR="Logs"
        mkdir -p "$LOG_DIR" 2>/dev/null || true
        set_log_file "$LOG_DIR/${script_name}.log"
    else
        LOG_DIR="Logs"
        mkdir -p "$LOG_DIR" 2>/dev/null || true
        set_log_file "$LOG_DIR/script.log"
    fi
fi

# Enable all outputs by default for maximum visibility
set_console_output true
set_file_output true
set_syslog_output false  # Disabled by default to avoid permission issues
