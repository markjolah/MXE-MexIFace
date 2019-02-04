# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := blas_reference_int64
$(PKG)_WEBSITE  := https://www.netlib.org/blas/
$(PKG)_DESCR    := Reference BLAS (Basic Linear Algebra Subprograms)
$(PKG)_IGNORE    = $(lapack_reference_IGNORE)
$(PKG)_VERSION   = $(lapack_reference_VERSION)
$(PKG)_CHECKSUM  = $(lapack_reference_CHECKSUM)
$(PKG)_SUBDIR    = $(lapack_reference_SUBDIR)
$(PKG)_FILE      = $(lapack_reference_FILE)
$(PKG)_URL       = $(lapack_reference_URL)
$(PKG)_DEPS     := cc
$(PKG)_PCNAME := refblas-int64
$(PKG)_LIBNAME := refblas_int64
$(PKG)_FFLAGS := -fdefault-integer-8

define $(PKG)_UPDATE
    echo $(lapack_VERSION)
endef

define $(PKG)_BUILD
	cd '$(SOURCE_DIR)' && sed -i -e 's:\([^xc]\)blas:\1\$${LIBNAME}:g' -e '/PROPERTIES/s:blas:\$${LIBNAME}:g' CMakeLists.txt BLAS/SRC/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i -e '/Name: /s:blas:@PCNAME@:' \
				-e 's/-lblas/-l@LIBNAME@\nFFLAGS=@LAPACK_PKGCONFIG_FFLAGS@/' \
				BLAS/blas.pc.in || die
	cd '$(SOURCE_DIR)' && sed -i -e 's:blas):\$${LIBNAME}):' BLAS/TESTING/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i -e "s:BINARY_DIR}/blas:BINARY_DIR}/\$${PCNAME}:" BLAS/CMakeLists.txt || die

	cd '$(BUILD_DIR)' &&  $(TARGET)-cmake -E env FFLAGS='$($(PKG)_FFLAGS)' $(TARGET)-cmake '$(SOURCE_DIR)' \
		-DCMAKE_AR='$(PREFIX)/bin/$(TARGET)-ar' \
		-DCMAKE_RANLIB='$(PREFIX)/bin/$(TARGET)-ranlib' \
		-DPCNAME=$($(PKG)_PCNAME) \
		-DLIBNAME=$($(PKG)_LIBNAME) \
		-DCBLAS=OFF \
		-DLAPACKE=OFF \
		-DLAPACK_PKGCONFIG_FFLAGS='$($(PKG)_FFLAGS)' \
		-DCMAKE_Fortran_FLAGS=$($(PKG)_FFLAGS)
	VERBOSE=1 $(MAKE) -C '$(BUILD_DIR)/BLAS' -j '$(JOBS)'
	$(MAKE) -C '$(BUILD_DIR)/BLAS' -j 1 install

	'$(TARGET)-gfortran' \
		-W -Wall -O2  \
		'$(SOURCE_DIR)/BLAS/TESTING/dblat1.f' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
		`'$(TARGET)-pkg-config' $($(PKG)_PCNAME) --variable=FFLAGS` \
		`'$(TARGET)-pkg-config' $($(PKG)_PCNAME) --libs`
endef
