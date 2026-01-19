# Makefile for hello-world package

PACKAGE_NAME = hello-world
VERSION = 1.0.0
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
DATADIR ?= $(PREFIX)/share/$(PACKAGE_NAME)
MANDIR ?= $(PREFIX)/share/man/man1
CONFDIR ?= /etc/$(PACKAGE_NAME)
DOCDIR ?= $(PREFIX)/share/doc/$(PACKAGE_NAME)

.PHONY: all install uninstall clean

all:
	@echo "Nothing to compile (shell script package)"
	@echo "Run 'make install' to install"

install:
	# Install executables (755 = rwxr-xr-x)
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 src/hello-world $(DESTDIR)$(BINDIR)/hello-world
	install -m 755 src/hello-info $(DESTDIR)$(BINDIR)/hello-info

	# Install shared library (644 = rw-r--r--)
	install -d $(DESTDIR)$(DATADIR)
	install -m 644 src/hello-lib.sh $(DESTDIR)$(DATADIR)/hello-lib.sh

	# Install configuration (644 = rw-r--r--)
	install -d $(DESTDIR)$(CONFDIR)
	install -m 644 src/hello.conf $(DESTDIR)$(CONFDIR)/hello.conf

	# Install man pages (644 = rw-r--r--)
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 man/hello-world.1 $(DESTDIR)$(MANDIR)/hello-world.1
	install -m 644 man/hello-info.1 $(DESTDIR)$(MANDIR)/hello-info.1

	# Install documentation
	install -d $(DESTDIR)$(DOCDIR)
	install -m 644 README.md $(DESTDIR)$(DOCDIR)/ || true

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/hello-world
	rm -f $(DESTDIR)$(BINDIR)/hello-info
	rm -rf $(DESTDIR)$(DATADIR)
	rm -rf $(DESTDIR)$(CONFDIR)
	rm -f $(DESTDIR)$(MANDIR)/hello-world.1*
	rm -f $(DESTDIR)$(MANDIR)/hello-info.1*
	rm -rf $(DESTDIR)$(DOCDIR)

clean:
	rm -rf build/
	@echo "Cleaned build directory"
