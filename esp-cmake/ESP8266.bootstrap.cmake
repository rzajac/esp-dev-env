# Copyright 2017 Rafal Zajac <rzajac@gmail.com>.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# Make sure ESPROOT environemt varaiabnle is set.
if (NOT EXISTS $ENV{ESPROOT})
  message(FATAL_ERROR "The ESPROOT environment varaible is not set.")
endif()

# Prevent in source builds.
if ( ${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR} )
  message(FATAL_ERROR "In-source builds not allowed. Run cmake -H . -B build" )
endif()

# Set basic paths.
set(ESP_CMAKE_DIR "$ENV{ESPROOT}/esp-cmake")
set(ESP_OPEN_SDK_DIR "$ENV{ESPROOT}/esp-open-sdk")
set(ESP_SDK_DIR "${ESP_OPEN_SDK_DIR}/sdk")
set(ESP_SDK_LIB_DIR "${ESP_SDK_DIR}/lib")
set(ESP_TOOLCHAIN_DIR "${ESP_OPEN_SDK_DIR}/xtensa-lx106-elf")
set(ESP_TOOLCHAIN_BIN_DIR "${ESP_TOOLCHAIN_DIR}/bin")
set(ESPTOOL_PATH "$ENV{ESPROOT}/esptool/esptool.py")

# Install paths.
set(CMAKE_INSTALL_PREFIX "$ENV{ESPROOT}" CACHE PATH "install prefix" FORCE)
set(CMAKE_INSTALL_LIBDIR "lib")
set(CMAKE_INSTALL_INCLUDEDIR "include")

# Setup toolchain.
set(CMAKE_TOOLCHAIN_FILE "${ESP_CMAKE_DIR}/toolchain.ESP8266.cmake")
mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

# Programming port.
set(ESP_PORT "/dev/ttyUSB0")

# Default programming speed.
set(ESP_BAUD 3000000)

# Firmware file names.
set(ESP_FW1 "0x00000")
set(ESP_FW2 "0x10000")

