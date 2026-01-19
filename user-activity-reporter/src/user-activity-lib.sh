#!/bin/bash
# user-activity-lib.sh - Shared library for user-activity-reporter
# Part of user-activity-reporter package

# Get all users on system
get_all_users() {
    local users=()
    while IFS=: read -r username _ uid _ _ home _; do
        # Only include regular users (UID >= 1000) with home directories
        if [ "$uid" -ge 1000 ] 2>/dev/null && [ -d "$home" ]; then
            users+=("$username")
        fi
    done < /etc/passwd
    echo "${users[@]}"
}

# Get last login time for user
get_last_login() {
    local username="$1"
    local last_login=$(last -n 1 "$username" 2>/dev/null | head -n 1 | awk '{print $3, $4, $5, $6}')
    
    if [ -n "$last_login" ] && [ "$last_login" != "wtmp" ]; then
        echo "$last_login"
    else
        echo "Never"
    fi
}

# Calculate online duration for currently logged in user
get_online_duration() {
    local username="$1"
    local current_time=$(date +%s)
    
    # Check if user is currently logged in
    if ! who | grep -q "^$username "; then
        echo "0|N/A"
        return
    fi
    
    # Get login time
    local login_time=$(who | grep "^$username " | awk '{print $3, $4, $5}')
    local login_timestamp=$(date -d "$login_time" +%s 2>/dev/null || echo "0")
    
    if [ "$login_timestamp" -eq 0 ]; then
        echo "0|N/A"
        return
    fi
    
    local duration_seconds=$((current_time - login_timestamp))
    local duration_formatted=$(format_duration "$duration_seconds")
    
    echo "$duration_seconds|$duration_formatted"
}

# Count active processes for user
count_processes() {
    local username="$1"
    local process_count=$(ps -u "$username" 2>/dev/null | wc -l)
    echo $((process_count - 1))  # Subtract header
}

# Get current logged-in users
get_logged_in_users() {
    local users=()
    while read -r user _; do
        users+=("$user")
    done < <(who | awk '{print $1}' | sort -u)
    echo "${users[@]}"
}

# Format duration in human-readable format
format_duration() {
    local seconds="$1"
    
    if [ "$seconds" -le 0 ]; then
        echo "0s"
        return
    fi
    
    local days=$((seconds / 86400))
    local hours=$(((seconds % 86400) / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    local result=""
    
    if [ "$days" -gt 0 ]; then
        result="${days}d "
    fi
    
    if [ "$hours" -gt 0 ]; then
        result="${result}${hours}h "
    fi
    
    if [ "$minutes" -gt 0 ]; then
        result="${result}${minutes}m "
    fi
    
    if [ "$secs" -gt 0 ] || [ -z "$result" ]; then
        result="${result}${secs}s"
    fi
    
    echo "$result" | sed 's/ $//'
}

# Format timestamp
format_timestamp() {
    local timestamp="$1"
    local format="${2:-%Y-%m-%d %H:%M:%S}"
    
    if [ -z "$timestamp" ] || [ "$timestamp" = "Never" ]; then
        echo "Never"
        return
    fi
    
    date -d "$timestamp" +"$format" 2>/dev/null || echo "$timestamp"
}

# Sort user data by field
sort_users() {
    local data=("$@")
    local field="${1:-user}"
    local reverse="${2:-false}"
    
    local field_index=0
    case "$field" in
        user) field_index=0 ;;
        login) field_index=1 ;;
        duration) field_index=2 ;;
        processes) field_index=4 ;;
    esac
    
    # Create array with sort key
    local temp_array=()
    for entry in "${data[@]}"; do
        local key=$(echo "$entry" | cut -d'|' -f$((field_index + 1)))
        temp_array+=("$key|$entry")
    done
    
    # Sort
    local sorted_data=()
    if [ "$reverse" = true ]; then
        IFS=$'\n' sorted_data=($(sort -r <<<"${temp_array[*]}"))
    else
        IFS=$'\n' sorted_data=($(sort <<<"${temp_array[*]}"))
    fi
    
    # Extract original entries
    local result=()
    for entry in "${sorted_data[@]}"; do
        result+=("${entry#*|}")
    done
    
    echo "${result[@]}"
}

# Export data to JSON file
export_json() {
    local data=("$@")
    local file="$1"
    local timestamp=$(date -Iseconds)
    
    {
        echo "{"
        echo "  \"timestamp\": \"$timestamp\","
        echo "  \"users\": ["
        
        local first=true
        for entry in "${data[@]}"; do
            local user=$(echo "$entry" | cut -d'|' -f1)
            local login=$(echo "$entry" | cut -d'|' -f2)
            local duration_seconds=$(echo "$entry" | cut -d'|' -f3)
            local duration_formatted=$(echo "$entry" | cut -d'|' -f4)
            local processes=$(echo "$entry" | cut -d'|' -f5)

            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi

            echo -n "    {"
            echo -n "\"username\": \"$user\", "
            echo -n "\"last_login\": \"$login\", "
            echo -n "\"duration_seconds\": $duration_seconds, "
            echo -n "\"duration_formatted\": \"$duration_formatted\", "
            echo -n "\"process_count\": $processes"
            echo -n "}"
        done
        
        echo ""
        echo "  ]"
        echo "}"
    } > "$file"
}

# Export data to CSV file
export_csv() {
    local data=("$@")
    local file="$1"
    
    {
        echo "username,last_login,duration_seconds,duration_formatted,process_count"
        
        for entry in "${data[@]}"; do
            local user=$(echo "$entry" | cut -d'|' -f1)
            local login=$(echo "$entry" | cut -d'|' -f2)
            local duration_seconds=$(echo "$entry" | cut -d'|' -f3)
            local duration_formatted=$(echo "$entry" | cut -d'|' -f4)
            local processes=$(echo "$entry" | cut -d'|' -f5)

            echo "$user,$login,$duration_seconds,$duration_formatted,$processes"
        done
    } > "$file"
}

# Print colored output
print_color() {
    local color="$1"
    local text="$2"
    
    case "$color" in
        red)
            echo -e "\033[1;31m$text\033[0m"
            ;;
        green)
            echo -e "\033[1;32m$text\033[0m"
            ;;
        yellow)
            echo -e "\033[1;33m$text\033[0m"
            ;;
        blue)
            echo -e "\033[1;34m$text\033[0m"
            ;;
        magenta)
            echo -e "\033[1;35m$text\033[0m"
            ;;
        cyan)
            echo -e "\033[1;36m$text\033[0m"
            ;;
        white)
            echo -e "\033[1;37m$text\033[0m"
            ;;
        *)
            echo "$text"
            ;;
    esac
}

# Load configuration file
load_config() {
    local config_file="$1"
    
    if [ ! -f "$config_file" ]; then
        return 1
    fi
    
    # Source the config file
    source "$config_file"
    return 0
}

# Validate user exists
validate_user() {
    local username="$1"
    
    if id "$username" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Get user home directory
get_user_home() {
    local username="$1"
    getent passwd "$username" | cut -d: -f6
}

# Get user shell
get_user_shell() {
    local username="$1"
    getent passwd "$username" | cut -d: -f7
}

# Check if user is currently logged in
is_user_logged_in() {
    local username="$1"
    
    if who | grep -q "^$username "; then
        return 0
    else
        return 1
    fi
}

# Get system uptime
get_system_uptime() {
    local uptime=$(uptime -s 2>/dev/null || uptime | awk '{print $3, $4}')
    echo "$uptime"
}

# Get current timestamp in ISO format
get_current_timestamp() {
    date -Iseconds
}

# Calculate time difference
time_diff() {
    local start_time="$1"
    local end_time="$2"
    
    local start_timestamp=$(date -d "$start_time" +%s 2>/dev/null || echo "0")
    local end_timestamp=$(date -d "$end_time" +%s 2>/dev/null || echo "0")
    
    if [ "$start_timestamp" -eq 0 ] || [ "$end_timestamp" -eq 0 ]; then
        echo "0"
        return
    fi
    
    echo $((end_timestamp - start_timestamp))
}

# Print header with separator
print_header() {
    local title="$1"
    local width=80
    
    echo ""
    echo "$title"
    printf '%*s\n' "$width" '' | tr ' ' '='
    echo ""
}

# Print error message
print_error() {
    local message="$1"
    echo "Error: $message" >&2
}

# Print warning message
print_warning() {
    local message="$1"
    echo "Warning: $message" >&2
}

# Print info message
print_info() {
    local message="$1"
    echo "Info: $message"
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Get number of CPU cores
get_cpu_cores() {
    nproc 2>/dev/null || echo "1"
}

# Get total memory in GB
get_total_memory() {
    local mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    echo "$((mem_kb / 1024 / 1024))"
}

# Get disk usage for path
get_disk_usage() {
    local path="${1:-/}"
    df -h "$path" | tail -n 1 | awk '{print $3 " / " $2 " (" $5 ")"}'
}

# Export all functions
export -f get_all_users
export -f get_last_login
export -f get_online_duration
export -f count_processes
export -f get_logged_in_users
export -f format_duration
export -f format_timestamp
export -f sort_users
export -f export_json
export -f export_csv
export -f print_color
export -f load_config
export -f validate_user
export -f get_user_home
export -f get_user_shell
export -f is_user_logged_in
export -f get_system_uptime
export -f get_current_timestamp
export -f time_diff
export -f print_header
export -f print_error
export -f print_warning
export -f print_info
export -f command_exists
export -f get_cpu_cores
export -f get_total_memory
export -f get_disk_usage