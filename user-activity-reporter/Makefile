# Makefile for user-activity-reporter package

PACKAGE_NAME = user-activity-reporter
VERSION = 1.0.1
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
DATADIR ?= $(PREFIX)/share/$(PACKAGE_NAME)
MANDIR ?= $(PREFIX)/share/man/man1
CONFDIR ?= /etc/$(PACKAGE_NAME)
DOCDIR ?= $(PREFIX)/share/doc/$(PACKAGE_NAME)

.PHONY: all install uninstall clean package

all:
	@echo "Nothing to compile (shell script package)"
	@echo "Run 'make install' to install"

install:
	# Install executable (755 = rwxr-xr-x)
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 src/user-activity-reporter $(DESTDIR)$(BINDIR)/user-activity-reporter

	# Install shared library (644 = rw-r--r--)
	install -d $(DESTDIR)$(DATADIR)
	install -m 644 src/user-activity-lib.sh $(DESTDIR)$(DATADIR)/user-activity-lib.sh

	# Install configuration (644 = rw-r--r--)
	install -d $(DESTDIR)$(CONFDIR)
	install -m 644 src/user-activity.conf $(DESTDIR)$(CONFDIR)/user-activity.conf

	# Install man page (644 = rw-r--r--)
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 man/user-activity-reporter.1 $(DESTDIR)$(MANDIR)/user-activity-reporter.1

	# Install documentation
	install -d $(DESTDIR)$(DOCDIR)
	install -m 644 README.md $(DESTDIR)$(DOCDIR)/ || true

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/user-activity-reporter
	rm -rf $(DESTDIR)$(DATADIR)
	rm -rf $(DESTDIR)$(CONFDIR)
	rm -f $(DESTDIR)$(MANDIR)/user-activity-reporter.1*
	rm -rf $(DESTDIR)$(DOCDIR)

clean:
	rm -rf build/
	@echo "Cleaned build directory"

package:
	@echo "Building packages..."
	@if [ -x scripts/build-deb.sh ]; then \
		./scripts/build-deb.sh; \
	fi
	@if [ -x scripts/build-rpm.sh ]; then \
		./scripts/build-rpm.sh; \
	fi
	@echo "Packages built in build/ directory"
