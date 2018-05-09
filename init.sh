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

# Script for initializing ESP8266 development environment.

echo "Initializing up ESP8266 development environment."
if [ "${ESPROOT}" == "" ]; then export ESPROOT=$HOME/esproot; fi
if ! [ -d "${ESPROOT}" ]; then mkdir -p ${ESPROOT}; fi
echo "Using ${ESPROOT} as ESPROOT."

echo "export ESPROOT=$ESPROOT" >> ~/.profile
echo "export PATH=\$ESPROOT/esp-open-sdk/xtensa-lx106-elf/bin:\$PATH" >> ~/.profile

(
    cd ${ESPROOT}
    mkdir lib include bin

    wget -O - https://raw.githubusercontent.com/rzajac/esp-dev-env/master/install.sh | bash
    if [ $? != 0 ]; then exit 1; fi

    git clone https://github.com/espressif/esptool.git
    if [ $? != 0 ]; then exit 1; fi

    git clone --recursive https://github.com/pfalcon/esp-open-sdk.git
    if [ $? != 0 ]; then exit 1; fi
)

echo
echo "Directory structure and all the necessary software has been checked out."
echo "Before you can compile and flash ESP8266 programs you must build "
echo "standalone version of esp-open-sdk. Follow instructions at"
echo "https://github.com/pfalcon/esp-open-sdk."
echo "Good luck!"
echo
