# This file is part of MXE.
# See index.html for further information.

PKG             := trng
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.20
$(PKG)_CHECKSUM := 8cffd03392a3e498fe9f93ccfa9ff0c9eacf9fd9d33e3655123852d701bbacbc
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://numbercrunch.de/trng/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc

define $(PKG)_BUILD
    cd '$(1)' && aclocal
    cd '$(1)' && libtoolize --force
    cd '$(1)' && automake --add-missing
    cd '$(1)' && autoreconf
    cd '$(1)' && ./configure --host='$(TARGET)' --enable-shared --disable-static --prefix='$(PREFIX)/$(TARGET)'
    $(MAKE) -C '$(1)' -j '$(JOBS)' LDFLAGS='-no-undefined'
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
