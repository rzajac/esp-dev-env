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


# Set path to CMake modules directory.
get_filename_component(_ownDir "${CMAKE_CURRENT_LIST_FILE}" PATH)
set(CMAKE_MODULE_PATH "${_ownDir}/Modules" ${CMAKE_MODULE_PATH} "${CMAKE_ROOT}/Modules")

# Tee target platform description.
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ESP8266)

# Setup compiler, linker, ...
set(CMAKE_C_COMPILER "${ESP_TOOLCHAIN_BIN_DIR}/xtensa-lx106-elf-gcc")

# The location of target environment.
set(CMAKE_FIND_ROOT_PATH "${ESP_TOOLCHAIN_DIR}" "${ESP_SDK_DIR}" "$ENV{ESPROOT}")

# Search programs in the host environment.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search headers and libraries only in target environment.
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
