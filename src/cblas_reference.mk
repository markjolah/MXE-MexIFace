# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := cblas_reference
$(PKG)_WEBSITE  := https://www.netlib.org/blas/
$(PKG)_DESCR    := C interface to Reference BLAS
$(PKG)_IGNORE    = $(lapack_reference_IGNORE)
$(PKG)_VERSION   = $(lapack_reference_VERSION)
$(PKG)_CHECKSUM  = $(lapack_reference_CHECKSUM)
$(PKG)_SUBDIR    = $(lapack_reference_SUBDIR)
$(PKG)_FILE      = $(lapack_reference_FILE)
$(PKG)_URL       = $(lapack_reference_URL)
$(PKG)_DEPS     := cc blas_reference
$(PKG)_PCNAME := refcblas
$(PKG)_LIBNAME := refcblas
$(PKG)_BLAS_LIBNAME := refblas
$(PKG)_BLAS_PCNAME := refblas

define $(PKG)_UPDATE
    echo $(lapack_VERSION)
endef

define $(PKG)_BUILD
	cd '$(SOURCE_DIR)' && sed -i \
		-e 's:cblas\([ \)]\):\$${LIBNAME}\1:g'\
		-e '/ALL_TARGETS/s:cblas):\$${LIBNAME}):' \
		-e '/_librar/s:cblas:\$${LIBNAME}:' \
		CMakeLists.txt \
		CBLAS/src/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e 's/cblas PROPERTIES/\$${LIBNAME} PROPERTIES/' \
		-e 's/cblas PUBLIC/\$${LIBNAME} PUBLIC/' \
		CBLAS/src/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e 's:/CMAKE/:/cmake/:g' \
		CBLAS/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e '/Name: /s:cblas:@PCNAME@:' \
		-e '/Requires\.private: /s:blas:$($(PKG)_BLAS_PCNAME):' \
		-e 's:-lcblas:-l@LIBNAME@:g' \
		 CBLAS/cblas.pc.in || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e 's:cblas):\$${LIBNAME}):' \
		CBLAS/testing/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e 's:BINARY_DIR}/cblas:BINARY_DIR}/\$${PCNAME}:' \
		-e '/install/s:include):include/\$${PCNAME}):g' \
		CBLAS/CMakeLists.txt || die
	cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
		-DCMAKE_AR='$(PREFIX)/bin/$(TARGET)-ar' \
		-DCMAKE_RANLIB='$(PREFIX)/bin/$(TARGET)-ranlib' \
		-DPCNAME=$($(PKG)_PCNAME) \
		-DLIBNAME=$($(PKG)_LIBNAME) \
		-DCBLAS=ON \
		-DLAPACKE=OFF \
		-DBLAS_LIBRARIES=$($(PKG)_BLAS_LIBNAME)
	$(MAKE) -C '$(BUILD_DIR)/CBLAS' -j '$(JOBS)'
	$(MAKE) -C '$(BUILD_DIR)/CBLAS' -j 1 install
	#Make default in pkg-config

    # if blas routines are used directly, add to pkg-config call
    '$(TARGET)-gcc' \
        -W -Wall -ansi \
        '$(SOURCE_DIR)/CBLAS/examples/cblas_example1.c' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $($(PKG)_PCNAME) --cflags --libs`
endef
