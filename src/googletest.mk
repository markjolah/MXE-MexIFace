PKG             := googletest
$(PKG)_WEBSITE  := https://github.com/google/googletest
$(PKG)_DESCR    := googletest and googlemock
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.8.1
$(PKG)_CHECKSUM := 9bf1fe5182a604b4135edc1a425ae356c9ad15e9b23f9f12a02e80184c3a249c
$(PKG)_GH_CONF  := google/googletest/tags, release-
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(1)' \
        -DBUILD_STATIC_LIBS=$(CMAKE_STATIC_BOOL) \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -Dgtest_build_samples=ON

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
    $(INSTALL) -m755 '$(BUILD_DIR)/googlemock/gtest/sample1_unittest.exe' '$(PREFIX)/$(TARGET)/bin/test-googletest.exe'
endef
