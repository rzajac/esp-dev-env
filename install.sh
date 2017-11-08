#!/usr/bin/env bash

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

# ESP8266 CMake scripts installer.
#
# Installer expects that esp-open-sdk is installed and compiled
# as standalone version at $ESPROOT/esp-open-sdk

ESP_CMAKE_REPO="https://github.com/rzajac/esp-dev-env"

# No modifications below this comment unless you know what you're doing.

# Remove temporary directory.
function rm_tmp() {
    echo "Removing ${TMP_DIR}"
    rm -rf ${TMP_DIR}
}

# Check / set ESPROOT.
if [ "${ESPROOT}" == "" ]; then ESPROOT=$HOME/esproot; fi
if ! [ -d "${ESPROOT}" ]; then mkdir -p ${ESPROOT}; fi
echo "Using ${ESPROOT} as ESPROOT"

TMP_DIR=`mktemp -d`
ESP_CMAKE_DST_DIR=${ESPROOT}/esp-cmake

if [ -d "${ESP_CMAKE_DST_DIR}" ]; then
    echo "Directory ${ESP_CMAKE_DST_DIR} already exists. Will overwrite."
fi

echo "Installing ESP8266 CMake scripts."
echo "Cloning ${ESP_CMAKE_REPO} to temporary directory."

git clone ${ESP_CMAKE_REPO} ${TMP_DIR}
if [ $? != 0 ]; then
    echo "Error: Cloning ${ESP_CMAKE_REPO} failed!"
    rm_tmp
    exit 1
fi

echo "Installing ESP8266 CMake scripts to ${ESP_CMAKE_DST_DIR}"
rm -rf ${ESP_CMAKE_DST_DIR}
cp -R ${TMP_DIR}/esp-cmake ${ESPROOT}
if [ $? != 0 ]; then
    echo "Error: Installing esp-cmake failed!"
    rm_tmp
    exit 1
fi

exit 0
