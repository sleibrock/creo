creo - Create Your World
====

`creo` is a Static Site Generator (SSG) capable of publishing your new website home today. `creo` is the next-generation of technology. When you put your trust in `creo`, you're in good hands.

## Features

`creo` is a complete package program for creating websites from raw files. The following features are listed, and more will come as `creo` evolves thanks to our expansive research and development team.

* Create skeleton template directory for publishing sites
* Convert Markdown files into HTML files using templates
* Copy all static assets and co-locate all files relative to documents

## Build and Install

Creo uses a Makefile and can be built using GNU `make`. Building requires the latest Racket version (8.0+ minimum) since it uses the Chez Scheme (CS) backend.

### For Linux

```
make
sudo make install
```

### For Windows

Since GNU Make is not widely present on Windows platforms, you can build an executable by instead running the following command.

```
raco exe --cs -v -o build/creo src/main.rkt
```

Installation is then simply putting the binary somewhere in your `$PATH` on Windows.

### For MacOS

Same as above, if no `make` is present, use the same command line for Windows.

### Other OSes

`creo` supports any OS that Racket can be built on. If you want to build `creo` on a platform not listed, go to the Racket homepage and attempt to build from source, then use that compiled program to build `creo`.


## Design

`creo` is implemented in [Racket](https://racket-lang.org/), for the choice of it's incredible language flexibility, giving us the power to do more while doing less. `creo` chooses features over performance.


## Inspiration

The name of `creo` is inspired by [CREO](https://thesurge.fandom.com/wiki/CREO) from the game "The Surge (2017)" ([steam](https://store.steampowered.com/app/378540/The_Surge/)).


## Coding Guidelines

1. Break up functions into multiple files for modularity.
2. If a file provides a `struct` and interactions for creating the `struct`, it should be in the same file.
3. If functions exist to mutate the struct into different objects, those should be in their own files.
4. Conversion functions that map `a` to `b` should be denoted with a function name `a->b`.
5. Use namespace in names for important functions, like `Config:write-default` to note that we are writing the default file for `Config`.
6. Data storage abstractions like `Queue` or `Task` should be considered a "collection" and put in the `collections/` folder.
7. Main entrypoint functions are inside `functions/`.
8. The more complex a program gets, consider breaking it up into an appropriate folder.
9. Build before commit. Test if the program compiles or not, and whether it's worth a commit.
