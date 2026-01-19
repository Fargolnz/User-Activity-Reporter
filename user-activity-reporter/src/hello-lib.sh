#!/bin/bash
# hello-lib.sh - Shared library for hello-world package
# This file is sourced by other scripts, not executed directly

# Print a formatted header
print_header() {
    local text="$1"
    local len=${#text}
    printf '=%.0s' $(seq 1 $((len + 4)))
    echo ""
    echo "  $text"
    printf '=%.0s' $(seq 1 $((len + 4)))
    echo ""
}

# Print colored text (if terminal supports it)
print_color() {
    local color="$1"
    local text="$2"
    case "$color" in
        red)    echo -e "\033[31m${text}\033[0m" ;;
        green)  echo -e "\033[32m${text}\033[0m" ;;
        blue)   echo -e "\033[34m${text}\033[0m" ;;
        *)      echo "$text" ;;
    esac
}
