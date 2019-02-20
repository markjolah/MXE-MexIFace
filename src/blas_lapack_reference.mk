
# Combined netlib BLAS and LAPACK reference installation with 32-bit integers
# Mark J. Olah (mjo@cs.unm DOT edu)
# 2019

PKG             := blas_lapack_reference
$(PKG)_WEBSITE  := https://www.netlib.org/blas/
$(PKG)_DESCR    := Reference BLAS and LAPACK
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.8.0
$(PKG)_CHECKSUM := deb22cc4a6120bff72621155a9917f485f96ef8319ac074a7afbc68aab88bcf6
$(PKG)_GH_CONF  := Reference-LAPACK/lapack/tags,v
$(PKG)_FILE     := lapack_reference-$($(PKG)_VERSION).tar.gz
# $(PKG)_SUBDIR    = $(lapack_reference_SUBDIR)
# $(PKG)_URL       = $(lapack_reference_URL)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    echo $(lapack_VERSION)
endef

define $(PKG)_BUILD
	sed -i -e 's:blas PROPERTIES:blas PROPERTIES OUTPUT_NAME blas_reference:' $(SOURCE_DIR)/BLAS/SRC/CMakeLists.txt || die
	sed -i -e 's:lapack PROPERTIES:lapack PROPERTIES OUTPUT_NAME lapack_reference:' $(SOURCE_DIR)/SRC/CMakeLists.txt || die
	cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
		-DCMAKE_AR='$(PREFIX)/bin/$(TARGET)-ar' \
		-DCMAKE_RANLIB='$(PREFIX)/bin/$(TARGET)-ranlib' \
		-DCBLAS=OFF \
		-DLAPACKE=OFF
# 		-DCMAKE_Fortran_FLAGS="-fdefault-integer-4"
	$(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
	$(MAKE) -C '$(BUILD_DIR)' -j 1 install

	mv $(PREFIX)/$(TARGET)/lib/pkgconfig/blas.pc $(PREFIX)/$(TARGET)/lib/pkgconfig/blas-reference.pc
	mv $(PREFIX)/$(TARGET)/lib/pkgconfig/lapack.pc $(PREFIX)/$(TARGET)/lib/pkgconfig/lapack-reference.pc
	sed -i -e 's:-lblas:-lblas_reference:' $(PREFIX)/$(TARGET)/lib/pkgconfig/blas-reference.pc
	sed -i -e 's:-llapack:-llapack_reference:' -e 's:blas:blas-reference:' $(PREFIX)/$(TARGET)/lib/pkgconfig/lapack-reference.pc

# 	'$(TARGET)-gfortran' \
# 		-W -Wall -O2 \
# 		'$(SOURCE_DIR)/BLAS/TESTING/dblat1.f' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
# 		`'$(TARGET)-pkg-config' $($(PKG)_PROFNAME) --cflags --libs`
endef
