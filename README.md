## ESP8266 Development Environment.

This repository is my try to somehow organize my ESP8266 development. It
mainly defines requirements for development environment directory structure 
to help organize / find libraries used by many of my projects. Based on 
the directory structure I created a collection of CMake helper scripts which
automate building and and flashing process. 

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

## Example usage.

TODO

## License.

[Apache License Version 2.0](LICENSE) unless stated otherwise.
