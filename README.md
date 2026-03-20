# Bygg - A C Build System for Idiots

**bygg** is a tiny, dependency‑driven build system for C that provides real
modules, clean encapsulation, and predictable builds — all implemented in
a single, portable POSIX shell script.

## Key Features

**✔ Explicit modules**

Each module has a .bygg file that declares its name and the modules it depends on.

**✔ Private by default**

Unless exposed by a module's header, all smybols are private. No need for
`static` or header guards.

**✔ Automatic dependency resolution**

The build script discovers all required modules starting from main.bygg.

**✔ Correct build order with no manual rules**

Modules are compiled in dependency order automatically.


## Requirements

In order to run `bygg` you just need standard system utilities like
`sed`, `grep`, `diff`, `wc`, and so on.


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

Note that the name of the `.bygg` file _must_ match the name
of the module it declares. For example, `foo.bygg` must start
with the line `foo`.


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


## Contributing

For portability both `bygg` and the test runner are written in POSIX `sh`.
In order to run the tests you will need the standard GNU toolchain
(`gcc`, `ar`, `ld`, ...) as well as `shellcheck`.

Run the tests by running the `tests/test.sh` script.
This will run `shellcheck` on the test runner itself and `bygg`,
and then build each project in the `tests/` directory and
compare its output to its expected output.


## Current Limitations

This is an early version. Known gaps include:
- No cycle detection in `.bygg` files
- No validation for missing modules or headers
- No incremental rebuilds
- No diagnostics for unused or missing imports

