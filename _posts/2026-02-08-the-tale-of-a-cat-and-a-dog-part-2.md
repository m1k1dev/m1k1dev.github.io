---
title: 'The Tale of a Cat and a Dog - Part II'
date: 2026-02-28
categories: [Software Development, Utils]
tags: [python, cli, cat, coreutils, pyutils, unix, linux]
description: Learn the implementation details of - the dog - a simple cat clone written in Python.
---

## Introduction

This is the second part of the Tale that will show the implementation details of the `cat` [[1]] clone written in Python. Just for the sake of fun I decided to name the clone as - the `dog`.

## The dog anatomy

The application is split into several basic packages which contain submodules with clear responsibilites:

![Dog Architecture](/assets/diagrams/the-tale-of-a-cat-and-a-dog-architecture.svg)
*Dog packages and submodules*

At the top is the dog package and submodule, which serve as a main entry point. Their responsibilities are to parse the command-line arguments and create the runtime configuration based on them. Once the configuration is prepared, the application is ready for I/O operations, during which it reads from the provided file(s) (and/or `stdin`) and performs the necessary processing as defined by the configuration. To realize the intended functionality, the dog submodule combines the capabilities provided by the dependent packages and modules.
 
### Cli package

The main purpose of the cli package is to provide capabilities for parsing command-line arguments and creating the runtime configuration. 

There are two submodules:
- `parser`, which statically defines the supported arguments and provides the functionality to parse them.
- `config`, which provides options that allow the creation of the runtime configuration as a convenient abstraction over the command-line arguments.

### Core package

The core package provides the core processing capabilities to translate the input data into appropriate output format based on the runtime configuration.

There are two submodules:
- `processor`, which performs input data classification and processing.
- `transformers`, which exposes functionality for translating the classified data into output ready format based on the configuration.

### Util package

The utilities package provides basic utilities that can be used by other submodules to simplify the implementation of the desired bussiness logic. The `util` submodule exposes options for line counting, formatting, meta transformations, and more.

## Teaching my dog to bark

### Command-line arguments parsing

The supported arguments were explained in [Part I]({% post_url 2026-01-25-the-tale-of-a-cat-and-a-dog-part-1 %}#command-line-options) [[2]]. All of them are defined as flags or switches to enable specific kinds of output. The only exception is the `FILE` argument, which expects zero or more file paths specifying the files to be processed.

Parsing of command-line arguments is the responsibility of the `parser` submodule, which is part of the `cli` package. It is built on top of Python's `argparse` library and provides a single API: `parse_args`. When invoked it first creates an internal parser instance of `argparse.ArgumentParser`.

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
- `formatter_class` defines the help output formatter. ArgumentParser uses internal formatting for the program help. With RawDescriptionHelpFormatter [[3]] the help section uses the description and epilog as defined by the user.
- `epilog` provides additional information about the program displayed after the description of the arguments. 


Arguments are registered with the `add_argument` method. It can be passed one or more optional parameters as specified in the library documentation [[4]].

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

Most of the arguments can be enabled by using either their short or long forms. All of them (except `FILE`) use the `store_true` action, which  simply sets the argument flag to `True` when the option is provided.

The `FILE` argument has a special definition. The `nargs="*"` parameter is set because a variable number of files can be provided on the command line. All file paths should be treated as strings, so the `type=str` is specified. However, if no files are provided, then the program reads from the `stdin`, which is defined by the `default="-"` setting.

Once the parser is created and the arguments are registered, they are parsed, stored in a `argparse.Namespace` object, and returned to the caller.

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

Since certain output formatting options can be enabled by more than one argument, the existence of each of these arguments must be verified to determine if the option should be enabled. As shown in the snippet above, to determine whether tabs should be visible in the output, all three arguments that enable the option must be checked: `show_tabs`, `t` and `show_all`. This approach is cumbersome and negatively affects code readability and comprehension.

This logic can be simplified, which is where `DogConfig` comes in.

`DogConfig` is a class provided by the `cli.config` submodule. It represents the configuration built from command-line arguments of the currently executing program.

```python
def __init__(self, args: Namespace) -> None:
    """ Initialize a new DogConfig instance.

    Args:
        args (Namespace): Command line arguments
    """

    self.args = args
```

`DogConfig` encapsulates argument presence verification within a set of well-defined methods.

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

Now, for the same example, instead of explicitly checking for the presence of the `show_tabs`, `t` and `show_all` arguments, these checks are encapsulated within the `show_tabs` method, which returns a boolean indicating whether any of the arguments is set. Internally, the same values are still evaluated, but the resulting user code is simpler and more readable.

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

Standard input is read if no `FILE` argument is set or when it is set to "-". To read from `stdin`, it's internal buffer is accessed and read line by line. Data is then processed as defined in the  configuration and written to standard output - `stdout`.

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

The data is read and processed for each file stored by the `FILE` argument. It is read in chunks of 256 bytes, which makes the file reading memory efficient, as the entire file is not loaded into memory at once. If any argument such as `--squeeze-blank`, `--number` or `--number-nonblank` are enabled, the data is buffered until an end of line (EOL) marker is detected. Only then the buffered data is formatted according to the configuration (e.g. lines are numbered, repeated empty are lines removed) and written to stdout. If none of the enlisted arguments is provided the data is immediatelly written to `stdout` after processing.

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

So far we've seen how the application parses the command-line arguments, how it creates the runtime configuration based on them, and how it reads the data from standard input and/or from one or more files.

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

Once the steps above are completed the data is processed and transformed according to the configuration, and finally written to the standard output. The basic algorithm flow is shown below.

![Dog Architecture](/assets/diagrams/the-tale-of-a-cat-and-a-dog-processing-algorithm.svg)
*Data processing and transformation algorithm*

#### Processor

Data classification and processing are performed by the `processor` submodule. Each byte is classified into the appropriate character class based on its code. The classification follows the standard ASCII encoding table [[5]]. Any non-ASCII character is displayed as a symbol in meta notation if non-printing characters are requested via the command-line arguments. Once classifed, each byte or character is passed to the appropriate transformation function in the `transformers` submodule.

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

The `transformers` submodule contains data transformation functions. These functions are defined for each character class and use configuration settings to determine the correct output representation for a given character code. Lets take a closer look at each one.

The simplest function is the one for transforming alphanumeric characters. There are no special configuration settings for the alphanumeric characters class, so they are always represented in their basic form.

```python
def transform_alphanum_character(code: int) -> bytes:
    return bytes([code])
```

The newline character could essentially be classified as a control character, but it is assigned its own character class for easier manipulation. The `transform_newline_character` function first checks whether end-of-line symbols were requested in the configuration. If they were, the special "$" symbol is prepended to the newline character. Otherwise, the newline is treated as a regular end-of-line character.

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

The last transformation function transforms non-ASCII characters. All non-printing characters belong to this class and they are displayed in the output in a meta notation only if the `show-nonprinting` command-line argument is set.

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

The `to_meta_notation` function checks whether the high-bit is set. If it is, the character code is converted to the appropriate symbol in meta notation based on the value of the remaining low bits.

## Woof woof

Let's test whether this `dog` barks as the `cat` meows.

```terminal
❯ python3 -m pyutils.dog.dog -bnt pyutils/dog/test_file.txt
     1  This is a normal line.

     2  This line has trailing spaces.
     3  (Ends with 4 spaces)




     4  These were multiple blank lines above.

     5  Line with a TAB M-bM-^FM-^R^I    after the tab.

     6  Line with Unicode: M-DM-^EM-DM-^MM-DM-^YM-EM->M-fM-<M-"M-eM--M-^WM-pM-^_M-^YM-^B

     7  Line with raw control chars:
     8  BEL: ^G
     9  BS: ^H
    10  ESC: ^[
    11  DEL: ^?

    12  Null byte in text:
    13  Here M-bM-^FM-^R M-oM-?M-= M-bM-^FM-^P there

    14  A very long line for chunk-reading testing: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

    15  Line without newline at end M-bM-^FM-^R END_OF_FILE
```

```terminal
❯ cat -bnt pyutils/dog/test_file.txt
     1  This is a normal line.

     2  This line has trailing spaces.
     3  (Ends with 4 spaces)




     4  These were multiple blank lines above.

     5  Line with a TAB M-bM-^FM-^R^I    after the tab.

     6  Line with Unicode: M-DM-^EM-DM-^MM-DM-^YM-EM->M-fM-<M-"M-eM--M-^WM-pM-^_M-^YM-^B

     7  Line with raw control chars:
     8  BEL: ^G
     9  BS: ^H
    10  ESC: ^[
    11  DEL: ^?

    12  Null byte in text:
    13  Here M-bM-^FM-^R M-oM-?M-= M-bM-^FM-^P there

    14  A very long line for chunk-reading testing: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

    15  Line without newline at end M-bM-^FM-^R END_OF_FILE
```

Both programs were invoked with `-b`, `-n`, and `-t` options and they produced the same output.
The non-empty lines are numbered and the tab character is replaced with the "^I" symbol.

Seems like this dog knows how to bark now.

## References

1. **GNU-Coreutils**. *Cat Usage*.
   <https://www.gnu.org/software/coreutils/manual/html_node/cat-invocation.html>

2. **The Tale of a Cat and a Dog - Part I**. *Part I*.
   <https://m1k1dev.github.io/posts/the-tale-of-a-cat-and-a-dog>

3. **RawDescriptionHelpFormatter**. *Description Formatter*.
   <https://docs.python.org/3/library/argparse.html#argparse.RawDescriptionHelpFormatter>

4. **Add argument library documentation**. *Add argument method*.
   <https://docs.python.org/3/library/argparse.html#the-add-argument-method>

5. **ASCII-CODE**. *Ascii Table*.
   <https://www.ascii-code.com/>

[1]: https://www.gnu.org/software/coreutils/manual/html_node/cat-invocation.html

[2]: <https://m1k1dev.github.io/posts/the-tale-of-a-cat-and-a-dog>

[3]: https://docs.python.org/3/library/argparse.html#argparse.RawDescriptionHelpFormatter

[4]: https://docs.python.org/3/library/argparse.html#the-add-argument-method

[5]: https://www.ascii-code.com/
