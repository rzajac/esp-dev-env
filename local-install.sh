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

# Copies (overwrites) esp-cmake to ${ESPROOT}.

if [ "${ESPROOT}" == "" ]; then ESPROOT=$HOME/esproot; fi
if ! [ -d "${ESPROOT}" ]; then mkdir -p ${ESPROOT}; fi
echo "Using ${ESPROOT} as ESPROOT."

ESP_CMAKE_DST_DIR=${ESPROOT}/esp-cmake

echo "Installing ESP8266 CMake scripts to ${ESP_CMAKE_DST_DIR}"
rm -rf ${ESP_CMAKE_DST_DIR}
cp -R ./esp-cmake ${ESPROOT}
if [ $? != 0 ]; then
    echo "Error: Installing esp-cmake failed!"
    exit 1
fi

exit 0
