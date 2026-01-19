#!/bin/bash
# Build both Debian and RPM packages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Building All Packages"
echo "=========================================="

if command -v dpkg &> /dev/null; then
    echo ""
    "$SCRIPT_DIR/build-deb.sh"
fi

if command -v rpm &> /dev/null; then
    echo ""
    "$SCRIPT_DIR/build-rpm.sh"
fi

echo ""
echo "=========================================="
echo "  Done! Output: $(dirname "$SCRIPT_DIR")/build/"
echo "=========================================="
