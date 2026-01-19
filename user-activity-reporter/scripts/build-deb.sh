#!/bin/bash
# Build script for Debian package (.deb)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build/deb"
PACKAGE_NAME="user-activity-reporter"
VERSION="1.0.0"

echo "=== Building Debian Package ==="

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create source directory
BUILD_SRC="$BUILD_DIR/${PACKAGE_NAME}-${VERSION}"
mkdir -p "$BUILD_SRC"

# Copy files
cp -r "$PROJECT_DIR/src" "$BUILD_SRC/"
cp -r "$PROJECT_DIR/man" "$BUILD_SRC/"
cp -r "$PROJECT_DIR/debian" "$BUILD_SRC/"
cp "$PROJECT_DIR/Makefile" "$BUILD_SRC/"
cp "$PROJECT_DIR/README.md" "$BUILD_SRC/"
cp "$PROJECT_DIR/LICENSE" "$BUILD_SRC/"

chmod +x "$BUILD_SRC/debian/rules"

cd "$BUILD_SRC"

if command -v dpkg-buildpackage &> /dev/null; then
    dpkg-buildpackage -us -uc -b
    echo ""
    echo "=== Build Complete ==="
    ls -la "$BUILD_DIR"/*.deb 2>/dev/null || echo "Check: $BUILD_DIR"
else
    echo "dpkg-buildpackage not found."
    echo "Install: sudo apt install devscripts debhelper build-essential"
fi
