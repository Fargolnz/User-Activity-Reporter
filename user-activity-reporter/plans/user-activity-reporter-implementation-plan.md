# User Activity Reporter - Implementation Plan

## Project Overview

**Tool Name:** `user-activity-reporter`

**Project Type:** CLI Tool for Linux System Monitoring

**Description:** A comprehensive command-line tool that reports user activities including last login time, online duration, active process count, and extended features for system administrators.

**Package Format:** Debian (.deb) and RPM packages

**Language:** Bash Scripting

---

## Extended Features

### Core Features (Required)
- Display last login time for users
- Show online duration for active users
- Count active processes per user
- Support for multiple users

### Extended Features (Bonus)
- Real-time monitoring mode
- Activity history tracking
- Detailed reports with sorting options
- Export reports to file (JSON, CSV, TXT)
- Filter by user or activity level
- Color-coded output for better readability
- Configurable output format
- Support for --help and --version flags
- Activity thresholds and alerts

---

## Architecture

### File Structure

```
user-activity-reporter/
├── src/
│   ├── user-activity-reporter    # Main executable (755)
│   ├── user-activity-lib.sh      # Shared library (644)
│   └── user-activity.conf        # Configuration file (644)
├── man/
│   └── user-activity-reporter.1  # Man page (644)
├── debian/
│   ├── control                   # Package metadata
│   ├── changelog                 # Version history
│   ├── rules                     # Build rules
│   ├── install                   # File installation paths
│   ├── copyright                 # License info
│   └── source/format             # Source format
├── rpm/
│   └── user-activity-reporter.spec  # RPM spec file
├── scripts/
│   ├── build-deb.sh              # Debian build script
│   ├── build-rpm.sh              # RPM build script
│   └── build-all.sh              # Build both packages
├── Makefile                      # Build automation
├── README.md                     # Project documentation
└── LICENSE                       # MIT License
```

### Installation Paths

| File | Destination | Permission |
|------|-------------|------------|
| user-activity-reporter | /usr/bin/ | 755 |
| user-activity-lib.sh | /usr/share/user-activity-reporter/ | 644 |
| user-activity.conf | /etc/user-activity-reporter/ | 644 |
| user-activity-reporter.1 | /usr/share/man/man1/ | 644 |

---

## Implementation Details

### 1. Main Executable (user-activity-reporter)

**Purpose:** Primary CLI interface for the tool

**Key Functions:**
- Parse command-line arguments
- Load configuration
- Call library functions
- Format and display output
- Handle export operations

**Command Options:**
```
user-activity-reporter [OPTIONS]

Options:
  -h, --help              Show help message
  -v, --version           Show version information
  -u, --user USER         Show activity for specific user
  -a, --all               Show all users (default)
  -s, --sort FIELD        Sort by field (user, login, duration, processes)
  -r, --reverse           Reverse sort order
  -w, --watch             Real-time monitoring mode (refresh every N seconds)
  -o, --output FILE       Export report to file
  -f, --format FORMAT     Output format (table, json, csv)
  -c, --config FILE       Use custom config file
  --no-color              Disable colored output
  --threshold N           Alert if process count exceeds N
```

**Example Usage:**
```bash
# Show all users
user-activity-reporter

# Show specific user
user-activity-reporter -u username

# Real-time monitoring (refresh every 5 seconds)
user-activity-reporter -w 5

# Export to JSON
user-activity-reporter -o report.json -f json

# Sort by process count
user-activity-reporter -s processes -r
```

### 2. Shared Library (user-activity-lib.sh)

**Purpose:** Reusable functions for data collection and processing

**Key Functions:**

```bash
# Get all users on system
get_all_users()

# Get last login time for user
get_last_login(username)

# Calculate online duration
get_online_duration(username)

# Count active processes for user
count_processes(username)

# Get current logged-in users
get_logged_in_users()

# Format duration in human-readable format
format_duration(seconds)

# Format timestamp
format_timestamp(timestamp)

# Sort user data
sort_users(data, field, reverse)

# Export to JSON
export_json(data, file)

# Export to CSV
export_csv(data, file)

# Print colored output
print_color(color, text)

# Load configuration
load_config(config_file)
```

### 3. Configuration File (user-activity.conf)

**Purpose:** Default settings and preferences

**Configuration Options:**
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
```

### 4. Man Page (user-activity-reporter.1)

**Sections:**
- NAME
- SYNOPSIS
- DESCRIPTION
- OPTIONS
- EXAMPLES
- CONFIGURATION
- FILES
- EXIT STATUS
- AUTHOR
- SEE ALSO

---

## Data Sources

The tool will use standard Linux commands:
- `who` - Current logged-in users
- `last` - Login history
- `w` - User activity and processes
- `ps` - Process information
- `uptime` - System uptime
- `date` - Current timestamp

---

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

---

## Package Configuration

### Debian Control File
```
Source: user-activity-reporter
Section: admin
Priority: optional
Maintainer: Team Name <team.email@example.com>
Build-Depends: debhelper-compat (= 13)
Standards-Version: 4.6.0

Package: user-activity-reporter
Architecture: all
Depends: ${misc:Depends}, bash
Description: User Activity Reporter for Linux
 A comprehensive CLI tool for monitoring and reporting user activities
 including login times, online duration, and process counts.
 .
 Features:
  - Real-time monitoring
  - Multiple export formats (JSON, CSV, TXT)
  - Configurable output
  - Color-coded display
  - Activity thresholds and alerts
```

### RPM Spec File
Similar structure with RPM-specific directives.

---

## Build Process

### Makefile Targets
- `make install` - Install to local system
- `make uninstall` - Remove from local system
- `make clean` - Clean build artifacts
- `make package` - Build both deb and rpm packages

### Build Scripts
- `scripts/build-deb.sh` - Build Debian package
- `scripts/build-rpm.sh` - Build RPM package
- `scripts/build-all.sh` - Build both packages

---

## Testing Checklist

- [ ] Tool installs correctly via dpkg
- [ ] Tool installs correctly via rpm
- [ ] All command-line options work
- [ ] Configuration file is loaded correctly
- [ ] Output formats work (table, json, csv)
- [ ] Real-time monitoring mode works
- [ ] Sorting and filtering work
- [ ] Export to file works
- [ ] Man page displays correctly
- [ ] Tool works with different user permissions
- [ ] Error handling is robust
- [ ] Package uninstallation works cleanly

---

## Bonus Points (Optional)

For additional credit:
- [ ] GitHub Release with version tag (v1.0.0)
- [ ] Release Notes included
- [ ] SHA256 checksum for package verification
- [ ] Unit tests for library functions
- [ ] Integration tests
- [ ] Additional output formats (HTML, XML)
- [ ] Email notification support
- [ ] Web dashboard integration

---

## Timeline

1. **Phase 1:** Rename files and update package metadata
2. **Phase 2:** Implement shared library functions
3. **Phase 3:** Implement main executable
4. **Phase 4:** Create configuration file
5. **Phase 5:** Write man page
6. **Phase 6:** Update documentation
7. **Phase 7:** Test and debug
8. **Phase 8:** Build packages and verify

---

## Notes

- All scripts must be executable (755)
- All non-executable files must be readable (644)
- Follow Debian Policy Manual guidelines
- Ensure compatibility with Ubuntu, Debian, Fedora, RHEL
- Use only standard Linux tools (no external dependencies)
- Code must be well-commented
- Error messages should be clear and helpful