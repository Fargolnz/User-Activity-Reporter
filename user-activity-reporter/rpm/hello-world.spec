Name:           hello-world
Version:        1.0.0
Release:        1%{?dist}
Summary:        A simple hello world package with multiple commands

License:        MIT
URL:            https://github.com/example/hello-world
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       bash

%description
This package provides two commands:
 - hello-world: prints a customizable greeting
 - hello-info: displays system information

It demonstrates Linux packaging with multiple executables,
shared libraries, and configuration files.

%prep
%setup -q

%build
# Nothing to build (shell scripts)

%install
# Executables
mkdir -p %{buildroot}%{_bindir}
install -m 755 src/hello-world %{buildroot}%{_bindir}/hello-world
install -m 755 src/hello-info %{buildroot}%{_bindir}/hello-info

# Shared library
mkdir -p %{buildroot}%{_datadir}/hello-world
install -m 644 src/hello-lib.sh %{buildroot}%{_datadir}/hello-world/hello-lib.sh

# Configuration
mkdir -p %{buildroot}%{_sysconfdir}/hello-world
install -m 644 src/hello.conf %{buildroot}%{_sysconfdir}/hello-world/hello.conf

# Man pages
mkdir -p %{buildroot}%{_mandir}/man1
install -m 644 man/hello-world.1 %{buildroot}%{_mandir}/man1/hello-world.1
install -m 644 man/hello-info.1 %{buildroot}%{_mandir}/man1/hello-info.1

%files
%license LICENSE
%doc README.md
%{_bindir}/hello-world
%{_bindir}/hello-info
%{_datadir}/hello-world/hello-lib.sh
%config(noreplace) %{_sysconfdir}/hello-world/hello.conf
%{_mandir}/man1/hello-world.1*
%{_mandir}/man1/hello-info.1*

%changelog
* Wed Dec 11 2025 Your Name <your.email@example.com> - 1.0.0-1
- Initial release with multiple executables
- Added hello-world and hello-info commands
- Added shared library and configuration file
