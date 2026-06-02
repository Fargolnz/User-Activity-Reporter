#!/bin/bash
# Build script for RPM package (Fedora/RHEL)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build/rpm"
PACKAGE_NAME="user-activity-reporter"
VERSION="1.1.0"

echo "=== Building RPM Package ==="

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

build_with_rpmbuild() {
    echo "Using rpmbuild..."

    RPMBUILD_DIR="$BUILD_DIR/rpmbuild"
    mkdir -p "$RPMBUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

    # Create source tarball
    TARBALL_DIR="$BUILD_DIR/${PACKAGE_NAME}-${VERSION}"
    mkdir -p "$TARBALL_DIR"
    cp -r "$PROJECT_DIR/src" "$TARBALL_DIR/"
    cp -r "$PROJECT_DIR/man" "$TARBALL_DIR/"
    cp "$PROJECT_DIR/README.md" "$TARBALL_DIR/"
    cp "$PROJECT_DIR/LICENSE" "$TARBALL_DIR/"
    cp "$PROJECT_DIR/Makefile" "$TARBALL_DIR/"

    cd "$BUILD_DIR"
    tar czf "$RPMBUILD_DIR/SOURCES/${PACKAGE_NAME}-${VERSION}.tar.gz" "${PACKAGE_NAME}-${VERSION}"
    cp "$PROJECT_DIR/rpm/user-activity-reporter.spec" "$RPMBUILD_DIR/SPECS/"

    rpmbuild --define "_topdir $RPMBUILD_DIR" -bb "$RPMBUILD_DIR/SPECS/user-activity-reporter.spec"
    cp "$RPMBUILD_DIR/RPMS"/*/*.rpm "$BUILD_DIR/" 2>/dev/null || true

    echo ""
    echo "=== Build Complete ==="
    ls -la "$BUILD_DIR"/*.rpm 2>/dev/null
}

build_with_fpm() {
    echo "Using fpm..."

    STAGING="$BUILD_DIR/staging"
    mkdir -p "$STAGING/usr/bin"
    mkdir -p "$STAGING/usr/share/user-activity-reporter"
    mkdir -p "$STAGING/usr/share/man/man1"
    mkdir -p "$STAGING/usr/share/doc/user-activity-reporter"
    mkdir -p "$STAGING/etc/user-activity-reporter"

    # Executables (755)
    cp "$PROJECT_DIR/src/user-activity-reporter" "$STAGING/usr/bin/"
    chmod 755 "$STAGING/usr/bin/user-activity-reporter"

    # Library (644)
    cp "$PROJECT_DIR/src/user-activity-lib.sh" "$STAGING/usr/share/user-activity-reporter/"
    chmod 644 "$STAGING/usr/share/user-activity-reporter/user-activity-lib.sh"

    # Config (644)
    cp "$PROJECT_DIR/src/user-activity.conf" "$STAGING/etc/user-activity-reporter/"
    chmod 644 "$STAGING/etc/user-activity-reporter/user-activity.conf"

    # Man pages
    cp "$PROJECT_DIR/man/user-activity-reporter.1" "$STAGING/usr/share/man/man1/"
    gzip -f "$STAGING/usr/share/man/man1/"*.1

    # Docs
    cp "$PROJECT_DIR/README.md" "$STAGING/usr/share/doc/user-activity-reporter/"
    cp "$PROJECT_DIR/LICENSE" "$STAGING/usr/share/doc/user-activity-reporter/"

    cd "$BUILD_DIR"
    fpm -s dir -t rpm \
        -n "$PACKAGE_NAME" \
        -v "$VERSION" \
        --description "User Activity Reporter for Linux" \
        --license "MIT" \
        --architecture noarch \
        --depends bash \
        --config-files /etc/user-activity-reporter/user-activity.conf \
        -C "$STAGING" \
        .

    echo ""
    echo "=== Build Complete ==="
    ls -la "$BUILD_DIR"/*.rpm
}

if command -v fpm &> /dev/null; then
    build_with_fpm
elif command -v rpmbuild &> /dev/null; then
    build_with_rpmbuild
else
    echo "Neither fpm nor rpmbuild found."
    echo ""
    echo "Install fpm:"
    echo "  sudo dnf install ruby ruby-devel gcc make rpm-build"
    echo "  sudo gem install fpm"
    echo ""
    echo "Or install rpmbuild:"
    echo "  sudo dnf install rpm-build rpmdevtools"
    exit 1
fi
