# This file is part of MXE.
# See index.html for further information.

PKG             := trng
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.19
$(PKG)_CHECKSUM := 36b49961c631ae01d770ff481796c8b280e18c6b6e6b5ca00f2b868533b0492e
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
