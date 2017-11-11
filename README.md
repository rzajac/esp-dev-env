## ESP8266 Development Environment.

The main purpose of this project is to define development environment 
(directory structure) and provide CMake scripts which other projects 
can use to simplify build process. 

## Motivation.

As my ESP8266 projects grew in number I started having problems with code 
dependencies between my programs and libraries. At some point it become 
really hard to keep self contained repositories up to date when doing 
fixes or changes to libraries.

For example updating to latest version of the library meant I had to go to 
each of my projects depending on that library and pull new changes. Even 
though I used git subtree it became cumbersome on the long run. 

The obvious solution was to create consistent build system and directory 
structure which allows code sharing between projects. Projects using this
strategy do not have all the libraries as part of their repositories but 
know where to find them on the system. The process of finding, 
configuring and managing the build of the software is delegated to CMake. 

Below I'll try to give you a detail overview this development environment.
Starting with directory structure. 

## Directory Structure.

To simplify building more complicated programs the build scripts must know
where to find libraries, header files, compiler, linker and supporting scripts.
The well defined directory structure helps to standardize places where things 
are located:

    $ESPROOT
    ├── bin          <-- helper shell scripts
    ├── esp-cmake    <-- cmake scripts
    ├── esp-open-sdk <-- the clone of esp-open-sdk
    ├── esptool      <-- the esptool repository clone
    ├── include      <-- the library include files
    └── lib          <-- the libraries

The root directory of the development environment is defined by `$ESPROOT` 
environment variable. By default it's set to `$HOME/esproot` but it's 
recommended to define it in `.profile` file so it's set every time you 
log in. The root of the development environment contains six directories:  

- **bin** - Each of the projects may install here helper binaries (e.g. AES key
generator script).
- **esp-cmake** - The CMake script defining paths, toolchain and utility functions. 
See below.
- **esp-open-sdk** - The [esp-open-sdk](git clone https://github.com/pfalcon/esp-open-sdk)
compiled as standalone (`make STANDALONE=y`). See the documentation at 
[esp-open-sdk](git clone https://github.com/pfalcon/esp-open-sdk).
- **esptool** - The checkout of the [esptool](https://github.com/espressif/esptool).
- **include** - The library header files.
- **lib** - The compiled libraries are being installed here.

Each library project that is part of this system must provide way to install
it's libraries and header files in **lib** and **include** directories. 

## Shared CMake scripts.

Part of the development environment are shared CMake scripts which provide
ESP8266 toolchain, compiler, linker configuration as well as path and 
helper function definitions:

The [ESP8266.bootstrap.cmake](esp-cmake/ESP8266.bootstrap.cmake) defines the 
toolchain to use, paths to various development environment directories and 
where to install libraries, header files and binaries so other programs know
how to find them. It should be included before call to `project()` function.

The [ESP8266.cmake](esp-cmake/ESP8266.cmake) defines compiler and linker flags
as well as `esp_gen_exec_targets` and `esp_gen_lib` functions.

The example of the program which this build system may look like this:

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

In this example the `esp_sdo` library depends on `esp_gpio` library but because we 
use `${esp_sdo_LIBRARIES}` and `${esp_sdo_INCLUDE_DIRS}` we don't have to care about it.

Defining the library is even easier:

```
add_library(esp_gpio STATIC
    esp_gpio.c
    esp_gpio_debug.c
    include/esp_gpio.h
    include/esp_gpio_debug.h)

target_include_directories(esp_gpio PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
    ${ESP_USER_CONFIG_DIR})

# Generate installation targets.
esp_gen_lib(esp_gpio ${ESP_CMAKE_FIND_DIR})
```

## Initializing Development Environment.

To initialize development environment for the first time you may setup the
directories by hand as shown above or use `init.sh` script:

```
$ wget -O - https://raw.githubusercontent.com/rzajac/esp-dev-env/master/init.sh | bash
```

which will set up the directory structure checkout 
[esp-open-sdk](git clone https://github.com/pfalcon/esp-open-sdk) and 
[esptool](https://github.com/espressif/esptool) repositories. 

**NOTE** - it will not make `esp-open-sdk` you will have to do it yourself 
by changing to `$HOME/esproot/esp-open-sdk` directory and issuing 
`make STANDALONE=y`. See the documentation at 
[esp-open-sdk](git clone https://github.com/pfalcon/esp-open-sdk).

# Installing External Libraries.

For example to use one of the libraries from 
[esp-ecl](https://github.com/rzajac/esp-ecl) you just do

```
$ wget -O - https://raw.githubusercontent.com/rzajac/esp-ecl/master/install.sh | bash
```

which compiles the libraries being part of the 
[esp-ecl](https://github.com/rzajac/esp-ecl) repository and installs all needed
files to appropriate places in `$ESPROOT` so other programs can easily find 
 and use them.

This makes pulling new libraries to your project very fast and easy.

## External Library Requirements.

All libraries which are part of this build system **must**:

- Provide shell installation script (see 
[install.sh](https://github.com/rzajac/esp-ecl/blob/master/install.sh)).
- Provide installation targets which install libraries to `$ESPROOT/lib`,
header files to `$ESPROOT/include`, supporting binary files to `$ESPROOT/bin`.
- Provide CMake `Find<lib_name>.cmake` scripts and install them to 
`$ESPROOT/esp-cmake/Modules` directory (see 
[Findesp_sdo.cmake](https://github.com/rzajac/esp-ecl/blob/master/cmake/Findesp_sdo.cmake)).

## Libraries Supporting This Build System. 

- [esp_ecl](https://github.com/rzajac/esp-ecl) - Collection of small but useful libraries.
- [esp-prot](https://github.com/rzajac/esp-prot) - Protocols (I2C, OneWire).

## License.

[Apache License Version 2.0](LICENSE) unless stated otherwise.
