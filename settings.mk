JOBS := 8
MXE_TARGETS := x86_64-w64-mingw32.shared
LOCAL_PKG_LIST := libidn boost pthreads armadillo zlib libics trng gsl openblas lapack googletest
override MXE_PLUGIN_DIRS += plugins/gcc4
local-pkg-list: $(LOCAL_PKG_LIST)
