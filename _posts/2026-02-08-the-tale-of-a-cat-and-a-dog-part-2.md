---
title: 'The Tale of a Cat and a Dog - Part II'
date: 2026-02-08
categories: [Software Development, Utils]
tags: [python, cli, cat, coreutils, pyutils, unix, linux]
description: Learn the implementation details of a dog - a simple cat clone written in Python.
---

## Introduction

This is the second part of the Tale which will show the implementation details of the `cat` clone written in Python. Just for the sake of fun I decided to name it as - the `dog`.

## The Dog Anatomy

The application is split into several basic packages which contain submodules with clear responsibilites:

![Dog Architecture](/assets/diagrams/the-tale-of-a-cat-and-a-dog-architecture.svg)
*Dog packages and submodules*

At the top is the dog package and submodule which serves as a main entry point. Its responsibilities are to parse the command-line arguments and create the runtime configuration based on them. Once the configuration is prepared, the application is ready for the I/O operations, during which it will read from the provided file(s) (and/or `stdin`) and perform necessary processing as defined by the configuration. To realize the intended functionality, the dog submodule combines the capabilities provided by the dependent packages and modules.
 
### Cli Package

The main purpose of the cli package is to provide capabilities for parsing command-line arguments and creating the runtime configuration. 

There are two submodules:
- The `parser` submodule statically defines the supported arguments and provides the functionality to parse them. 
- The `config` submodule provides options that allow the creation of the runtime configuration as a convenient abstraction on top of the command-line arguments. 

### Core Package

The core package provides the core processing capabilities to translate the input data into appropriate output format based on the runtime configuration.

There are two submodules:
- The `processor` submodule performs input data classification and processing.
- The `transformers` submodule exposes functionality for translating the classified data into output ready format based on the configuration.

### Util Package

The utilities package provides basic utilities which can be used by other submodules to simplify realization of the wanted bussiness logic. The `util` submodule exposes options for line counting, formatting, meta transformations and other.

## Teaching My Dog How To Bark

### Parsing The Command Line Arguments

The supported arguments were explained in [Part I]({% post_url 2026-01-25-the-tale-of-a-cat-and-a-dog-part-1 %}#command-line-options). All of them are defined as flags/switches and they serve to enable certain kind of output. Only exception is the `FILE` argument which expects zero or more file paths with the name of the file that should be processed.

Parsing of command-line arguments is the responsibility of the `parser` submodule that is part of the `cli` package. It is built on top of Python's `argparse` library and provides a single API: `parse_args`. When invoked it first creates an internal parser instance of `argparse.ArgumentParser`.

The parser is created as:

```python

def _create_parser() -> argparse.ArgumentParser:
    """ Creates the command line argument parser.

    Returns:
        argparse.ArgumentParser: Argument parser instance.
    """

    parser = argparse.ArgumentParser(prog="dog",
                                     description="Concatenate FILE(s) to standard output.\n\nWith no FILE, or when FILE is -, read standard input.",
                                     usage="dog [OPTION]... [FILE]...",
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog="Full documentation <https://github.com/m1k1dev/unix-pyutils>")
    ...

    return parser
```

- `prog` defines the program name i.e "dog".
- `description` defines the arbitrary description of the program. In this case exact copy of `cat`s description.
- `usage` defines basic instructions how to run the program.
- `formatter_class` defines the help output formatter. ArgumentParser uses internal formatting for the program help. With [RawDescriptionHelpFormatter](https://docs.python.org/3/library/argparse.html#argparse.RawDescriptionHelpFormatter) the help section uses the description and epilog as is.
- `epilog` provides additional information about the program displayed after the description of the arguments. 


Arguments are registered with the `add_argument` method. It can be invoked with one or more optional arguments as specified in the [library documentation](https://docs.python.org/3/library/argparse.html#the-add-argument-method). 

To realize the needed functionality only the following ones are used:

| Argument      | Description                                                                                                       | Comment                                                                                   |
|---------------|-------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| `name or flags` | Either a name or a list of option strings, e.g. 'foo' or '-f', '--foo'.                                           | Used to specify the argument name.                                                        |
| `action`        | The basic type of action to be taken when this argument is encountered at the command line.                       | Used to specify the 'store_true' action to enable the flag arguments.                     |
| `nargs`         | The number of command-line arguments that should be consumed.                                                     | Used to specify that a variable number of file paths can be given for FILE(s) argument.   |
| `default`       | The value produced if the argument is absent from the command line and if it is absent from the namespace object. | Used to specify that reading from stdin ("-") should be used if no FILE(s) were provided. |
| `type`          | The type to which the command-line argument should be converted.                                                  | Used to specify that FILE(s) should be treated as str.                                    |
| `help`          | A brief description of what the argument does.                                                                    | Used to describe the argument in the help section.                                        |

The arguments are statically defined as specified by the requirements:

```python

def _create_parser() -> argparse.ArgumentParser:
    ...

    parser.add_argument("-A",
                        "--show-all",
                        action="store_true",
                        help="equivalent to -vET")

    parser.add_argument("-b",
                        "--number-nonblank",
                        action="store_true",
                        help="number nonempty output lines, overrides -n")

    parser.add_argument("-e",
                        action="store_true",
                        help="equivalent to -vE")

    parser.add_argument("-E",
                        "--show-ends",
                        action="store_true",
                        help="display $ at end of each line")

    parser.add_argument("-n",
                        "--number",
                        action="store_true",
                        help="number all output lines")

    parser.add_argument("-s",
                        "--squeeze-blank",
                        action="store_true",
                        help="supress repeated empty output lines")

    parser.add_argument("-t",
                        help="equivalent to -vT",
                        action="store_true")

    parser.add_argument("-T",
                        "--show-tabs",
                        action="store_true",
                        help="display TAB characters as ^I")

    parser.add_argument("-u",
                        action="store_true",
                        help="ignored")

    parser.add_argument("-v",
                        "--show-nonprinting",
                        action="store_true",
                        help="use ^ and M- notation, except for LFD and TAB")

    parser.add_argument("--version",
                        action="store_true",
                        help="output version information and exit")

    parser.add_argument("FILE",
                        nargs="*",
                        type=str,
                        default="-")
    ...
```

Most of the arguments can be enabled by using either their short or long format. All of them (besides `FILE(s)`) use the `store_true` action which 
will simply set the argument flag to `True` if one is provided. 

The `FILE(s)` argument has a special definition. The `nargs="*"` is set since a variable number of files can be provided in the command line. All filepaths with names should be treated as strings so the `type=str` is set. However, if no files are provided then the program should read from the `stdin` which is defined by the `default="-"` argument.

Once the parser is created and the arguments are registered, they are parsed and stored in a `argparse.Namespace` object and returned to the caller.

```python
import argparse

def parse_args() -> argparse.Namespace:
    parser = _create_parser()
    return parser.parse_args()
```

### Dog Configuration

### Input Reading

#### Reading From The Standard Input

#### Reading From A File

### Input Processing

#### Processor

#### Transformers

## Final Barks