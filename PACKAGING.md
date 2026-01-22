# راهنمای بسته‌بندی لینوکس

این مستند ساختار پروژه و نحوه بسته‌بندی لینوکس را توضیح می‌دهد.

---

## ساختار پروژه

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

## انواع فایل و مجوزها

### فایل‌های اجرایی (Executables)
- **مجوز**: `755` (rwxr-xr-x)
- **محل نصب**: `/usr/bin/`
- **مثال**: `user-activity-reporter`

```bash
install -m 755 src/user-activity-reporter/usr/bin/user-activity-reporter
```

### فایل‌های کتابخانه (Libraries)
- **مجوز**: `644` (rw-r--r--)
- **محل نصب**: `/usr/share/user-activity-reporter/`
- **مثال**: `user-activity-lib.sh`

این فایل‌ها توسط برنامه‌های دیگر `source` می‌شوند ولی مستقیماً اجرا نمی‌شوند.

```bash
install -m 644 src/user-activity-lib.sh /usr/share/user-activity-reporter/
```

### فایل‌های پیکربندی (Config)
- **مجوز**: `644` (rw-r--r--)
- **محل نصب**: `/etc/user-activity-reporter/`
- **مثال**: `user-activity.conf`

```bash
install -m 644 src/user-activity.conf /etc/user-activity-reporter/
```

### صفحات Man
- **مجوز**: `644`
- **محل نصب**: `/usr/share/man/man1/`
- معمولاً با gzip فشرده می‌شوند

---

## بسته‌بندی Debian

### فایل `debian/control`

```
Source: user-activity-reporter
Section: utils
Priority: optional
Maintainer: Seyyedeh Fargol Nazemzadeh <fargol.nz@gmail.com>
Build-Depends: debhelper-compat (= 13)

Package: user-activity-reporter
Architecture: all
Depends: ${misc:Depends}, bash
Description: User Activity Reporter for Linux
```

**فیلدهای مهم:**
- `Architecture: all` - برای اسکریپت‌ها (بدون کامپایل)
- `Depends` - وابستگی‌های اجرا

### فایل `debian/install`

این فایل مشخص می‌کند هر فایل کجا نصب شود:

```
src/user-activity-reporter usr/bin
src/user-activity-lib.sh usr/share/user-activity-reporter
src/user-activity.conf etc/user-activity-reporter
man/user-activity-reporter.1 usr/share/man/man1
```

### فایل `debian/rules`

```makefile
#!/usr/bin/make -f
%:
    dh $@

override_dh_fixperms:
    dh_fixperms
    chmod 755 debian/user-activity-reporter/usr/bin/user-activity-reporter
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

# کتابخانه
install -m 644 src/user-activity-lib.sh %{buildroot}%{_datadir}/user-activity-reporter/

# پیکربندی
install -m 644 src/user-activity.conf %{buildroot}%{_sysconfdir}/user-activity-reporter/

%files
%{_bindir}/user-activity-reporter
%{_datadir}/user-activity-reporter/user-activity-lib.sh
%config(noreplace) %{_sysconfdir}/user-activity-reporter/user-activity.conf
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
    install -m 755 src/user-activity-reporter $(DESTDIR)$(BINDIR)/

    # کتابخانه (644)
    install -m 644 src/user-activity-lib.sh $(DESTDIR)$(DATADIR)/

    # پیکربندی (644)
    install -m 644 src/user-activity.conf $(DESTDIR)$(CONFDIR)/
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
    -n user-activity-reporter \
    -v 1.0.0 \
    --depends bash \
    --config-files /etc/user-activity-reporter/user-activity.conf \
    -C staging/ \
    .
```

---

## نصب و حذف

### نصب
```bash
# Debian
sudo dpkg -i user-activity-reporter_1.0.1_all.deb

# Fedora
sudo rpm -i user-activity-reporter-1.0.1.noarch.rpm
```

### حذف
```bash
# Debian
sudo dpkg -r user-activity-reporter

# Fedora
sudo rpm -e user-activity-reporter
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
