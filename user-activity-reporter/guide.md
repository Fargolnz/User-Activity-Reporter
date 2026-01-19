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
mypackage/
├── src/                    # کد منبع
│   ├── program1            # فایل اجرایی اول
│   ├── program2            # فایل اجرایی دوم
│   ├── common-lib.sh       # کتابخانه مشترک
│   └── config.conf         # فایل پیکربندی
├── man/                    # صفحات راهنما
│   ├── program1.1
│   └── program2.1
├── debian/                 # فایل‌های Debian
├── rpm/                    # فایل‌های RPM
├── scripts/                # اسکریپت‌های ساخت
├── Makefile
├── LICENSE
└── README.md
```

---

## نوشتن برنامه

### قدم ۲: برنامه اجرایی اصلی

فایل `src/hello-world`:
```bash
#!/bin/bash
# hello-world - برنامه اصلی

VERSION="1.0.0"

# بارگذاری کتابخانه مشترک
LIB_PATH="/usr/share/hello-world/hello-lib.sh"
[ -f "$LIB_PATH" ] && source "$LIB_PATH"

# بارگذاری تنظیمات
CONF_PATH="/etc/hello-world/hello.conf"
[ -f "$CONF_PATH" ] && source "$CONF_PATH"

case "${1:-}" in
    -h|--help)
        echo "Usage: hello-world [OPTIONS]"
        echo "  -h, --help      Show help"
        echo "  -v, --version   Show version"
        ;;
    -v|--version)
        echo "hello-world version $VERSION"
        ;;
    *)
        echo "${GREETING:-Hello}, ${NAME:-World}!"
        ;;
esac
```

### قدم ۳: برنامه اجرایی دوم

فایل `src/hello-info`:
```bash
#!/bin/bash
# hello-info - نمایش اطلاعات سیستم

VERSION="1.0.0"

# بارگذاری کتابخانه
LIB_PATH="/usr/share/hello-world/hello-lib.sh"
[ -f "$LIB_PATH" ] && source "$LIB_PATH"

case "${1:-}" in
    -h|--help)
        echo "Usage: hello-info [OPTIONS]"
        echo "  -h, --help    Show help"
        echo "  -s, --short   Short output"
        ;;
    -s|--short)
        echo "$(uname -n) | $(uname -r)"
        ;;
    *)
        print_header "System Info"
        echo "Hostname: $(uname -n)"
        echo "Kernel:   $(uname -r)"
        ;;
esac
```

### قدم ۴: کتابخانه مشترک

فایل `src/hello-lib.sh`:
```bash
#!/bin/bash
# hello-lib.sh - توابع مشترک
# این فایل source می‌شود، مستقیم اجرا نمی‌شود

print_header() {
    local text="$1"
    echo "=== $text ==="
}
```

**نکته مهم**: این فایل با `source` بارگذاری می‌شود، پس نیاز به مجوز اجرا ندارد.

### قدم ۵: فایل پیکربندی

فایل `src/hello.conf`:
```bash
# تنظیمات hello-world
GREETING="Hello"
NAME="World"
```

### تنظیم مجوزها

```bash
# فایل‌های اجرایی: 755
chmod 755 src/hello-world
chmod 755 src/hello-info

# فایل‌های غیر اجرایی: 644
chmod 644 src/hello-lib.sh
chmod 644 src/hello.conf
```

---

## ساخت صفحات Man

### قدم ۶: صفحه Man برای hello-world

فایل `man/hello-world.1`:
```troff
.TH HELLO-WORLD 1 "December 2025" "1.0.0" "User Commands"
.SH NAME
hello-world \- print a greeting message
.SH SYNOPSIS
.B hello-world
[\fIOPTION\fR]
.SH DESCRIPTION
.B hello-world
prints a customizable greeting message.
.SH OPTIONS
.TP
.BR \-h ", " \-\-help
Display help message.
.TP
.BR \-v ", " \-\-version
Display version.
.SH FILES
.TP
.I /etc/hello-world/hello.conf
Configuration file.
.SH SEE ALSO
.BR hello-info (1)
```

### قدم ۷: صفحه Man برای hello-info

فایل `man/hello-info.1`:
```troff
.TH HELLO-INFO 1 "December 2025" "1.0.0" "User Commands"
.SH NAME
hello-info \- display system information
.SH SYNOPSIS
.B hello-info
[\fIOPTION\fR]
.SH DESCRIPTION
.B hello-info
displays basic system information.
.SH OPTIONS
.TP
.BR \-h ", " \-\-help
Display help.
.TP
.BR \-s ", " \-\-short
Short output.
.SH SEE ALSO
.BR hello-world (1)
```

### دستورات فرمت Man

| دستور | کاربرد | مثال |
|-------|--------|------|
| `.TH` | عنوان | `.TH NAME 1 "Date" "Version"` |
| `.SH` | سرفصل | `.SH OPTIONS` |
| `.TP` | پاراگراف | قبل از هر آپشن |
| `.B` | بولد | `.B hello-world` |
| `.I` | ایتالیک | `.I /path/to/file` |
| `.BR` | بولد+معمولی | `.BR \-h ", " \-\-help` |

---

## نوشتن Makefile

### قدم ۸: ساخت Makefile

```makefile
# Makefile for hello-world package

PACKAGE_NAME = hello-world
VERSION = 1.0.0

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
	install -m 755 src/hello-world $(DESTDIR)$(BINDIR)/
	install -m 755 src/hello-info $(DESTDIR)$(BINDIR)/

	# نصب کتابخانه (644)
	install -m 644 src/hello-lib.sh $(DESTDIR)$(DATADIR)/

	# نصب پیکربندی (644)
	install -m 644 src/hello.conf $(DESTDIR)$(CONFDIR)/

	# نصب صفحات man (644)
	install -m 644 man/hello-world.1 $(DESTDIR)$(MANDIR)/
	install -m 644 man/hello-info.1 $(DESTDIR)$(MANDIR)/

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/hello-world
	rm -f $(DESTDIR)$(BINDIR)/hello-info
	rm -rf $(DESTDIR)$(DATADIR)
	rm -rf $(DESTDIR)$(CONFDIR)
	rm -f $(DESTDIR)$(MANDIR)/hello-world.1*
	rm -f $(DESTDIR)$(MANDIR)/hello-info.1*

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

### قدم ۹: فایل control

فایل `debian/control`:
```
Source: hello-world
Section: utils
Priority: optional
Maintainer: Your Name <email@example.com>
Build-Depends: debhelper-compat (= 13)
Standards-Version: 4.6.0
Rules-Requires-Root: no

Package: hello-world
Architecture: all
Depends: ${misc:Depends}, bash
Description: A hello world package
 This package provides hello-world and hello-info commands.
 It demonstrates Linux packaging concepts.
```

### فیلدهای مهم

| فیلد | توضیح |
|------|-------|
| `Source` | نام بسته منبع |
| `Package` | نام بسته باینری |
| `Architecture` | `all` برای اسکریپت، `amd64` برای باینری |
| `Depends` | وابستگی‌های اجرا |
| `Build-Depends` | وابستگی‌های ساخت |

### قدم ۱۰: فایل changelog

فایل `debian/changelog`:
```
hello-world (1.0.0-1) unstable; urgency=low

  * Initial release
  * Added hello-world command
  * Added hello-info command

 -- Your Name <email@example.com>  Wed, 11 Dec 2025 12:00:00 +0000
```

**فرمت نسخه**: `VERSION-REVISION`
- `1.0.0` = نسخه upstream
- `1` = شماره revision دبیان

### قدم ۱۱: فایل rules

فایل `debian/rules`:
```makefile
#!/usr/bin/make -f

export DH_VERBOSE = 1

%:
	dh $@

override_dh_auto_install:
	$(MAKE) install DESTDIR=$(CURDIR)/debian/hello-world PREFIX=/usr
```

**مهم**: این فایل باید اجرایی باشد:
```bash
chmod +x debian/rules
```

### قدم ۱۲: فایل install

فایل `debian/install`:
```
src/hello-world usr/bin
src/hello-info usr/bin
src/hello-lib.sh usr/share/hello-world
src/hello.conf etc/hello-world
man/hello-world.1 usr/share/man/man1
man/hello-info.1 usr/share/man/man1
```

**فرمت**: `SOURCE DESTINATION`
- بدون `/` در ابتدای مقصد
- مسیر نسبی به ریشه بسته

### قدم ۱۳: فایل copyright

فایل `debian/copyright`:
```
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: hello-world
Source: https://github.com/example/hello-world

Files: *
Copyright: 2025 Your Name
License: MIT

License: MIT
 Permission is hereby granted...
```

### قدم ۱۴: فایل source/format

فایل `debian/source/format`:
```
3.0 (native)
```

**انواع**:
- `3.0 (native)` = بسته native (بدون tarball جدا)
- `3.0 (quilt)` = بسته با tarball upstream و patch

---

## بسته‌بندی RPM

### قدم ۱۵: فایل Spec

فایل `rpm/hello-world.spec`:
```spec
Name:           hello-world
Version:        1.0.0
Release:        1%{?dist}
Summary:        A hello world package

License:        MIT
URL:            https://github.com/example/hello-world
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       bash

%description
This package provides hello-world and hello-info commands.
It demonstrates Linux packaging concepts.

%prep
%setup -q

%build
# Nothing to build

%install
# Executables
mkdir -p %{buildroot}%{_bindir}
install -m 755 src/hello-world %{buildroot}%{_bindir}/
install -m 755 src/hello-info %{buildroot}%{_bindir}/

# Library
mkdir -p %{buildroot}%{_datadir}/hello-world
install -m 644 src/hello-lib.sh %{buildroot}%{_datadir}/hello-world/

# Config
mkdir -p %{buildroot}%{_sysconfdir}/hello-world
install -m 644 src/hello.conf %{buildroot}%{_sysconfdir}/hello-world/

# Man pages
mkdir -p %{buildroot}%{_mandir}/man1
install -m 644 man/hello-world.1 %{buildroot}%{_mandir}/man1/
install -m 644 man/hello-info.1 %{buildroot}%{_mandir}/man1/

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
* Wed Dec 11 2025 Your Name <email@example.com> - 1.0.0-1
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

### قدم ۱۶: اسکریپت ساخت Debian

فایل `scripts/build-deb.sh`:
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build/deb"
PACKAGE_NAME="hello-world"
VERSION="1.0.0"

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

### قدم ۱۷: اسکریپت ساخت RPM

فایل `scripts/build-rpm.sh`:
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build/rpm"
PACKAGE_NAME="hello-world"
VERSION="1.0.0"

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

cp "$PROJECT_DIR/rpm/hello-world.spec" "$RPMBUILD_DIR/SPECS/"

rpmbuild --define "_topdir $RPMBUILD_DIR" \
    -bb "$RPMBUILD_DIR/SPECS/hello-world.spec"

cp "$RPMBUILD_DIR/RPMS"/*/*.rpm "$BUILD_DIR/"

echo "=== Done ==="
ls -la "$BUILD_DIR"/*.rpm
```

### قدم ۱۸: اجرای ساخت

```bash
# اجرایی کردن اسکریپت‌ها
chmod +x scripts/*.sh

# ساخت بسته Debian
./scripts/build-deb.sh

# ساخت بسته RPM
./scripts/build-rpm.sh
```

### قدم ۱۹: نصب بسته

```bash
# Debian/Ubuntu
sudo dpkg -i build/deb/hello-world_1.0.0-1_all.deb

# Fedora/RHEL
sudo rpm -i build/rpm/hello-world-1.0.0-1.noarch.rpm
```

### قدم ۲۰: تست

```bash
# تست برنامه
hello-world
hello-world --version

hello-info
hello-info --short

# مشاهده man
man hello-world
man hello-info
```

### حذف بسته

```bash
# Debian
sudo dpkg -r hello-world

# Fedora
sudo rpm -e hello-world
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
    -n hello-world \
    -v 1.0.0 \
    --description "Hello world package" \
    --depends bash \
    --config-files /etc/hello-world/hello.conf \
    usr/=/usr/ \
    etc/=/etc/

# ساخت DEB
fpm -s dir -t deb \
    -n hello-world \
    -v 1.0.0 \
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
Package: hello-world
Architecture: all
Depends: bash
Description: Main package

Package: hello-world-doc
Architecture: all
Description: Documentation
```

#### RPM
```spec
%package doc
Summary: Documentation
%description doc
Documentation for hello-world

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
