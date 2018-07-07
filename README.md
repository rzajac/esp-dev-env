## ESP8266 Development Environment.

The main purpose of this project is to define development environment 
(directory structure and CMake scripts) which simplifies development and 
build process for ESP8266 micro-controller using NonOS SDK.   

## Motivation.

As my ESP8266 projects grew in number and become more complicated. I started 
having problems with code dependencies between my programs and libraries. 
At some point it become really hard to keep self contained repositories up to 
date when doing fixes or changes to libraries.

Updating to latest version of the library meant I had to go to each of the 
projects using the library and pull new changes. Even though I used 
git subtree it became cumbersome. 

The obvious solution was to create build system and directory structure which 
allows code sharing. Projects using this strategy don't have all the libraries 
as part of their repositories but instead use build system based 
on CMake to install and find them. The process of finding, configuring and 
managing the build of the software is fully delegated to CMake plus few utility
scripts which are described later in this document. 

Below I'll try to give you detail overview of how all the parts of development 
environment work - starting with directory structure. 

## Prerequisites

Building and flashing programs to ESP8266 requires following software.

```
$ sudo apt -y install libtool-bin build-essential cmake make unrar-free \
                      autoconf automake libtool gcc g++ gperf \
                      flex bison texinfo gawk ncurses-dev libexpat-dev \
                      python-dev python python-serial \
                      sed unzip help2man wget bzip2
```

Besides packages installed with `apt` `esp-open-sdk` requires Python 2.7 
to be installed. Check your version with:

```
$ python --version
Python 2.7.15 :: Anaconda, Inc.
```

and then run:

```
$ pip install pyserial
```

## Directory Structure.

Build scripts must know where to find compiler, linker, libraries, header files 
and supporting scripts. The well defined directory 
structure helps to standardize places where things are located and searched 
for. Below is the representation of the directory structure used by the 
development environment. 

    $ESPROOT
     ├── bin         
     ├── esp-cmake   
     ├── esp-open-sdk
     ├── esptool     
     ├── include     
     └── lib         

The root directory of the development environment is defined by `$ESPROOT` 
environment variable. By default it's set to `$HOME/esproot` but **it's 
recommended to define it in `.profile` file so it's set every time you 
log in**. The root of the development environment contains six directories. 
Each of the subdirectories of the `$ESPROOT` has a function described in below
table:

Directory        | Function
-----------------|---------
**bin**          | The helper binaries installed by projects (e.g. AES key generator script).
**esp-cmake**    | The CMake scripts defining paths, toolchain and utility functions. See below.
**esp-open-sdk** | The [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk) compiled as standalone (`make STANDALONE=y`). See the documentation at [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).
**esptool**      | The checkout of the [esptool](https://github.com/espressif/esptool) repository.
**include**      | The installed header files.
**lib**          | The installed libraries.

Each library must provide way to install it's archives, header files in **lib** 
and **include** directories respectively. 

## Shared CMake scripts.

Part of the development environment are also CMake scripts which provide
ESP8266 toolchain, compiler and linker configuration as well as define 
useful paths and helper functions which can be used in your CMake scripts to 
simplify configuration and build process. Below is the short description of 
the scripts located in `esp-cmake` directory. For more details see the source 
which I made sure is well documented.

The [ESP8266.bootstrap.cmake](esp-cmake/ESP8266.bootstrap.cmake) defines the 
toolchain, paths to various development environment directories as well as 
`cmake` variables which configure the installation destinations for libraries,
header files and binaries. It should be included before call to `project()` 
function (see example below).

The [ESP8266.cmake](esp-cmake/ESP8266.cmake) defines compiler and linker flags
as well as `esp_gen_exec_targets` and `esp_gen_lib` functions which help with 
target generation for executables (firmwares) and libraries.

The program which uses the CMake scripts may look like this:

```
cmake_minimum_required(VERSION 3.5)

# Bootstrap before call to project().
include("$ENV{ESPROOT}/esp-cmake/ESP8266.bootstrap.cmake")

project(esp_test C)
set(CMAKE_C_STANDARD 99)

# Find package in development environment.
find_package(esp_sdo REQUIRED)

# The directory containing global user_congih.h header file.
set(ESP_USER_CONFIG_DIR "${CMAKE_CURRENT_LIST_DIR}/include")
set(ESP_USER_CONFIG "${ESP_USER_CONFIG_DIR}/user_config.h")

# Magic.
include("${ESP_CMAKE_DIR}/ESP8266.cmake")

# Test program.
add_executable(esp_test src/main.c ${ESP_USER_CONFIG})

target_include_directories(esp_test PUBLIC
    ${esp_sdo_INCLUDE_DIRS}
    ${ESP_USER_CONFIG_DIR})

target_link_libraries(esp_test ${esp_sdo_LIBRARIES})

# Generate targets to compile and flash the test program.
esp_gen_exec_targets(esp_test)
```

This is all you have to do to compile and flash the program with commands:

```
$ mkdir build # Only out of source builds are supported.
$ cd build
$ cmake ..
$ make esp_test_flash
```

Also notice that in this example we use `esp_sdo` library which in turn 
depends on `esp_gpio` but because we use `${esp_sdo_LIBRARIES}` and 
`${esp_sdo_INCLUDE_DIRS}` we don't have to care about it because all 
libraries being part of this build system must provide CMake 
`Find<lib_name>.cmake` files which define helpful variables. See below 
for more details.

Using this build system to create / define library is even easier:

```
# The library name and its sources.
add_library(esp_gpio STATIC
    esp_gpio.c
    esp_gpio_debug.c
    include/esp_gpio.h
    include/esp_gpio_debug.h)

# Include directories.
target_include_directories(esp_gpio PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
    ${ESP_USER_CONFIG_DIR})

# Generate installation targets.
esp_gen_lib(esp_gpio)
```

This will generate targets to compile and install the library in appropriate 
places. See "*External Library Requirements*" below for more details.

## Initializing Development Environment.

To initialize development environment you may setup the directories by hand as 
shown in "*Directory Structure*" above or use `init.sh` script:

```
$ export ESPROOT=$HOME/esproot
$ wget -O - https://raw.githubusercontent.com/rzajac/esp-dev-env/master/init.sh | bash
```

which will set up the directory structure, checkout 
[esp-open-sdk](https://github.com/pfalcon/esp-open-sdk) and 
[esptool](https://github.com/espressif/esptool) repositories. 

**NOTE** - it will not make `esp-open-sdk`. You will have to do it 
yourself by changing to `$ESPROOT/esp-open-sdk` directory and issuing 
`make STANDALONE=y`. See the documentation at 
[esp-open-sdk](https://github.com/pfalcon/esp-open-sdk) (before running `make` 
make sure you have Python 2.7). 

# Installing External Libraries.

To start using any of the libraries supporting this development environment in
your project you can install them in one of two ways (I will use 
[esp-ecl](https://github.com/rzajac/esp-ecl) library as an example):

1. Clone the library repository and install it:

```
$ git clone https://github.com/rzajac/esp-ecl
$ cd esp-ecl/build
$ cmake ..
$ make install
```

2. Install library archive, header files and supporting scripts automatically 
with:

```
$ wget -O - https://raw.githubusercontent.com/rzajac/esp-ecl/master/install.sh | bash
```

which will compile the libraries being part of the 
[esp-ecl](https://github.com/rzajac/esp-ecl) repository and install all needed
files to appropriate places in `$ESPROOT`.

This makes pulling new libraries to your project very fast and easy.

## Building Hello Universe example.

```
$ cd ~/esproot/src/esp-dev-env/build
$ cmake ..
-- The C compiler identification is GNU 4.8.5
-- Check for working C compiler: /home/user/esproot/esp-open-sdk/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc
-- Check for working C compiler: /home/user/esproot/esp-open-sdk/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Configuring done
-- Generating done
-- Build files have been written to: /home/user/esproot/src/esp-dev-env/build

$ make hello_universe_flash
Scanning dependencies of target hello_universe
[ 33%] Building C object src/hello_universe/CMakeFiles/hello_universe.dir/main.c.o
[ 66%] Linking C executable hello_universe.out
esptool.py v2.4.1
Creating image for ESP8266...
[ 66%] Built target hello_universe
Scanning dependencies of target hello_universe_flash
esptool.py v2.4.1
Serial port /dev/ttyUSB0
Connecting........_
Detecting chip type... ESP8266
Chip is ESP8266EX
Features: WiFi
MAC: 5c:cf:7f:80:ce:79
Uploading stub...
Running stub...
Stub running...
Changing baud rate to 3000000
Changed.
Configuring flash size...
Auto-detected Flash size: 1MB
Compressed 27440 bytes to 20418...
Wrote 27440 bytes (20418 compressed) at 0x00000000 in 0.1 seconds (effective 1596.4 kbit/s)...
Hash of data verified.
Compressed 200356 bytes to 147317...
Wrote 200356 bytes (147317 compressed) at 0x00010000 in 1.5 seconds (effective 1046.8 kbit/s)...
Hash of data verified.

Leaving...
Hard resetting via RTS pin...
[100%] Built target hello_universe_flash
```

## External Library Requirements.

All libraries which are part of this build system **MUST**:

- Provide shell installation script (see 
[install.sh](https://github.com/rzajac/esp-ecl/blob/master/install.sh)).
- Provide installation targets which install libraries to `$ESPROOT/lib`,
header files to `$ESPROOT/include`, supporting binary files to `$ESPROOT/bin`.
- Provide CMake `Find<lib_name>.cmake` scripts and install them to 
`$ESPROOT/esp-cmake/Modules` directory.

The `Find<lib_name>.cmake` scripts must define following variables:

Variable Name           | Description
------------------------|-------------   
<lib_name>_FOUND        | System found the library.
<lib_name>_INCLUDE_DIR  | The library include directory.
<lib_name>_INCLUDE_DIRS | If library has dependencies this must be set to <lib_name>_INCLUDE_DIR [<dep1_name_INCLUDE_DIRS>, ...].
<lib_name>_LIBRARY      | The absolute path to the library.
<lib_name>_LIBRARIES    | The dependencies to link to to use the library. It will have a form of <lib_name>_LIBRARY [dep1_name_LIBRARIES, ...].

See example script: [Findesp_sdo.cmake](https://github.com/rzajac/esp-ecl/blob/master/cmake/Findesp_sdo.cmake)

## Libraries Supporting This Build System. 

- [esp_ecl](https://github.com/rzajac/esp-ecl) - Collection of small but useful libraries.
- [esp_prot](https://github.com/rzajac/esp-prot) - Low level protocol drivers (I2C, OneWire).
- [esp_drv](https://github.com/rzajac/esp-drv) - Various device drivers. 
- [esp_cmd](https://github.com/rzajac/esp-cmd) - TCP command server library. 
- [esp_det](https://github.com/rzajac/esp-det) - Detect and configure new devices on the network. 

## License.

[Apache License Version 2.0](LICENSE) unless stated otherwise.
