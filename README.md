# Bygg - A C Build System for Idiots

**bygg** is a tiny, dependency‑driven build system for C that provides real
modules, clean encapsulation, and predictable builds — all implemented in
a single POSIX shell script.

## Key Features

**✔ Explicit modules**
Each module has a .bygg file that declares its name and the modules it depends on.

**✔ Automatic dependency resolution**
The build script discovers all required modules starting from main.bygg.

**✔ Correct build order with no manual rules**
Modules are compiled in dependency order automatically.

**✔ One static library per module**
Each module becomes a clean, isolated unit at link time.

**✔ Simple, predictable header usage**
Modules only see the headers of modules they explicitly import.

**✔ No Makefiles or build configuration files**
Just run `bygg`.


## Modules

A module in `bygg` is made up of a directory containing a header file,
a `.bygg` file, and one or more `.c` files.

A module's header file should export its public API.
Then `bygg` will take care of shadowing and symbol collisions.
This means a module's symbols will be visible only to that module
by default (without needing `static`!).

A `.bygg` file looks like this:

```
ModuleName
DependencyA
DependencyB
...
```

The first line is the module's name.
The following lines list the modules it depends on.


## Project Layout

A typical project might look like:

```
src
├── main.bygg
├── main.c
├── ModuleA
│   ├── ModuleA.bygg
│   ├── modulea.c
│   └── modulea.h
├── ModuleB
│   ├── moduleb1.c
│   ├── moduleb2.c
│   ├── ModuleB.bygg
│   └── moduleb.h
└── ModuleC
    ├── ModuleC.bygg
    ├── modulec.c
    └── modulec.h
```

But `bygg` doesn't actually care about your project's layout.
You're free to organize it however you want.
Module dependency and visibility is defined entirely by the `.bygg` files.


## Current Limitations

This is an early version. Known gaps include:
- No cycle detection in `.bygg` files
- No validation for missing modules or headers
- No incremental rebuilds
- No diagnostics for unused or missing imports

