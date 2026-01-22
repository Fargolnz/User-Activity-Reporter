# User Activity Reporter

A comprehensive CLI tool for monitoring and reporting user activities on Linux systems.

## Overview

**user-activity-reporter** is a command-line tool designed for system administrators to track user activities including login times, online duration, and active process counts. It provides real-time monitoring capabilities and supports multiple export formats.

## Developers

- Seyyedeh Fargol Nazemzadeh
- Zahra Kamalian
- Reihaneh Sharifi
- Fatemeh Mohammadganji

## Features

- **User Activity Monitoring**: Track last login times, online duration, and process counts
- **Real-time Monitoring**: Watch mode with configurable refresh intervals
- **Multiple Export Formats**: Export reports in Table, JSON, or CSV format
- **Sorting and Filtering**: Sort by user, login time, duration, or process count
- **Color-coded Output**: Visual highlighting for high process counts
- **Configurable Settings**: Customizable via configuration file
- **Activity Thresholds**: Alert when process counts exceed specified limits
- **Standard CLI Options**: Support for `--help` and `--version` flags

## Project Structure

```
user-activity-reporter/
├── src/
│   ├── user-activity-reporter    # Main executable (755)
│   ├── user-activity-lib.sh      # Shared library (644)
│   └── user-activity.conf        # Configuration file (644)
├── man/
│   └── user-activity-reporter.1  # Man page (644)
├── debian/                       # Debian packaging files
├── rpm/                          # RPM packaging files
├── scripts/                      # Build scripts
├── Makefile                      # Build automation
├── LICENSE                       # MIT License
├── GUIDE.md                      # Packaging guide
├── PACKAGING.md                  # Packaging info
├── REPORT.md                     # Project report
└── README.md                     # This file
```

## Installation

### Debian/Ubuntu

```bash
# Install dependencies
sudo apt install build-essential debhelper devscripts

# Build package
./scripts/build-deb.sh

# Install package
sudo dpkg -i build/deb/user-activity-reporter_1.0.1_all.deb
```

### Fedora/RHEL

```bash
# Install dependencies
sudo dnf install rpm-build rpmdevtools

# Build package
./scripts/build-rpm.sh

# Install package
sudo rpm -i build/rpm/user-activity-reporter-1.0.1.noarch.rpm
```

### Manual Installation

```bash
# Install using Makefile
sudo make install

# Or manually
sudo cp src/user-activity-reporter /usr/bin/
sudo chmod 755 /usr/bin/user-activity-reporter
sudo mkdir -p /usr/share/user-activity-reporter
sudo cp src/user-activity-lib.sh /usr/share/user-activity-reporter/
sudo mkdir -p /etc/user-activity-reporter
sudo cp src/user-activity.conf /etc/user-activity-reporter/
sudo mkdir -p /usr/share/man/man1
sudo cp man/user-activity-reporter.1 /usr/share/man/man1/
```

## Usage

### Basic Usage

```bash
# Show activity for all users
user-activity-reporter

# Show activity for a specific user
user-activity-reporter -u username

# Show version
user-activity-reporter --version

# Show help
user-activity-reporter --help
```

### Real-time Monitoring

```bash
# Watch mode with default 5-second refresh
user-activity-reporter -w

# Watch mode with custom 10-second refresh
user-activity-reporter -w 10
```

### Export Reports

```bash
# Export to JSON
user-activity-reporter -o report.json -f json

# Export to CSV
user-activity-reporter -o report.csv -f csv

# Export to TXT (table format)
user-activity-reporter -o report.txt -f table
```

### Sorting and Filtering

```bash
# Sort by process count (ascending)
user-activity-reporter -s processes

# Sort by process count (descending)
user-activity-reporter -s processes -r

# Sort by login time
user-activity-reporter -s login

# Sort by duration
user-activity-reporter -s duration
```

### Advanced Options

```bash
# Use custom configuration file
user-activity-reporter -c /path/to/custom.conf

# Disable colored output
user-activity-reporter --no-color

# Highlight users with more than 50 processes
user-activity-reporter --threshold 50

# Combine options
user-activity-reporter -u username -s processes -r --threshold 100
```

## Command Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-v, --version` | Show version information |
| `-u, --user USER` | Show activity for specific user |
| `-a, --all` | Show all users (default) |
| `-s, --sort FIELD` | Sort by field (user, login, duration, processes) |
| `-r, --reverse` | Reverse sort order |
| `-w, --watch [SECONDS]` | Real-time monitoring mode |
| `-o, --output FILE` | Export report to file |
| `-f, --format FORMAT` | Output format (table, json, csv) |
| `-c, --config FILE` | Use custom config file |
| `--no-color` | Disable colored output |
| `--threshold N` | Alert if process count exceeds N |

## Output Formats

### Table Format (Default)

```
USER       LAST LOGIN           DURATION    PROCESSES
root       2026-01-19 14:30:00  2h 15m      45
fargol     2026-01-19 16:00:00  7m 30s      12
```

### JSON Format

```json
{
  "timestamp": "2026-01-19T16:13:28+03:30",
  "users": [
    {
      "username": "root",
      "last_login": "2026-01-19T14:30:00+03:30",
      "duration_seconds": 8100,
      "duration_formatted": "2h 15m",
      "process_count": 45
    }
  ]
}
```

### CSV Format

```csv
username,last_login,duration_seconds,duration_formatted,process_count
root,2026-01-19T14:30:00+03:30,8100,2h 15m,45
fargol,2026-01-19T16:00:00+03:30,450,7m 30s,12
```

## Configuration

The configuration file is located at `/etc/user-activity-reporter/user-activity.conf`.

### Configuration Options

```bash
# Output settings
DEFAULT_FORMAT="table"
ENABLE_COLORS=true
SHOW_HEADER=true

# Monitoring settings
DEFAULT_REFRESH_INTERVAL=5
PROCESS_THRESHOLD=100

# Display settings
TIME_FORMAT="%Y-%m-%d %H:%M:%S"
DATE_FORMAT="%Y-%m-%d"

# Export settings
EXPORT_DIR="/var/log/user-activity"
DEFAULT_EXPORT_FORMAT="json"

# User filtering
EXCLUDE_USERS="nobody,systemd-*"
INCLUDE_ONLY=""

# Advanced settings
MIN_UID=1000
MAX_UID=60000
SHOW_SYSTEM_USERS=false
DEFAULT_SORT_ORDER="asc"
DEFAULT_SORT_FIELD="user"
```

## Files Installed

| File | Location | Permission | Type |
|------|----------|------------|------|
| user-activity-reporter | /usr/bin/ | 755 | Executable |
| user-activity-lib.sh | /usr/share/user-activity-reporter/ | 644 | Library |
| user-activity.conf | /etc/user-activity-reporter/ | 644 | Config |
| user-activity-reporter.1 | /usr/share/man/man1/ | 644 | Man page |

## Uninstallation

### Debian/Ubuntu

```bash
sudo dpkg -r user-activity-reporter
```

### Fedora/RHEL

```bash
sudo rpm -e user-activity-reporter
```

### Manual

```bash
sudo make uninstall
```

## Requirements

- Bash 4.0 or higher
- Standard Linux utilities: `who`, `last`, `ps`, `date`, `getent`
- Read access to `/etc/passwd`, `/var/log/wtmp`, and `/proc`

## Building from Source

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Build Debian package
./scripts/build-deb.sh

# Build RPM package
./scripts/build-rpm.sh

# Build both packages
./scripts/build-all.sh

# Or use Makefile
make package
```

Output will be in the `build/` directory.

## Documentation

- **Man Page**: `man user-activity-reporter`

## Examples

### Monitor specific user in real-time

```bash
user-activity-reporter -u fargol -w 10
```

### Export daily report

```bash
user-activity-reporter -o "report-$(date +%Y%m%d).json" -f json
```

### Find users with high process count

```bash
user-activity-reporter -s processes -r --threshold 50
```

### Generate CSV for spreadsheet analysis

```bash
user-activity-reporter -o activity.csv -f csv
```

## Troubleshooting

### Permission Denied

Ensure the script has execute permissions:
```bash
sudo chmod 755 /usr/bin/user-activity-reporter
```

### No Data Displayed

Check if you have read access to system files:
```bash
ls -l /var/log/wtmp
ls -l /etc/passwd
```

### User Not Found

Verify the user exists:
```bash
id username
```

## License

MIT License - See [LICENSE](LICENSE) file.


## Contributing

This project was developed as a final project for the Operating Systems Lab course at the University of Tehran.

## Acknowledgments

- University of Tehran - Faculty of Farabi
- Operating Systems Lab
- Academic Year 1404-1405
