# hello-world

A demonstration Linux package for learning Debian (.deb) and RPM packaging.

## Overview

This project demonstrates how to create Linux packages with:
- Multiple executable commands
- Shared library files
- Configuration files
- Man pages
- Build scripts for both Debian and Fedora

## Project Structure

```
oslab-packaging/
├── src/                    # Source files
│   ├── hello-world         # Main command (executable)
│   ├── hello-info          # Second command (executable)
│   ├── hello-lib.sh        # Shared library (sourced)
│   └── hello.conf          # Configuration file
├── man/                    # Man pages
│   ├── hello-world.1
│   └── hello-info.1
├── debian/                 # Debian packaging files
│   ├── control
│   ├── changelog
│   ├── rules
│   ├── install
│   ├── copyright
│   └── source/format
├── rpm/                    # RPM packaging files
│   └── hello-world.spec
├── scripts/                # Build scripts
│   ├── build-deb.sh
│   ├── build-rpm.sh
│   └── build-all.sh
├── Makefile
├── LICENSE
├── README.md               # This file
├── PACKAGING.md            # Quick reference (Persian)
└── guide.md                # Full tutorial (Persian)
```

## Commands

| Command | Description |
|---------|-------------|
| `hello-world` | Print a customizable greeting |
| `hello-info` | Display system information |
| `hello-info -s` | Short system info output |

## Files Installed

| File | Location | Permission | Type |
|------|----------|------------|------|
| hello-world | /usr/bin/ | 755 | Executable |
| hello-info | /usr/bin/ | 755 | Executable |
| hello-lib.sh | /usr/share/hello-world/ | 644 | Library |
| hello.conf | /etc/hello-world/ | 644 | Config |
| hello-world.1 | /usr/share/man/man1/ | 644 | Man page |
| hello-info.1 | /usr/share/man/man1/ | 644 | Man page |

## Requirements

### Debian/Ubuntu
```bash
sudo apt install build-essential debhelper devscripts
```

### Fedora
```bash
sudo dnf install rpm-build rpmdevtools
# Or for fpm:
sudo dnf install ruby ruby-devel gcc make
sudo gem install fpm
```

## Build

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Build Debian package
./scripts/build-deb.sh

# Build RPM package
./scripts/build-rpm.sh

# Build both
./scripts/build-all.sh
```

Output will be in `build/` directory.

## Install

### Debian/Ubuntu
```bash
sudo dpkg -i build/deb/hello-world_1.0.0-1_all.deb
```

### Fedora/RHEL
```bash
sudo rpm -i build/rpm/hello-world-1.0.0-1.noarch.rpm
```

## Usage

```bash
# Show greeting
hello-world

# Show version
hello-world --version

# Show help
hello-world --help

# Show system info
hello-info

# Short system info
hello-info --short

# View man pages
man hello-world
man hello-info
```

## Uninstall

### Debian/Ubuntu
```bash
sudo dpkg -r hello-world
```

### Fedora/RHEL
```bash
sudo rpm -e hello-world
```

## Configuration

Edit `/etc/hello-world/hello.conf` to customize:
```bash
GREETING="Hello"
NAME="World"
```

## Documentation

| File | Language | Description |
|------|----------|-------------|
| `README.md` | English | Project overview |
| `PACKAGING.md` | Persian | Quick reference guide |
| `guide.md` | Persian | Full step-by-step tutorial |

## File Permissions Explained

- **755 (rwxr-xr-x)**: Executable files - can be run directly
- **644 (rw-r--r--)**: Non-executable files - libraries, configs, docs

## License

MIT License - See [LICENSE](LICENSE) file.

## Author

OSLab Packaging Demo
