---
title: 'The Tale of a Cat and a Dog - Part II'
date: 2026-02-08
categories: [Software Development, Utils]
tags: [python, cli, cat, coreutils, pyutils, unix, linux]
description: Learn the implementation details of a dog - a simple cat clone written in Python.
---

## Introduction

This is the second part of the Tale which will show the implementation details of the `cat` clone written in Python. Just for the sake of fun I decided to name it as - the `dog`.

## The dog anatomy

The application is split into several basic packages which contain submodules with clear responsibilites:

![Dog Architecture](/assets/diagrams/the-tale-of-a-cat-and-a-dog-architecture.svg)
*Dog packages and submodules*

At the top is the dog package and submodule which serves as a main entry point. Its responsibilities are to parse the command-line arguments and create the runtime configuration based on them. Once the configuration is prepared, the application is ready for the I/O operations, during which it will read from the provided file(s) (and/or `stdin`) and perform necessary processing as defined by the configuration. To realize the intended functionality, the dog submodule combines the capabilities provided by the dependent packages and modules.
 
### Cli package

The main purpose of the cli package is to provide capabilities for parsing command-line arguments and creating the runtime configuration. 

There are two submodules:
- The `parser` submodule statically defines the supported arguments and provides the functionality to parse them. 
- The `config` submodule provides options that allow the creation of the runtime configuration as a convenient abstraction on top of the command-line arguments. 

### Core package

The core package provides the core processing capabilities to translate the input data into appropriate output format based on the runtime configuration.

There are two submodules:
- The `processor` submodule performs input data classification and processing.
- The `transformers` submodule exposes functionality for translating the classified data into output ready format based on the configuration.

### Util package

The utilities package provides basic utilities which can be used by other submodules to simplify realization of the wanted bussiness logic. The `util` submodule exposes options for line counting, formatting, meta transformations and other.

## Teaching my dog to bark

### Command-line arguments parsing

The supported arguments were explained in [Part I]({% post_url 2026-01-25-the-tale-of-a-cat-and-a-dog-part-1 %}#command-line-options). All of them are defined as flags/switches and they serve to enable certain kind of output. Only exception is the `FILE` argument which expects zero or more file paths with the name of the file that should be processed.

Parsing of command-line arguments is the responsibility of the `parser` submodule that is part of the `cli` package. It is built on top of Python's `argparse` library and provides a single API: `parse_args`. When invoked it first creates an internal parser instance of `argparse.ArgumentParser`.

The parser is created as:

```python
import argparse

def _create_parser() -> argparse.ArgumentParser:
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
import argparse

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

Most of the arguments can be enabled by using either their short or long format. All of them (besides `FILE`) use the `store_true` action which 
will simply set the argument flag to `True` if one is provided. 

The `FILE` argument has a special definition. The `nargs="*"` is set since a variable number of files can be provided in the command line. All filepaths with names should be treated as strings so the `type=str` is set. However, if no files are provided then the program should read from the `stdin` which is defined by the `default="-"` argument.

Once the parser is created and the arguments are registered, they are parsed and stored in a `argparse.Namespace` object and returned to the caller.

```python
import argparse

def parse_args() -> argparse.Namespace:
    parser = _create_parser()
    return parser.parse_args()
```

### Dog configuration

Once the arguments are parsed they can be simply accessed as:

```python
import cli.parser

args = parser.parse_args()

if args.show_tabs or args.t or args.show_all:
    # format the output sequence to show tabs as ^I symbols.
elif args.show_ends or args.show_all or args.e:
    # format the output sequence to show $ as line endings.
...

```

Since certain output formatting options can be enabled by more than one argument, existence of each of these arguments needs to be verified to determine if the option should be enabled or not. Like in the snippet above, to determine if tabs should be visible in the output or not, all three arguments which enable the option need to be checked: `show_tabs`, `t` and `show_all`. This approach is cumbersome and negatively affects code readability and comprehension. 

This can be simplified a bit which is where the `DogConfig` comes in. 

`DogConfig` is a class provided by the `cli.config` submodule. It represents the configuration built from command-line arguments of the currently executing program.

```python
def __init__(self, args: Namespace) -> None:
    """ Initialize a new DogConfig instance.

    Args:
        args (Namespace): Command line arguments
    """

    self.args = args
```

By using `DogConfig`, the existence verification of each argument is abstracted into a set of well-defined methods. 

```python

class DogConfig:
    ...

    def show_tabs(self) -> bool:
        ...

    def show_nonprinting(self) -> bool:
        ...

    def show_ends(self) -> bool:
        ...

    def show_all_line_numbers(self) -> bool
        ...

    def show_nonblank_line_numbers(self) -> bool:
        ...

    def show_version(self) -> bool:
        ...

    def squeeze_blank_lines(self) -> bool:
        ...

    def get_filenames(self) -> list[str]:
        ...

```

Now, for the same example, instead of explictly checking for the existence of `show_tabs`, `t` and `show_all` arguments at once, these checks are moved into the `show_tabs` method which returns a boolean if either of the arguments is set. Internally, the same values are still checked, but the resulting user code is simpler and more readable. 

```python
def show_tabs(self) -> bool:
    return self.args.show_tabs or \
           self.args.t or \
           self.args.show_all
```

Other verifications follow the same pattern:

```python
def show_ends(self) -> bool:
    return self.args.show_ends or \
           self.args.show_all or \
           self.args.e
```

### Input reading

There are two primary sources of data for the application:

1. The standard input - `stdin`.
2. File input.

For both sources the data is read in binary mode and processed as a sequence of bytes.

#### Standard input - stdin

Standard input is read if no `FILE` argument is set or when it is set to "-". To read from `stdin`, it's internal buffer is accessed and read line by line. Data is then processed as required by the  configuration and written to standard output - `stdout`.

```python
import cli.config as dc
import core.processor as dp
import utils.utils as du

def read_stdin(dog_config: dc.DogConfig, line_tracker: du.LineTracker) -> None:
    while (data := sys.stdin.buffer.readline()):
        processed_data = dp.process_data(data, dog_config)
        du.write_stdout(du.format_line(processed_data, dog_config, line_tracker))
```

#### File input

The data is read and processed for each file stored in the `FILE` argument. It is read in chunks of 256 bytes which makes the file reading memory efficient as the whole file is not loaded into the memory at once. If any argument such as `--squeeze-blank`, `--number` or `--number-nonblank` is enabled then the data is buffered until end of line (EOL) is detected. Only when EOL is detected the buffered data is formatted based on the configuration (lines enumerated, repeating empty lines removed...) and written to stdout.

```python
import cli.config as dc
import core.processor as dp
import utils.utils as du

def read_file(filename: str, dog_config: dc.DogConfig, line_tracker: du.LineTracker) -> None:
    chunk_size = 256
    with open(filename, "rb") as file:
        buffered_data = bytearray()
        while (data_chunk := file.read(chunk_size)) != b"":
            processed_data = dp.process_data(data_chunk, dog_config)
            if du.track_end_of_line(dog_config):
                buffered_data += processed_data
                if b"\n" in buffered_data:
                    process_buffer(buffered_data, dog_config, line_tracker)
            else:
                du.write_stdout(processed_data)
```

### Input Processing

So far we've seen how the application parses the command-line arguments, how it creates the runtime configuration based on them and how it reads the data from standard input and/or one or more files.

```python

import cli.config as dc
import cli.parser as dp
import utils.utils as du

def run_dog():
    """
        Function which executes the dog utility
    """

    args = dp.parse_args()
    dog_config = dc.DogConfig(args)
    line_tracker = du.LineTracker()

    for filename in dog_config.get_filenames():
        if filename == "-":
            read_stdin(dog_config, line_tracker)
        else:
            read_file(filename, dog_config, line_tracker)

```

Once the steps above are completed the data is processed and transformed based on the configuration and finally written to the standard output. The basic algorithm flow:

![Dog Architecture](/assets/diagrams/the-tale-of-a-cat-and-a-dog-processing-algorithm.svg)
*Data processing and transformation algorithm*

#### Processor

Data classification and processing are performed by the `processor` submodule. Each byte is classified into the appropriate character class based on its code. The classification follows the standard ASCII encoding table. Any non-ASCII character will be displayed as a symbol in meta notation if non-printing characters are requested via the command-line arguments. Once classifed, each byte/character is passed to appropriate transformation function in the `transformers` submodule.

The `process_data` function implements the algorithm shown above:

```python
import cli.config as dc
import core.transformers as dt

def process_data(data: bytes, dog_config: dc.DogConfig) -> bytearray:
    data_it = 0
    processed_data= bytearray()

    while data_it < len(data):
        code = data[data_it]
        if is_newline_character(code):
            processed_data += dt.transform_newline_character(dog_config)
        elif is_alphanum_character(code):
            processed_data += dt.transform_alphanum_character(code)
        elif is_control_character(code):
            processed_data += dt.transform_control_character(code, dog_config)
        else:
            processed_data += dt.transform_utf8_character(code, dog_config)
        data_it += 1

    return processed_data
```

#### Transformers

The `transfomers` submodule contains data transformation functions. The functions are defined for each character class and they use configuration settings to determine the correct output representation for the given character code. Lets have a closer look at each one.

The simplest function is the one for transforming alphanumeric characters. There are no special configuration settings for the alphanumeric characters class so they are always represented in their basic form.

```python
def transform_alphanum_character(code: int) -> bytes:
    return bytes([code])
```

The newline character could essentially be classified as a control character but it is classified into own character class for easier manipulation. The `transform_newline_character` function first checks if end of line symbols were requested by the configuration. If they were then the special "$" symbol is prepended to the newline character. Otherwise the newline is treated as a regular end of line character.

```python
import cli.config as dc

def transform_newline_character(dog_config: dc.DogConfig) -> bytes:
    if dog_config.show_ends():
        return b"$\n"
    return b"\n"
```

The control characters are transformed as follows:

- If given character code is TAB ("\t") and if any of (`--show-tabs`, `-t,` `--show-all`, `-A`) command-line arguments are set, the function will return "^I" as an output representation of that character.
- If given character code is DEL - code point 127 - and if any of (`-v`, `--show-nonprinting`, `-t`, `-e`, `-A`, `--show-all`) command-line arguments are set, the function will return "^?" as an output representation of that character.
- If any other control character code is provided and if any of (`-v`, `--show-nonprinting`, `-e`, `--A`, `--show-all`) command-line arguments are set, the function will return character's "carret" representation.
- If none of the above is matched the character is returned as is.

```python
import cli.config as dc

def transform_control_character(code: int, dog_config: dc.DogConfig) -> bytes:
    if code == ord("\t"):
        if dog_config.show_tabs():
            return b"^I"
        return bytes([code])

    if code == 127:
        if dog_config.show_nonprinting():
            return b"^?"
        return bytes([code])

    if dog_config.show_nonprinting():
        code = code + 64
        return b"^" + bytes([code])

    return bytes([code])
```

The final transformation function is the one which transforms any non-ASCII character. All non-printing characters are part of this character class and they're only displayed in the output in a meta-notation if the `show-nonprinting` command-line argument is set.

```python
import cli.config as dc

def transform_non_ascii_character(code: int, dog_config: dc.DogConfig) -> bytes:
    if dog_config.show_nonprinting():
        return du.to_meta_notation(code).encode("ascii")

    return bytes([code])

...

def to_meta_notation(code: int) -> str:
    low_bits = code & 0x7F
    if low_bits == 127:
        return "M-^?"
    if low_bits < 32:
        return f"M-^{chr(low_bits + 64)}"
    return f"M-{chr(low_bits)}"
```

`to_meta_notation` function checks if the high-bit is set. If it is, the character code is converted to appropriate symbol in meta-notation based on the value range of the remaining low bits. 

## Final Barks