# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := blas_reference
$(PKG)_WEBSITE  := https://www.netlib.org/blas/
$(PKG)_DESCR    := Reference BLAS (Basic Linear Algebra Subprograms)
$(PKG)_IGNORE    = $(lapack_reference_IGNORE)
$(PKG)_VERSION   = $(lapack_reference_VERSION)
$(PKG)_CHECKSUM  = $(lapack_reference_CHECKSUM)
$(PKG)_SUBDIR    = $(lapack_reference_SUBDIR)
$(PKG)_FILE      = $(lapack_reference_FILE)
$(PKG)_URL       = $(lapack_reference_URL)
$(PKG)_DEPS     := cc
$(PKG)_PROFNAME = refblas
$(PKG)_LIBNAME = refblas

define $(PKG)_UPDATE
    echo $(lapack_VERSION)
endef

define $(PKG)_BUILD
	cd '$(SOURCE_DIR)' && sed -i -e 's:\([^xc]\)blas:\1\$${LIBNAME}:g' -e '/PROPERTIES/s:blas:\$${LIBNAME}:g' CMakeLists.txt BLAS/SRC/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i -e '/Name: /s:blas:@PROFNAME@:' -e 's:-lblas:-l@LIBNAME@:g' BLAS/blas.pc.in || die
	cd '$(SOURCE_DIR)' && sed -i -e 's:blas):\$${LIBNAME}):' BLAS/TESTING/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i -e "s:BINARY_DIR}/blas:BINARY_DIR}/\$${PROFNAME}:" BLAS/CMakeLists.txt || die

	cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
		-DCMAKE_AR='$(PREFIX)/bin/$(TARGET)-ar' \
		-DPROFNAME=$($(PKG)_PROFNAME) \
		-DLIBNAME=$($(PKG)_LIBNAME) \
		-DCMAKE_RANLIB='$(PREFIX)/bin/$(TARGET)-ranlib' \
		-DCBLAS=OFF \
		-DLAPACKE=OFF
	$(MAKE) -C '$(BUILD_DIR)/BLAS' -j '$(JOBS)'
	$(MAKE) -C '$(BUILD_DIR)/BLAS' -j 1 install

	'$(TARGET)-gfortran' \
		-W -Wall -O2 \
		'$(SOURCE_DIR)/BLAS/TESTING/dblat1.f' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
		`'$(TARGET)-pkg-config' $($(PKG)_PROFNAME) --cflags --libs`
endef
