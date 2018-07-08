#!/usr/bin/env bash

# Copyright 2018 Rafal Zajac <rzajac@gmail.com>.
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

# ESP8266 CMake scripts installer.
#
# Installer expects that esp-open-sdk is installed and compiled
# as standalone version at $ESPROOT/esp-open-sdk

ESP_CMAKE_REPO="ssh://github.com/rzajac/esp-dev-env"

# No modifications below this comment unless you know what you're doing.

# Check / set ESPROOT.
if [ "${ESPROOT}" == "" ]; then ESPROOT=$HOME/esproot; fi
if ! [ -d "${ESPROOT}" ]; then mkdir -p ${ESPROOT}; fi
echo "Using ${ESPROOT} as ESPROOT"

ESP_ENV_DST_DIR=${ESPROOT}/src/esp-dev-env
ESP_CMAKE_DST_DIR=${ESPROOT}/esp-cmake

echo "Cloning ${ESP_CMAKE_REPO} to ${ESP_ENV_DST_DIR}."
if [ -d "${ESP_ENV_DST_DIR}" ]; then
    echo "Directory ${ESP_ENV_DST_DIR} already exists. Will git reset."
    (cd ${ESP_ENV_DST_DIR} && git fetch && git reset --hard origin master)
else
    git clone ${ESP_CMAKE_REPO} ${ESP_ENV_DST_DIR}
    if [ $? != 0 ]; then
        echo "Error: Cloning ${ESP_CMAKE_REPO} failed!"
        exit 1
    fi
fi

echo "Creating symlink ${ESP_CMAKE_DST_DIR}"
rm -rf ${ESP_CMAKE_DST_DIR}
ln -s ${ESP_ENV_DST_DIR}/esp-cmake ${ESP_CMAKE_DST_DIR}
ln -s ${ESP_ENV_DST_DIR}/src/include/esp.h ${ESPROOT}/include/esp.h
ln -s ${ESP_ENV_DST_DIR}/src/include/user_config.h ${ESPROOT}/include/user_config.h
cp ${ESP_ENV_DST_DIR}/lib-install.sh  ${ESPROOT}/bin

exit 0
