# This file is part of MXE. See LICENSE.md for licensing information.

# partial module - included by src/cmake/CMakeLists.txt

set(TGT test-${PKG}-cmake)

enable_language(C)
add_executable(${TGT} ${CMAKE_CURRENT_LIST_DIR}/${PKG}-test.c)

find_package(BLAS REQUIRED)
target_link_libraries(${TGT} ${BLAS_LIBRARIES})
target_compile_definitions(${TGT} OPENBLAS___64BIT__=1 OPENBLAS_USE64BITINT)
install(TARGETS ${TGT} DESTINATION bin)
