# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := armadillo
$(PKG)_WEBSITE  := https://arma.sourceforge.io/
$(PKG)_DESCR    := Armadillo C++ linear algebra library
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 9.400.4
$(PKG)_CHECKSUM := b498ba84f2b7736a4efdfaaab351231f1218ddaa73503a3bd7d0045c514460f3
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://$(SOURCEFORGE_MIRROR)/project/arma/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc hdf5

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://sourceforge.net/projects/arma/files/' | \
    $(SED) -n 's,.*/armadillo-\([0-9.]*\)[.]tar.*".*,\1,p' | \
    head -1
endef

#define $(PKG)_BUILD
#    mkdir '$(1)/build'
#    cd '$(1)/build' && '$(TARGET)-cmake' .. \
#        -DARMA_USE_WRAPPER=false
#    $(MAKE) -C '$(1)/build' -j '$(JOBS)' install VERBOSE=1
#
#    '$(TARGET)-g++' \
#        -W -Wall -Werror \
#        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-armadillo.exe' \
#        -larmadillo -llapack -lblas -lgfortran -lquadmath
#endef
define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DDETECT_HDF5=ON \
        -DARMA_USE_WRAPPER=ON
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    # create pkg-config file
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: $($(PKG)_DESCR)'; \
     echo 'Requires: hdf5'; \
     echo 'Libs: -larmadillo'; \
    ) > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    # compile test
#     '$(TARGET)-g++' \
#         -W -Wall -Werror \
#         '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' -larmadillo -lopenblas -lhdf5
endef
