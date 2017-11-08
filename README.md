## ESP8266 Development Environment.

This repository is my try to somehow organize my ESP8266 development. It
mainly defines requirements for development environment directory structure 
to help organize / find libraries used by many of my projects. Based on 
the directory structure I created a collection of CMake helper scripts which
automate building and flashing process. 

## Motivation

As my ESP8266 projects grew in number I started having problems with code 
dependencies. Some of my libraries depended on others and at some point 
it become really hard to keep repositories up to date when doing changes, 
fixes and refactorings to libraries they depended on. The first approach 
was to use git subtree but even this caused problems on the long run.

The obvious solution was to create consistent build system and directory 
structure which allows sharing the code (libraries) between projects. 
This repository provides basis for exactly that. 

Aside form defined directory structure and shared CMake files defining 
how the code is build it also provides toolchain configuration and 
ability to easily install libraries using example install scripts. 

For example to use [esp-pin](https://github.com/rzajac/esp-pin) library
you can just do:

```
$ wget -O - https://raw.githubusercontent.com/rzajac/esp-pin/master/install.sh | bash
```

and start using it in your project.
 
## Directory structure.

The root of the development environment is pointed by `$ESPROOT` environment 
variable. It's recommended to define it in `.profile` file so it is set
every time you log in. If it is not set the default value 
`$HOME/esproot` will be used. 

## Initializing Development Environment.

The easiest way to initialize development environment is to run:

```
$ wget -O - https://raw.githubusercontent.com/rzajac/esp-dev-env/master/init.sh | bash
```

It will:

- Create `$HOME/esproot/{include,lib}` directories.
- Checkout [esptool](https://github.com/espressif/esptool) and 
[esp-open-sdk](git clone https://github.com/pfalcon/esp-open-sdk).
- Setup CMake scripts.
- Adds `$ESPROOT` export to `.profile` file.
- Adds `$ESPROOT/esp-open-sdk/xtensa-lx106-elf/bin` binaries to `$PATH` in `.profile` file. 

The result of running the script is following directory structure:

    ${HOME}
    └── esproot
        ├── esp-cmake
        ├── esp-open-sdk
        ├── esptool
        ├── include
        └── lib

**NOTE!** Before you can compile and flash ESP8266 programs you will have to 
compile `esp-open-sdk` as standalone (`make STANDALONE=y`). See
the documentation at [esp-open-sdk](git clone https://github.com/pfalcon/esp-open-sdk).   

## License.

[Apache License Version 2.0](LICENSE) unless stated otherwise.
