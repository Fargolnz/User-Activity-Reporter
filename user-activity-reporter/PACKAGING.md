# راهنمای بسته‌بندی لینوکس

این مستند ساختار پروژه و نحوه بسته‌بندی لینوکس را توضیح می‌دهد.

---

## ساختار پروژه

```
oslab-packaging/
├── src/                          # فایل‌های منبع
│   ├── hello-world               # برنامه اصلی (اجرایی)
│   ├── hello-info                # برنامه دوم (اجرایی)
│   ├── hello-lib.sh              # کتابخانه مشترک (غیر اجرایی)
│   └── hello.conf                # فایل پیکربندی (غیر اجرایی)
├── man/                          # صفحات راهنما
│   ├── hello-world.1             # man برای hello-world
│   └── hello-info.1              # man برای hello-info
├── debian/                       # بسته‌بندی Debian
│   ├── control                   # اطلاعات بسته
│   ├── changelog                 # تاریخچه تغییرات
│   ├── rules                     # قوانین ساخت
│   ├── copyright                 # مجوز
│   ├── install                   # فهرست نصب
│   └── source/format
├── rpm/                          # بسته‌بندی RPM
│   └── hello-world.spec          # فایل spec
├── scripts/                      # اسکریپت‌های ساخت
│   ├── build-deb.sh
│   ├── build-rpm.sh
│   └── build-all.sh
├── Makefile
├── LICENSE
└── README.md
```

---

## انواع فایل و مجوزها

### فایل‌های اجرایی (Executables)
- **مجوز**: `755` (rwxr-xr-x)
- **محل نصب**: `/usr/bin/`
- **مثال**: `hello-world`, `hello-info`

```bash
install -m 755 src/hello-world /usr/bin/hello-world
```

### فایل‌های کتابخانه (Libraries)
- **مجوز**: `644` (rw-r--r--)
- **محل نصب**: `/usr/share/PACKAGE_NAME/`
- **مثال**: `hello-lib.sh`

این فایل‌ها توسط برنامه‌های دیگر `source` می‌شوند ولی مستقیماً اجرا نمی‌شوند.

```bash
install -m 644 src/hello-lib.sh /usr/share/hello-world/
```

### فایل‌های پیکربندی (Config)
- **مجوز**: `644` (rw-r--r--)
- **محل نصب**: `/etc/PACKAGE_NAME/`
- **مثال**: `hello.conf`

```bash
install -m 644 src/hello.conf /etc/hello-world/
```

### صفحات Man
- **مجوز**: `644`
- **محل نصب**: `/usr/share/man/man1/`
- معمولاً با gzip فشرده می‌شوند

---

## بسته‌بندی Debian

### فایل `debian/control`

```
Source: hello-world
Section: utils
Priority: optional
Maintainer: نام <ایمیل>
Build-Depends: debhelper-compat (= 13)

Package: hello-world
Architecture: all
Depends: ${misc:Depends}, bash
Description: توضیحات بسته
```

**فیلدهای مهم:**
- `Architecture: all` - برای اسکریپت‌ها (بدون کامپایل)
- `Depends` - وابستگی‌های اجرا

### فایل `debian/install`

این فایل مشخص می‌کند هر فایل کجا نصب شود:

```
src/hello-world usr/bin
src/hello-info usr/bin
src/hello-lib.sh usr/share/hello-world
src/hello.conf etc/hello-world
man/hello-world.1 usr/share/man/man1
man/hello-info.1 usr/share/man/man1
```

### فایل `debian/rules`

```makefile
#!/usr/bin/make -f
%:
    dh $@

override_dh_fixperms:
    dh_fixperms
    chmod 755 debian/hello-world/usr/bin/hello-world
    chmod 755 debian/hello-world/usr/bin/hello-info
```

### ساخت بسته Debian

```bash
dpkg-buildpackage -us -uc -b
```

---

## بسته‌بندی RPM

### فایل Spec

```spec
Name:           user-activity-reporter
Version:        1.0.1
Release:        1%{?dist}
BuildArch:      noarch
Requires:       bash

%install
# فایل‌های اجرایی
install -m 755 src/user-activity-reporter %{buildroot}%{_bindir}/
install -m 755 src/user-activity-reporter-info %{buildroot}%{_bindir}/

# کتابخانه
install -m 644 src/user-activity-lib.sh %{buildroot}%{_datadir}/hello-world/

# پیکربندی
install -m 644 src/user-activity.conf %{buildroot}%{_sysconfdir}/hello-world/

%files
%{_bindir}/hello-world
%{_bindir}/hello-info
%{_datadir}/hello-world/hello-lib.sh
%config(noreplace) %{_sysconfdir}/hello-world/hello.conf
```

### متغیرهای RPM

| متغیر | مقدار |
|-------|-------|
| `%{_bindir}` | `/usr/bin` |
| `%{_datadir}` | `/usr/share` |
| `%{_sysconfdir}` | `/etc` |
| `%{_mandir}` | `/usr/share/man` |

### `%config(noreplace)`

برای فایل‌های پیکربندی استفاده می‌شود تا در به‌روزرسانی، تنظیمات کاربر حفظ شود.

---

## Makefile

```makefile
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
DATADIR ?= $(PREFIX)/share/$(PACKAGE_NAME)
CONFDIR ?= /etc/$(PACKAGE_NAME)

install:
    # اجرایی‌ها (755)
    install -m 755 src/hello-world $(DESTDIR)$(BINDIR)/
    install -m 755 src/hello-info $(DESTDIR)$(BINDIR)/

    # کتابخانه (644)
    install -m 644 src/hello-lib.sh $(DESTDIR)$(DATADIR)/

    # پیکربندی (644)
    install -m 644 src/hello.conf $(DESTDIR)$(CONFDIR)/
```

**نکات:**
- `DESTDIR` برای نصب در مسیر موقت (توسط بسته‌ساز)
- `install -d` برای ساخت دایرکتوری
- `install -m XXX` برای تنظیم مجوز

---

## صفحات Man

### ساختار

```troff
.TH COMMAND 1 "تاریخ" "نسخه" "User Commands"
.SH NAME
command \- توضیح کوتاه
.SH SYNOPSIS
.B command
[\fIOPTION\fR]
.SH DESCRIPTION
توضیحات
.SH OPTIONS
.TP
.BR \-h ", " \-\-help
راهنما
.SH SEE ALSO
.BR other-command (1)
```

### شماره بخش‌ها

| شماره | نوع |
|-------|-----|
| 1 | دستورات کاربر |
| 5 | فرمت فایل‌ها |
| 8 | دستورات مدیریت |

---

## FPM (روش ساده)

```bash
fpm -s dir -t rpm \
    -n hello-world \
    -v 1.0.0 \
    --depends bash \
    --config-files /etc/hello-world/hello.conf \
    -C staging/ \
    .
```

---

## نصب و حذف

### نصب
```bash
# Debian
sudo dpkg -i hello-world_1.0.0-1_all.deb

# Fedora
sudo rpm -i hello-world-1.0.0-1.noarch.rpm
```

### حذف
```bash
# Debian
sudo dpkg -r hello-world

# Fedora
sudo rpm -e hello-world
```

---

## نکات مهم

1. **مجوز فایل‌ها**:
   - اجرایی: `755`
   - غیر اجرایی: `644`

2. **فولدر build**:
   - خروجی ساخت در `build/` ذخیره می‌شود
   - با `make clean` پاک می‌شود
   - در git نباید commit شود

3. **Architecture**:
   - `all` (deb) یا `noarch` (rpm) برای اسکریپت‌ها
   - `amd64`/`x86_64` برای باینری‌ها

4. **وابستگی‌ها**:
   - همیشه وابستگی‌ها را مشخص کنید
   - `bash` برای اسکریپت‌های shell

5. **فایل پیکربندی**:
   - در RPM از `%config(noreplace)` استفاده کنید
   - در `/etc/` قرار می‌گیرد
