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


# Include directories.
include_directories(${ESP_SDK_DIR}/include)

# Setup compiler and linkert flags.
set(ESP_SDK_LD_SCRIPT ${ESP_SDK_DIR}/ld/eagle.app.v6.ld)

set(CMAKE_C_FLAGS "-Os -Wall -Wno-unused-function -Wpointer-arith -Wundef -Werror -Wl,-EL")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-inline-functions -nostdlib")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mlongcalls -mtext-section-literals")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__ets__ -DICACHE_FLASH")

if($ENV{DEBUG_ON})
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DDEBUG_ON")
endif()

set(CMAKE_EXE_LINKER_FLAGS "-L${ESP_SDK_LIB_DIR} -T${ESP_SDK_LD_SCRIPT}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--no-check-sections")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -u call_user_start -Wl,-static -O2")

set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS>")
set(CMAKE_C_LINK_EXECUTABLE "${CMAKE_C_LINK_EXECUTABLE} -o <TARGET>")
set(CMAKE_C_LINK_EXECUTABLE "${CMAKE_C_LINK_EXECUTABLE} -Wl,--start-group <OBJECTS> <LINK_LIBRARIES> -Wl,--end-group")

# Those libraries will be linked into every executable.
set(CMAKE_C_STANDARD_LIBRARIES "-lc -lgcc -lphy -lpp -lnet80211 -llwip -lwpa -lmain")

# Genetare targets for creating firmwares and flashing.
function(esp_gen_exec_targets TARGET_NAME)
  set(ESP_TARGET_FW1 "${CMAKE_CURRENT_BINARY_DIR}/${ESP_FW1}.bin")
  set(ESP_TARGET_FW2 "${CMAKE_CURRENT_BINARY_DIR}/${ESP_FW2}.bin")

  # Create ESP8266 binary files.
  add_custom_command(
    OUTPUT
      ${ESP_TARGET_FW1} ${ESP_TARGET_FW2}
    COMMAND
      ${ESPTOOL_PATH} elf2image $<TARGET_FILE:${TARGET_NAME}> -o ${CMAKE_CURRENT_BINARY_DIR}/
    DEPENDS
      ${TARGET_NAME}
  )

  add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
      COMMAND
        ${ESPTOOL_PATH} elf2image $<TARGET_FILE:${TARGET_NAME}> -o ${CMAKE_CURRENT_BINARY_DIR}/
      BYPRODUCTS
        ${ESP_TARGET_FW1} ${ESP_TARGET_FW2}
  )

  # Flash binary files to the device.
  add_custom_target(${TARGET_NAME}_flash
    COMMAND
      ${ESPTOOL_PATH} -p ${ESP_PORT} -b ${ESP_BAUD} write_flash ${ESP_FW1} ${ESP_TARGET_FW1} ${ESP_FW2} ${ESP_TARGET_FW2}
    DEPENDS
      ${ESP_TARGET_FW1} ${ESP_TARGET_FW2}
  )
endfunction()

# Function generates library install rules.
function(esp_gen_lib TARGET_NAME)
  install(TARGETS ${TARGET_NAME}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

  install(FILES "Find${TARGET_NAME}.cmake" DESTINATION "${ESP_MODULE_DIR}")

  add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
      COMMAND
        ${ESP_TOOLCHAIN_BIN_DIR}/xtensa-lx106-elf-strip --strip-unneeded $<TARGET_FILE:${TARGET_NAME}>
  )
endfunction()
