# آموزش کامل بسته‌بندی لینوکس

این راهنما یک آموزش قدم به قدم برای ساخت بسته‌های لینوکس (DEB و RPM) است.

---

## فهرست مطالب

1. [مقدمه](#مقدمه)
2. [پیش‌نیازها](#پیش‌نیازها)
3. [ساختار پروژه](#ساختار-پروژه)
4. [نوشتن برنامه](#نوشتن-برنامه)
5. [ساخت صفحات Man](#ساخت-صفحات-man)
6. [نوشتن Makefile](#نوشتن-makefile)
7. [بسته‌بندی Debian](#بسته‌بندی-debian)
8. [بسته‌بندی RPM](#بسته‌بندی-rpm)
9. [ساخت و نصب](#ساخت-و-نصب)
10. [نکات پیشرفته](#نکات-پیشرفته)

---

## مقدمه

### بسته چیست؟

بسته (Package) یک فایل فشرده است که شامل:
- فایل‌های برنامه
- اطلاعات نصب (کجا نصب شود)
- وابستگی‌ها (چه بسته‌های دیگری لازم است)
- اسکریپت‌های نصب/حذف

### انواع بسته

| فرمت | توزیع | ابزار نصب |
|------|-------|-----------|
| `.deb` | Debian, Ubuntu | `dpkg`, `apt` |
| `.rpm` | Fedora, RHEL, CentOS | `rpm`, `dnf` |

---

## پیش‌نیازها

### برای Debian/Ubuntu
```bash
sudo apt update
sudo apt install build-essential debhelper devscripts
```

### برای Fedora
```bash
sudo dnf install rpm-build rpmdevtools
# یا برای fpm:
sudo dnf install ruby ruby-devel gcc make
sudo gem install fpm
```

---

## ساختار پروژه

### قدم ۱: ساخت دایرکتوری‌ها

```bash
mkdir -p mypackage/{src,man,debian,rpm,scripts}
cd mypackage
```

### ساختار نهایی

```
user-activity-reporter/
├── src/                          # فایل‌های منبع
│   ├── user-activity-reporter    # برنامه اصلی (اجرایی)
│   ├── user-activity-lib.sh      # کتابخانه مشترک (غیر اجرایی)
│   └── user-activity.conf        # فایل پیکربندی (غیر اجرایی)
├── man/                          # صفحات راهنما
│   ├── user-activity-reporter.1  # man برای user-activity-reporter
├── debian/                       # بسته‌بندی Debian
│   ├── control                   # اطلاعات بسته
│   ├── changelog                 # تاریخچه تغییرات
│   ├── rules                     # قوانین ساخت
│   ├── copyright                 # مجوز
│   ├── install                   # فهرست نصب
│   └── source/format
├── rpm/                          # بسته‌بندی RPM
│   └── user-activity-reporter.spec # فایل spec
├── scripts/                      # اسکریپت‌های ساخت
│   ├── build-deb.sh
│   ├── build-rpm.sh
│   └── build-all.sh
├── Makefile                      # اسکریپت‌های ساخت
├── LICENSE                       # مجوز
├── GUIDE.md                      # آموزش پکیج‌ها
├── PACKAGING.md                  # راهنمای پکیج‌ها
├── REPORT.md                     # گزارش پروژه
└── README.md                     # مستندات
```

---

## نوشتن برنامه

### قدم ۲: برنامه اجرایی اصلی

فایل `src/user-activity-reporter`:
```bash
#!/bin/bash
# user-activity-reporter - برنامه اصلی

VERSION="1.1.0"

# بارگذاری کتابخانه مشترک
LIB_PATH="/usr/share/user-activity-reporter/user-activity-lib.sh"
[ -f "$LIB_PATH" ] && source "$LIB_PATH"

# بارگذاری تنظیمات
CONF_PATH="/etc/user-activity-reporter/user-activity.conf"
[ -f "$CONF_PATH" ] && source "$CONF_PATH"

case "${1:-}" in
    -h|--help)
        echo "Usage: user-activity-reporter [OPTIONS]"
        echo "  -h, --help      Show help"
        echo "  -v, --version   Show version"
        ;;
    -v|--version)
        echo "user-activity-reporter version $VERSION"
        ;;
    *)
        echo "${GREETING:-Hello}, ${NAME:-World}!"
        ;;
esac
```

### قدم ۳: کتابخانه مشترک

فایل `src/user-activity-lib.sh`:
```bash
#!/bin/bash
# user-activity-lib.sh - توابع مشترک
# این فایل source می‌شود، مستقیم اجرا نمی‌شود

print_header() {
    local text="$1"
    echo "=== $text ==="
}
```

**نکته مهم**: این فایل با `source` بارگذاری می‌شود، پس نیاز به مجوز اجرا ندارد.

### قدم ۴: فایل پیکربندی

فایل `src/user-activity.conf`:
```bash
# تنظیمات user-activity-reporter
GREETING="Hello"
NAME="World"
```

### تنظیم مجوزها

```bash
# فایل‌های اجرایی: 755
chmod 755 src/user-activity-reporter

# فایل‌های غیر اجرایی: 644
chmod 644 src/user-activity-lib.sh
chmod 644 src/user-activity.conf
```

---

## ساخت صفحات Man

### قدم ۵: صفحه Man برای user-activity-reporter

فایل `man/user-activity-reporter.1`:
```troff
.TH USER-ACTIVITY-REPORTER 1 "January 2026" "user-activity-reporter 1.1.0" "User Commands"
.SH NAME
user-activity-reporter \- User Activity Reporter for Linux
.SH SYNOPSIS
.B user-activity-reporter
[\fIOPTIONS\fR]
.SH DESCRIPTION
\fBuser-activity-reporter\fR is a comprehensive command-line tool for monitoring and reporting user activities on Linux systems. It provides information about user login times, online duration, and active process counts.
.PP
The tool is designed for system administrators who need to track user activity and monitor system resource usage.
.SH OPTIONS
.TP
\fB\-h, \-\-help\fR
Display help message and exit.
.TP
\fB\-v, \-\-version\fR
Display version information and exit.
.TP
\fB\-u, \-\-user\fR \fIUSER\fR
Show activity for a specific user only.
.TP
\fB\-a, \-\-all\fR
Show all users (default behavior).
.TP
\fB\-s, \-\-sort\fR \fIFIELD\fR
Sort output by specified field. Valid fields are:
.RS
.PP
\fBuser\fR \- Sort by username (default)
.PP
\fBlogin\fR \- Sort by last login time
.PP
\fBduration\fR \- Sort by online duration
.PP
\fBprocesses\fR \- Sort by process count
.RE
.TP
\fB\-r, \-\-reverse\fR
Reverse the sort order.
...
```

### دستورات فرمت Man

| دستور | کاربرد | مثال |
|-------|--------|------|
| `.TH` | عنوان | `.TH NAME 1 "Date" "Version"` |
| `.SH` | سرفصل | `.SH OPTIONS` |
| `.TP` | پاراگراف | قبل از هر آپشن |
| `.B` | بولد | `.B user-activity-reporter` |
| `.I` | ایتالیک | `.I /path/to/file` |
| `.BR` | بولد+معمولی | `.BR \-h ", " \-\-help` |

---

## نوشتن Makefile

### قدم ۶: ساخت Makefile

```makefile
# Makefile for user-activity-reporter package

PACKAGE_NAME = user-activity-reporter
VERSION = 1.1.0

# مسیرهای نصب (قابل تغییر)
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
DATADIR ?= $(PREFIX)/share/$(PACKAGE_NAME)
MANDIR ?= $(PREFIX)/share/man/man1
CONFDIR ?= /etc/$(PACKAGE_NAME)
DOCDIR ?= $(PREFIX)/share/doc/$(PACKAGE_NAME)

.PHONY: all install uninstall clean

all:
	@echo "Run 'make install' to install"

install:
	# ساخت دایرکتوری‌ها
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(DATADIR)
	install -d $(DESTDIR)$(CONFDIR)
	install -d $(DESTDIR)$(MANDIR)

	# نصب فایل‌های اجرایی (755)
	install -m 755 src/user-activity-reporter $(DESTDIR)$(BINDIR)/

	# نصب کتابخانه (644)
	install -m 644 src/user-activity-lib.sh $(DESTDIR)$(DATADIR)/

	# نصب پیکربندی (644)
	install -m 644 src/user-activity.conf $(DESTDIR)$(CONFDIR)/

	# نصب صفحات man (644)
	install -m 644 man/user-activity-reporter.1 $(DESTDIR)$(MANDIR)/

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/user-activity-reporter
	rm -rf $(DESTDIR)$(DATADIR)
	rm -rf $(DESTDIR)$(CONFDIR)
	rm -f $(DESTDIR)$(MANDIR)/user-activity-reporter.1*

clean:
	rm -rf build/
```

### توضیح متغیرها

| متغیر | توضیح |
|-------|-------|
| `PREFIX` | پیشوند مسیر نصب (معمولاً `/usr`) |
| `DESTDIR` | دایرکتوری موقت برای بسته‌سازی |
| `?=` | مقدار پیش‌فرض (قابل override) |

### دستور install

```bash
install -d DIR          # ساخت دایرکتوری
install -m 755 SRC DST  # کپی با مجوز 755
install -m 644 SRC DST  # کپی با مجوز 644
```

---

## بسته‌بندی Debian

### قدم ۷: فایل control

فایل `debian/control`:
```
Source: user-activity-reporter
Section: utils
Priority: optional
Maintainer: Seyyedeh Fargol Nazemzadeh <fargol.nz@gmail.com>
Build-Depends: debhelper-compat (= 13)
Standards-Version: 4.6.0
Rules-Requires-Root: no

Package: user-activity-reporter
Architecture: all
Depends: ${misc:Depends}, bash
Description: User Activity Reporter for Linux
 A comprehensive CLI tool for monitoring and reporting user activities including login times, online duration, and process counts.
```

### فیلدهای مهم

| فیلد | توضیح |
|------|-------|
| `Source` | نام بسته منبع |
| `Package` | نام بسته باینری |
| `Architecture` | `all` برای اسکریپت، `amd64` برای باینری |
| `Depends` | وابستگی‌های اجرا |
| `Build-Depends` | وابستگی‌های ساخت |

### قدم ۸: فایل changelog

فایل `debian/changelog`:
```
user-activity-reporter (1.0.0-1) unstable; urgency=low

  * Initial release
  * Added user-activity-reporter command

 -- Soltan and Moridan Team <fargol.nz@gmail.com>  Wed, 11 Dec 2025 12:00:00 +0000
```

**فرمت نسخه**: `VERSION-REVISION`
- `1.1.0` = نسخه upstream
- `1` = شماره revision دبیان

### قدم ۹: فایل rules

فایل `debian/rules`:
```makefile
#!/usr/bin/make -f

export DH_VERBOSE = 1

%:
	dh $@

override_dh_auto_install:
	$(MAKE) install DESTDIR=$(CURDIR)/debian/user-activity-reporter PREFIX=/usr
```

**مهم**: این فایل باید اجرایی باشد:
```bash
chmod +x debian/rules
```

### قدم ۱۰: فایل install

فایل `debian/install`:
```
src/user-activity-reporter usr/bin
src/user-activity.sh usr/share/user-activity-reporter
src/user-activity.conf etc/user-activity-reporter
man/user-activity-reporter.1 usr/share/man/man1
```

**فرمت**: `SOURCE DESTINATION`
- بدون `/` در ابتدای مقصد
- مسیر نسبی به ریشه بسته

### قدم ۱۱: فایل copyright

فایل `debian/copyright`:
```
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: user-activity-reporter
Source: https://github.com/fargolnz/user-activity-reporter

Files: *
Copyright: 2025 Seyyedeh Fargol Nazemzadeh
License: MIT

License: MIT
 Permission is hereby granted...
```

### قدم ۱۲: فایل source/format

فایل `debian/source/format`:
```
3.0 (native)
```

**انواع**:
- `3.0 (native)` = بسته native (بدون tarball جدا)
- `3.0 (quilt)` = بسته با tarball upstream و patch

---

## بسته‌بندی RPM

### قدم ۱۳: فایل Spec

فایل `rpm/user-activity-reporter.spec`:
```spec
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

%prep
%setup -q

%build
# Nothing to build

%install
# Executables
mkdir -p %{buildroot}%{_bindir}
install -m 755 src/user-activity-reporter %{buildroot}%{_bindir}/

# Library
mkdir -p %{buildroot}%{_datadir}/user-activity-reporter
install -m 644 src/user-activity-lib.sh %{buildroot}%{_datadir}/user-activity-reporter/

# Config
mkdir -p %{buildroot}%{_sysconfdir}/user-activity-reporter
install -m 644 src/user-activity.conf %{buildroot}%{_sysconfdir}/user-activity-reporter/

# Man pages
mkdir -p %{buildroot}%{_mandir}/man1
install -m 644 man/user-activity-reporter.1 %{buildroot}%{_mandir}/man1/

%files
%license LICENSE
%doc README.md
%{_bindir}/user-activity-reporter
%{_datadir}/user-activity-reporter/user-activity-lib.sh
%config(noreplace) %{_sysconfdir}/user-activity-reporter/user-activity.conf
%{_mandir}/man1/user-activity-reporter.1*

%changelog
* Sun, 19 Jan 2026 Soltan and Moridan Team <fargol.nz@gmail.com> - 1.0.0-1
- Initial release
```

### بخش‌های فایل Spec

| بخش | توضیح |
|-----|-------|
| `%prep` | آماده‌سازی (استخراج tarball) |
| `%build` | کامپایل (خالی برای اسکریپت) |
| `%install` | نصب در buildroot |
| `%files` | لیست فایل‌های بسته |
| `%changelog` | تاریخچه تغییرات |

### متغیرهای RPM

| متغیر | مقدار |
|-------|-------|
| `%{_bindir}` | `/usr/bin` |
| `%{_datadir}` | `/usr/share` |
| `%{_sysconfdir}` | `/etc` |
| `%{_mandir}` | `/usr/share/man` |
| `%{buildroot}` | دایرکتوری ساخت موقت |

### نشانگرهای خاص در %files

| نشانگر | توضیح |
|--------|-------|
| `%license` | فایل مجوز |
| `%doc` | مستندات |
| `%config` | فایل پیکربندی |
| `%config(noreplace)` | پیکربندی که در آپدیت حفظ شود |

---

## ساخت و نصب

### قدم ۱۴: اسکریپت ساخت Debian

فایل `scripts/build-deb.sh`:
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build/deb"
PACKAGE_NAME="user-activity-reporter"
VERSION="1.1.0"

echo "=== Building Debian Package ==="

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# کپی فایل‌ها
BUILD_SRC="$BUILD_DIR/${PACKAGE_NAME}-${VERSION}"
mkdir -p "$BUILD_SRC"
cp -r "$PROJECT_DIR/src" "$BUILD_SRC/"
cp -r "$PROJECT_DIR/man" "$BUILD_SRC/"
cp -r "$PROJECT_DIR/debian" "$BUILD_SRC/"
cp "$PROJECT_DIR/Makefile" "$BUILD_SRC/"
cp "$PROJECT_DIR/README.md" "$BUILD_SRC/"
cp "$PROJECT_DIR/LICENSE" "$BUILD_SRC/"

chmod +x "$BUILD_SRC/debian/rules"

cd "$BUILD_SRC"
dpkg-buildpackage -us -uc -b

echo "=== Done ==="
ls -la "$BUILD_DIR"/*.deb
```

### قدم ۱۵: اسکریپت ساخت RPM

فایل `scripts/build-rpm.sh`:
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build/rpm"
PACKAGE_NAME="user-activity-reporter"
VERSION="1.1.0"

echo "=== Building RPM Package ==="

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# با استفاده از rpmbuild
RPMBUILD_DIR="$BUILD_DIR/rpmbuild"
mkdir -p "$RPMBUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# ساخت tarball
TARBALL_DIR="$BUILD_DIR/${PACKAGE_NAME}-${VERSION}"
mkdir -p "$TARBALL_DIR"
cp -r "$PROJECT_DIR/src" "$TARBALL_DIR/"
cp -r "$PROJECT_DIR/man" "$TARBALL_DIR/"
cp "$PROJECT_DIR/README.md" "$TARBALL_DIR/"
cp "$PROJECT_DIR/LICENSE" "$TARBALL_DIR/"
cp "$PROJECT_DIR/Makefile" "$TARBALL_DIR/"

cd "$BUILD_DIR"
tar czf "$RPMBUILD_DIR/SOURCES/${PACKAGE_NAME}-${VERSION}.tar.gz" \
    "${PACKAGE_NAME}-${VERSION}"

cp "$PROJECT_DIR/rpm/user-activity-reporter.spec" "$RPMBUILD_DIR/SPECS/"

rpmbuild --define "_topdir $RPMBUILD_DIR" \
    -bb "$RPMBUILD_DIR/SPECS/user-activity-reporter.spec"

cp "$RPMBUILD_DIR/RPMS"/*/*.rpm "$BUILD_DIR/"

echo "=== Done ==="
ls -la "$BUILD_DIR"/*.rpm
```

### قدم ۱۶: اجرای ساخت

```bash
# اجرایی کردن اسکریپت‌ها
chmod +x scripts/*.sh

# ساخت بسته Debian
./scripts/build-deb.sh

# ساخت بسته RPM
./scripts/build-rpm.sh
```

### قدم ۱۷: نصب بسته

```bash
# Debian/Ubuntu
sudo dpkg -i build/deb/user-activity-reporter_1.1.0_all.deb

# Fedora/RHEL
sudo rpm -i build/rpm/user-activity-reporter-1.1.0.noarch.rpm
```

### قدم ۱۸: تست

```bash
# تست برنامه
user-activity-reporter
user-activity-reporter --version

# مشاهده man
man user-activity-reporter
```

### حذف بسته

```bash
# Debian
sudo dpkg -r user-activity-reporter

# Fedora
sudo rpm -e user-activity-reporter
```

---

## نکات پیشرفته

### استفاده از FPM

FPM ابزار ساده‌تری برای ساخت بسته است:

```bash
# نصب fpm
sudo gem install fpm

# ساخت RPM
fpm -s dir -t rpm \
    -n user-activity-reporter \
    -v 1.1.0 \
    --description "User Activity Reporter for Linux" \
    --depends bash \
    --config-files /etc/user-activity-reporter/user-activity.conf \
    usr/=/usr/ \
    etc/=/etc/

# ساخت DEB
fpm -s dir -t deb \
    -n user-activity-reporter \
    -v 1.1.0 \
    usr/=/usr/ \
    etc/=/etc/
```

### اسکریپت‌های Pre/Post

#### Debian

فایل `debian/postinst`:
```bash
#!/bin/bash
echo "Package installed successfully!"
```

فایل `debian/prerm`:
```bash
#!/bin/bash
echo "Removing package..."
```

#### RPM

در فایل spec:
```spec
%post
echo "Package installed successfully!"

%preun
echo "Removing package..."
```

### وابستگی‌ها

#### Debian
```
Depends: bash, coreutils (>= 8.0)
Recommends: curl
Suggests: wget
```

#### RPM
```spec
Requires: bash
Requires: coreutils >= 8.0
```

### چندین بسته از یک منبع

#### Debian
```
Package: user-activity-reporter
Architecture: all
Depends: bash
Description: Main package

Package: user-activity-reporter-doc
Architecture: all
Description: Documentation
```

#### RPM
```spec
%package doc
Summary: Documentation
%description doc
Documentation for user-activity-reporter

%files doc
%doc README.md
```

---

## خلاصه

### چک‌لیست ساخت بسته

- [ ] ساخت ساختار دایرکتوری
- [ ] نوشتن برنامه‌ها
- [ ] تنظیم مجوزها (755/644)
- [ ] نوشتن صفحات man
- [ ] نوشتن Makefile
- [ ] آماده‌سازی فایل‌های debian/
- [ ] آماده‌سازی فایل spec
- [ ] نوشتن اسکریپت‌های ساخت
- [ ] تست ساخت بسته
- [ ] تست نصب و اجرا

### مجوزهای فایل

| نوع فایل | مجوز | توضیح |
|----------|------|-------|
| اجرایی | 755 | rwxr-xr-x |
| کتابخانه | 644 | rw-r--r-- |
| پیکربندی | 644 | rw-r--r-- |
| مستندات | 644 | rw-r--r-- |

### مسیرهای استاندارد

| نوع | مسیر |
|-----|------|
| اجرایی | `/usr/bin/` |
| کتابخانه | `/usr/share/PACKAGE/` |
| پیکربندی | `/etc/PACKAGE/` |
| Man | `/usr/share/man/man1/` |
| مستندات | `/usr/share/doc/PACKAGE/` |

---

## منابع

- [Debian Policy Manual](https://www.debian.org/doc/debian-policy/)
- [RPM Packaging Guide](https://rpm-packaging-guide.github.io/)
- [FPM Documentation](https://fpm.readthedocs.io/)
- [GNU Make Manual](https://www.gnu.org/software/make/manual/)
