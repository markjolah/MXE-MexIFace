# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := lapack_reference
$(PKG)_WEBSITE  := https://www.netlib.org/lapack/
$(PKG)_DESCR    := Reference LAPACK — Linear Algebra PACKage
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.8.0
$(PKG)_CHECKSUM := deb22cc4a6120bff72621155a9917f485f96ef8319ac074a7afbc68aab88bcf6
$(PKG)_GH_CONF  := Reference-LAPACK/lapack/tags,v
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc blas_reference
$(PKG)_PCNAME := reflapack
$(PKG)_LIBNAME := reflapack
$(PKG)_BLAS_LIBNAME := refblas
$(PKG)_BLAS_PCNAME := refblas
$(PKG)_CBLAS_PCNAME := refcblas
$(PKG)_LAPACKE_PCNAME := reflapacke
$(PKG)_LAPACKE_LIBNAME := reflapacke

define $(PKG)_BUILD
	cd '$(SOURCE_DIR)' && sed \
		-e 's:BINARY_DIR}/lapack.pc:BINARY_DIR}/\$${PCNAME}.pc:' \
		-e '/ALL_TARGETS/s:lapack):\$${LIBNAME}):' \
		-e '/LAPACK_LIBRARIES/s:lapack:\$${LIBNAME}:g' \
		-i CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e 's:(lapack:(\$${LIBNAME}:g' \
		-e '/PROPERTIES/s:lapack:\$${LIBNAME}:g' \
		SRC/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e '/Name: /s:lapack:@PCNAME@:' \
		-e 's:-llapack:-l@LIBNAME@:g' \
		-e '/Requires: /s:blas:@BLAS_REQUIRES@\nFflags\: ${LAPACK_PKGCONFIG_FFLAGS}:' \
		lapack.pc.in || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e 's:BINARY_DIR}/lapacke.pc:BINARY_DIR}/$($(PKG)_LAPACKE_PCNAME).pc:' \
		-e '/export/s:lapacke:$($(PKG)_LAPACKE_LIBNAME):g' \
		-e '/ALL_TARGETS/s:lapacke):$($(PKG)_LAPACKE_LIBNAME)):' \
		-e '/LAPACK_LIBRARIES/s:lapacke:$($(PKG)_LAPACKE_LIBNAME):g' \
		LAPACKE/CMakeLists.txt \
		CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e '/librar/s:(lapacke:($($(PKG)_LAPACKE_LIBNAME):g' \
		-e '/librar/s:(lapacke:($($(PKG)_LAPACKE_LIBNAME):g' \
		-e 's/lapacke PROPERTIES/$($(PKG)_LAPACKE_LIBNAME) PROPERTIES/' \
		-e 's/lapacke PUBLIC/$($(PKG)_LAPACKE_LIBNAME) PUBLIC/' \
		LAPACKE/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e '/librar/s:lapacke:$($(PKG)_LAPACKE_LIBNAME):g' \
		LAPACKE/example/CMakeLists.txt || die
	cd '$(SOURCE_DIR)' && sed -i \
		-e "s:-llapacke:-lreflapacke:g" \
		-e "/Requires\.private: /s:lapack:$($(PKG)_PCNAME):" \
		LAPACKE/lapacke.pc.in || die
	cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
		-DCMAKE_AR='$(PREFIX)/bin/$(TARGET)-ar' \
		-DCMAKE_RANLIB='$(PREFIX)/bin/$(TARGET)-ranlib' \
		-DBLAS_LIBRARIES=$($(PKG)_BLAS_LIBNAME) \
		-DPCNAME=$($(PKG)_PCNAME) \
		-DLIBNAME=$($(PKG)_LIBNAME) \
		-DCBLAS=OFF \
		-DLAPACKE=ON
	$(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
	$(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # if blas/cblas routines are used directly, add to pkg-config call
    '$(TARGET)-gfortran' \
        -W -Wall '$(PWD)/src/$(PKG)-test.f' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config'  $($(PKG)_PCNAME)  --libs` \
        `'$(TARGET)-pkg-config'  $($(PKG)_PCNAME) --variable=fflags`

    '$(TARGET)-gcc' \
        -W -Wall  \
        '$(PWD)/src/$(PKG)-test.c' -o '$(PREFIX)/$(TARGET)/bin/test-lapacke_reference.exe' \
        `'$(TARGET)-pkg-config' $($(PKG)_LAPACKE_PCNAME) $($(PKG)_CBLAS_PCNAME)  --cflags --libs`

endef
