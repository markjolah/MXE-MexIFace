# This file is part of MXE.
# See index.html for further information.

PKG             := libics
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.5.2
$(PKG)_CHECKSUM := 9308f910b06d4dff49a12ebc740079383890f011d7bf47b4655361cc301a7f83
$(PKG)_SUBDIR   := libics-$($(PKG)_VERSION)
$(PKG)_FILE     := libics-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://sourceforge.net/projects/libics/files/libics/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc

# define $(PKG)_UPDATE
#     $(WGET) -q -O- 'http://sourceforge.net/projects/libics/files/libics/' | \
#     $(SED) -n 's,.*/\([0-9][^"]*\)/".*,\1,p' | \
#     head -1
# endef


define $(PKG)_BUILD_SHARED
    cd '$(1)' && autoreconf --force --install
    cd '$(1)' && LDFLAGS="-Wl,-no-undefined" ./configure --enable-shared \
        --host='$(TARGET)' \
        --with-zlib='$(PREFIX)' \
        --prefix='$(PREFIX)/$(TARGET)'
    # libtool is somehow created to effectively disallow shared builds
    $(SED) -i 's,allow_undefined_flag="unsupported",allow_undefined_flag="",g' '$(1)/libtool'
    $(MAKE) -C '$(1)'
#     cd '$(1)' && /bin/sh ./libtool --tag=CC --mode=link x86_64-w64-mingw32.shared-gcc  -g -O2  -no-undefined -o libics.la -rpath /nfs/olah/home/mjo/mxe/usr/x86_64-w64-mingw32.shared/lib -version-info 0:0:0 libics_binary.lo libics_compress.lo libics_data.lo libics_gzip.lo libics_history.lo libics_preview.lo libics_read.lo libics_sensor.lo libics_test.lo libics_top.lo libics_util.lo libics_write.lo  -lm
#     ./foo
    $(MAKE) -C '$(1)' install
endef
