# MXE-MexIFace

MXE-MexIFace is a fork of [MXE](https://github.com/mxe/mxe) providing a mingw-w64 based GNU environment for
cross-compiling to Windows 64-bit targets.  This fork tracks the `mxe/master` branch, maintaining Matlab environment compatibility specifically for the [MexIFace](https://markjolah.github.io/MexIFace) package.

 Because of the Matlab MEX modules are dynamically loaded as shared libraries, they must be linked against an environment compatible with the closed-source Matlab and it's internal libraries.  MexIFace targets support of Matlab R2106b+ which is possible using a `gcc-4.9.4` toolchain.

  * [MexIFace documentation](https://markjolah.github.io/MexIFace/) The principal package using this environment.  Provides an object-oriented cross-platform C++/Matlab MEX interface and build environment.
  * [GCC standards support](https://gcc.gnu.org/projects/cxx-status.html)
     * `gcc-4.9.4` gives full C++11 and partial C++14 support and can work with Matlab R2016b+ (9.1+)
     * `gcc-6.5.0` gives full C++14 and partial C++17 support and can work with Matlab R2018a+ (9.4+)
 * Original [MXE-README.md](MXE-README.md)
 * [MXE Project](https://mxe.cc/)

## Matlab MXE Environment

This environment is deigned to provide a library of open-source libraries compatible with Matlab's built-in environment when compiling Matlab MEX files for Matlab's `win64` architecture.
  * Matlab Win64 uses the following MXE toolchain options
    * [MXE **sjlj** exception handling](https://github.com/mxe/mxe/pull/1664)
    * [MXE **posix** threading](https://github.com/mxe/mxe/pull/2263)
    * [MXE **shared** libraries](https://mxe.cc/#introduction)

Therefore, Matlab MEX files for `win64` arch should use `MXE` target toolchain notation:

    MXE_TARGETS := x86_64-w64-mingw32.shared.posix.sjlj

## Default MexIFace Package List
The following packages are included by default in [`settings.mk`](settings.mk), which can easily be extended as needed.

 * **pthreads** - Required for matlab MEX
 * [**boost**](https://www.boost.org/) - Essential C++ component.
 * [**armadillo**](http://arma.sourceforge.net/docs.html) - C++ array and linear-algebra library with BLAS/LAPACK integration
 * [**zlib**](https://www.zlib.net/) - Common dependency
 * [**googletest**](https://github.com/google/googletest) - Google's unit test framework

### Blas/Lapack 64-bit support

Matlab includes internal BLAS and LAPACK libraries that are compiled with 64-bit integer indexing.  These libraries are incompatible with the more common 32-bit integer indexed BLAS/LAPACK libraries such as the default MXE `src/blas.mk` and `src/lapack.mk`.  To enable combined 32-bit and 64-bit support for BLAS and LAPACK, we provide the following MXE packages which are used in-place of standard `blas` and `lapack`:

 * **blas_lapack_reference** - 32-bit integer BLAS/LAPACK using [NetLib reference sources](http://www.netlib.org/lapack/)
 * **blas_lapack_reference_int64** - 64-bit integer reference BLAS/LAPACK [NetLib reference sources](http://www.netlib.org/lapack/)

These packages modify the default [`pkg-config` files](https://www.freedesktop.org/wiki/Software/pkg-config/) providing the following `.pc` files at `usr/x86_64-w64-mingw32.shared.posix.sjlj/lib/pkgconfig/`:
 * `blas-reference.pc` - INT32 NetLib blas
 * `blas-reference-int64.pc` - INT64 NetLib BLAS
 * `lapack-reference.pc` - INT32 NetLib Lapack
 * `lapack-reference-int64.pc` - INT64 NetLib Lapack

### Specialized libraries

 * [**libics**](https://svi-opensource.github.io/libics/) - Scientific imaging library
 * [**trng**](https://www.numbercrunch.de/trng/) - Parallel random number generator engines

## Branches

 * `master` - Environment for Win64 gcc-4.9.x and later based Matlab systems.  Suitable for R2016b+ (9.1+)
 * `gcc-6.5` - Environment for Win64 gcc-6.x and later based Matlab systems.  Suitable for R2018a+ (9.4+).


