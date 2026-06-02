Name:           user-activity-reporter
Version:        1.1.0
Release:        1%{?dist}
Summary:        User Activity Reporter for Linux

License:        MIT
URL:            https://github.com/fargolnz/user-activity-reporter
Source0:        %{user-activity-reporter}-%{1.1.0}.tar.gz

BuildArch:      noarch
Requires:       bash

%description
A comprehensive CLI tool for monitoring and reporting user activities
including login times, online duration, and process counts.

Features:
 - Real-time monitoring with configurable refresh interval
 - Multiple export formats (JSON, CSV, TXT)
 - Sorting and filtering options
 - Color-coded display
 - Configurable output settings
 - Activity thresholds and alerts

This tool is useful for system administrators who need to track
user activity on Linux systems.

%prep
%setup -q

%build
# Nothing to build (shell scripts)

%install
# Executable
mkdir -p %{buildroot}%{_bindir}
install -m 755 src/user-activity-reporter %{buildroot}%{_bindir}/user-activity-reporter

# Shared library
mkdir -p %{buildroot}%{_datadir}/user-activity-reporter
install -m 644 src/user-activity-lib.sh %{buildroot}%{_datadir}/user-activity-reporter/user-activity-lib.sh

# Configuration
mkdir -p %{buildroot}%{_sysconfdir}/user-activity-reporter
install -m 644 src/user-activity.conf %{buildroot}%{_sysconfdir}/user-activity-reporter/user-activity.conf

# Man page
mkdir -p %{buildroot}%{_mandir}/man1
install -m 644 man/user-activity-reporter.1 %{buildroot}%{_mandir}/man1/user-activity-reporter.1

%files
%license LICENSE
%doc README.md
%{_bindir}/user-activity-reporter
%{_datadir}/user-activity-reporter/user-activity-lib.sh
%config(noreplace) %{_sysconfdir}/user-activity-reporter/user-activity.conf
%{_mandir}/man1/user-activity-reporter.1*

%changelog
* Sun Jan 19 2026 Soltan and Moridan Team <fargol.nz@gmail.com> - 1.0.0
- Initial release
- Added user activity monitoring with login times
- Added online duration tracking
- Added process count per user
- Added real-time monitoring mode
- Added multiple export formats (JSON, CSV, TXT)
- Added sorting and filtering options
- Added color-coded output
- Added configurable settings
- Added activity thresholds and alerts
