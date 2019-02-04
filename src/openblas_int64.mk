# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := openblas_int64
$(PKG)_WEBSITE  := https://www.openblas.net/
$(PKG)_DESCR    := OpenBLAS
$(PKG)_IGNORE   = $(openblas_IGNORE)
$(PKG)_VERSION  = $(openblas_VERSION)
$(PKG)_CHECKSUM = $(openblas_CHECKSUM)
$(PKG)_GH_CONF  = $(openblas_GH_CONF)
$(PKG)_FILE     = $(openblas_FILE)
$(PKG)_URL      = $(openblas_URL)
$(PKG)_DEPS     := cc pthreads
$(PKG)_PCNAME   := openblas-int64
# openblas has it's own optimised versions of netlib lapack that
# it bundles into -lopenblas so won't conflict with those libs
# headers do conflict so install to separate directory

$(PKG)_MAKE_OPTS = \
        PREFIX='$(PREFIX)/$(TARGET)' \
        OPENBLAS_INCLUDE_DIR='$(PREFIX)/$(TARGET)/include/openblas' \
        CROSS_SUFFIX='$(TARGET)-' \
        FC='$(TARGET)-gfortran' \
        CC='$(TARGET)-gcc' \
        HOSTCC='$(BUILD_CC)' \
        MAKE_NB_JOBS=-1 \
        CROSS=1 \
        BUILD_RELAPACK=1 \
        USE_THREAD=0 \
        USE_OPENMP=0 \
        NUM_THREADS=$(call LIST_NMAX, 2 $(NPROCS)) \
        TARGET=Nehalem \
        DYNAMIC_ARCH=1 \
        INTERFACE64=1 \
        ARCH=$(strip \
             $(if $(findstring x86_64,$(TARGET)),x86_64,\
             $(if $(findstring i686,$(TARGET)),x86))) \
        BINARY=$(BITS) \
        $(if $(BUILD_STATIC),NO_SHARED=1) \
        $(if $(BUILD_SHARED),NO_STATIC=1) \
        EXTRALIB="`'$(TARGET)-pkg-config' --libs pthreads` -fopenmp -lgfortran -lquadmath"

define $(PKG)_BUILD
    $(MAKE) -C '$(SOURCE_DIR)' -j '$(JOBS)' $($(PKG)_MAKE_OPTS)
    $(MAKE) -C '$(SOURCE_DIR)' -j 1 install $($(PKG)_MAKE_OPTS)

    '$(TARGET)-gcc' \
        -W -Wall -Werror \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' --cflags --libs $(PKG)`

    # set BLA_VENDOR and -fopenmp to find openblas
    mkdir '$(BUILD_DIR).test-cmake'
    cd '$(BUILD_DIR).test-cmake' && '$(TARGET)-cmake' \
        -DPKG=$(PKG) \
        -DBLA_VENDOR=OpenBLAS \
        -DCMAKE_C_FLAGS=-fopenmp \
        '$(PWD)/src/cmake/test'
    $(MAKE) -C '$(BUILD_DIR).test-cmake' -j 1 install
endef
