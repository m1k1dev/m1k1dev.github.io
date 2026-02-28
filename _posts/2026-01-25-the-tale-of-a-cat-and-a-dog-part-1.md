---
title: 'The Tale of a Cat and a Dog - Part I'
date: 2026-01-25
categories: [Software Development, Utils]
tags: [python, cli, cat, coreutils, pyutils, unix, linux]
description: Learn the details behind the cat utility.
---

## Introduction

What came first? A cat ? Or a dog ?

If you ask historians or scientists the dog was the first animal of the two that was domesticated around ~12000 years ago with 
some sources  claiming an even earlier point in time - around ~30000 years ago [[1]].

On the other hand, domestication of cats began around ~10000 years ago in the Middle East while in other parts of the world it started much later. 
It was around 4000 years ago in Africa and Egypt, 3000 years ago in China and just up until recently (18th century) the whole Europe was afraid of cats. 
No really, cats had a very bad reputation in Europe as they were often associated with witchcraft and were considered as bad omens.

But what does this have to do with software development ?

Absolutely nothing. 

But you will read about cat and dog in this blog post as I'll be explaining this simple but effective utility while also building my own clone.

## A cat

### Overview

In the world of software, `cat` was here before the dog as one of the core utilities supported in UNIX systems. 
The name `cat` comes from the word *concatenate* and this utility can be used to read one or more files, merge or join their content
in given order and print it to the standard output.

To use the `cat` utility you simply invoke it like:

`cat [OPTION]... [FILE]...`

- `cat` - Name of the command.
- `[OPTION]...` - Indicates that zero or more command line options can be provided.
- `[FILE]...` - Indicates that zero or more files can be provided as input. Additionally, if no input files are provided or if "-" is given as input, the command reads from standard input - `stdin`.


```terminal
~                                                                                                                                                                                         
❯ cat file.txt file2.txt
file.txt:
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. 
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
file2.txt:
Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam,
eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. 
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. 
Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius 
modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.                                                                                                                                                  
```

### Command line options

The following table summarizes all the options `cat` can be invoked with [[3]]:

| Short Option | Long Option          | Description 
| ------------ | -------------------  |  ----------- 
| `-A`         | `--show-all`         | Equivalent to -vET.            
| `-b`         | `--number-nonblank`  | Number nonemtpy output lines, overrides -n.    
| `-e`         |                      | Equivalent to -vE.
| `-E`         | `--show-ends`        | Display $ at the end of each line.
| `-n`         | `--number`           | Number all output lines.
| `-s`         | `--squeeze-blank`    | Suppress repeated empty output lines.
| `-t`         |                      | Equivalent to -vT.
| `-T`         | `--show-tabs`        | Display TAB characters as ^I.
| `-u`         |                      | (ignored).
| `-v`         | `--show-nonprinting` | Use ^ (carret) and M- (meta) notations, except for LFD and TAB.
|              | `--help`             | Display help.
|              | `--version`          | Output version information.

Let me explain each of these options in more details. You can notice that several of them
are actually a shorthand notation for a combination of others. I will skip these for now 
and explain the "main" ones first and in the end I'll show how the shorthand notation
can be conveniently used as a replacement in certain scenarios.

#### cat -b / --number-nonblank

The description states that this option can be used to number non empty lines, meaning that any blank line will be printed but without line number mark. 
It will also disable/override the functionality enabled by `-n` option, if such option is set. 
I'll jump a little bit ahead and say that `-n` enumerates and displays line numbers for the complete output.

```terminal
❯ cat -b ./test_file.txt 
     1	This is a normal line.

     2	This line has trailing spaces.    
     3	(Ends with 4 spaces)




     4	These were multiple blank lines above.

     5	Line with a TAB →	    after the tab.

     6	Line with Unicode: ąčęž漢字🙂

     7	Line with raw control chars:
     8	BEL: 
     9	BS: 
    10	ESC: 
1	DEL: 

    12	Null byte in text:
    13	Here → � ← there

    14	A very long line for chunk-reading testing: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

    15	Line without newline at end → END_OF_FILE

```

#### cat -E / --show-ends

This option simply puts the `"$"` character at the end of each line. 
This can be useful in certain scenarios like when dealing with non-printing characters so that end of line is easier to spot in the output.

```terminal
❯ cat -E test_file.txt                     
This is a normal line.$
$
This line has trailing spaces.    $
(Ends with 4 spaces)$
$
$
$
$
These were multiple blank lines above.$
$
Line with a TAB →	    after the tab.$
$
Line with Unicode: ąčęž漢字🙂$
$
Line with raw control chars:$
BEL: $
BS:$
ESC: 
EL: $
$
Null byte in text:$
Here → � ← there$
$
A very long line for chunk-reading testing: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA$
$
Line without newline at end → END_OF_FILE$

```

#### cat -n / --number

As I already mentioned:

> -n / --number enumerates and displays line numbers for the complete output.

In other words, cat will print line numbers even for empty lines.

```terminal
❯ cat -n test_file.txt
     1	This is a normal line.
     2	
     3	This line has trailing spaces.    
     4	(Ends with 4 spaces)
     5	
     6	
     7	
     8	
     9	These were multiple blank lines above.
    10	
    11	Line with a TAB →	    after the tab.
    12	
    13	Line with Unicode: ąčęž漢字🙂
    14	
    15	Line with raw control chars:
    16	BEL: 
    17	BS: 
    18	ESC: 
9	DEL: 
    20	
    21	Null byte in text:
    22	Here → � ← there
    23	
    24	A very long line for chunk-reading testing: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    25	
    26	Line without newline at end → END_OF_FILE
```

#### cat -s / --squeeze-blank

In cases when the input contains two or more consecutive blank lines the `-s` or `--squeeze-blank` 
option can be used to merge / squash / squeeze them into a single line to not waste the precious screen space.

```terminal
❯ cat -s test_file.txt
This is a normal line.

This line has trailing spaces.    
(Ends with 4 spaces)

These were multiple blank lines above.

Line with a TAB →	    after the tab.

Line with Unicode: ąčęž漢字🙂

Line with raw control chars:
BEL: 
BS: 
ESC: 

EL: 

Null byte in text:
Here → � ← there

A very long line for chunk-reading testing: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

Line without newline at end → END_OF_FILE

```

#### cat -T / --show-tabs

The name of this option is explanatory enough. Whenever cat encounters a `TAB` character, 
instead of indenting the remainder of the text it will simply output `"^I"` instead.

```terminal
 cat -T test_file.txt
This is a normal line.

This line has trailing spaces.    
(Ends with 4 spaces)




These were multiple blank lines above.

Line with a TAB →^I    after the tab.

Line with Unicode: ąčęž漢字🙂

Line with raw control chars:
BEL: 
BS: 
ESC: 

EL: 

Null byte in text:
Here → � ← there

A very long line for chunk-reading testing: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

Line without newline at end → END_OF_FILE

```

#### cat -v / --show-nonprinting

This one I find the most interesting as it handles non-printing characters in a special way. If we have a look at the standard ASCII table [[2]] we'll find the following definitions:

| Characters (DEC) | Description |
| 0-31 | Non-printing characters which usually have special meaning related to peripherals. |
| 32-127 | Printable characters which denote alphanumeric values, punctuation marks and other. |
| 128-255   | Extended ASCII characters set.

Characters with high-bit (`0x80`) set will be printed in meta notation (`M-`) if the option for non-printing characters is set.


```terminal
❯ cat -v test_file.txt              
This is a normal line.

This line has trailing spaces.    
(Ends with 4 spaces)




These were multiple blank lines above.

Line with a TAB M-bM-^FM-^R	    after the tab.

Line with Unicode: M-DM-^EM-DM-^MM-DM-^YM-EM->M-fM-<M-"M-eM--M-^WM-pM-^_M-^YM-^B

Line with raw control chars:
BEL: ^G
BS: ^H
ESC: ^[
DEL: ^?

Null byte in text:
Here M-bM-^FM-^R M-oM-?M-= M-bM-^FM-^P there

A very long line for chunk-reading testing: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

Line without newline at end M-bM-^FM-^R END_OF_FILE

```

#### cat --help

Prints the help section which explains the usage and all the supported options.

```terminal
❯ cat --help          
Usage: cat [OPTION]... [FILE]...
Concatenate FILE(s) to standard output.

With no FILE, or when FILE is -, read standard input.

  -A, --show-all           equivalent to -vET
  -b, --number-nonblank    number nonempty output lines, overrides -n
  -e                       equivalent to -vE
  -E, --show-ends          display $ at end of each line
  -n, --number             number all output lines
  -s, --squeeze-blank      suppress repeated empty output lines
  -t                       equivalent to -vT
  -T, --show-tabs          display TAB characters as ^I
  -u                       (ignored)
  -v, --show-nonprinting   use ^ and M- notation, except for LFD and TAB
      --help        display this help and exit
      --version     output version information and exit

Examples:
  cat f - g  Output f's contents, then standard input, then g's contents.
  cat        Copy standard input to standard output.

GNU coreutils online help: <https://www.gnu.org/software/coreutils/>
Full documentation <https://www.gnu.org/software/coreutils/cat>
or available locally via: info '(coreutils) cat invocation'


```

#### cat --version

This option will print some standard information about current utility version, authors and similar.

```terminal
❯ cat --version                                   
cat (GNU coreutils) 9.7
Copyright (C) 2025 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Torbjörn Granlund and Richard M. Stallman.
```

#### Compound options

Now we come back to the compound options that represent a combination of other options. 

- `-A` / `--show-all option` - Starting with `-A` / `--show-all option`, it gives the user a possibility to enable functionalities provided by options: `-v`, `-E`, `-T`. 
In other words this option will output file contents in such way that `"$"` signs are printed for line endings combined with `"^I"` 
as a replacement for `TAB` characters. It will also print the non-printing characters as explained earlier.

- `cat -e` - Similarly as the one above, this option will enable `"$"` signs for line endings combined with non-printing characters.

- `cat -t` - This one will simultaneously enable functionalities provided by `-v` and `-T` options to show non-printing characters in the output together with `TAB` characters displayed as `"^I"`.

## Conclusion

This first part of the blog gives an overview of the `cat` command with explanations for each of the supported options.
The second part will explain one way on how to implement this utility by going through the implementation details of my own `cat` clone - `dog`.

Stay tuned ...

## References

1. **Boehringer Ingelheim**. *The history of cats*.  
   <https://www.boehringer-ingelheim.com/in/animal-health/companion-animals/pets/history-cats>

2. **ASCII-CODE**. *Ascii Table*.  
   <https://www.ascii-code.com/>

3. **GNU-Coreutils**. *Cat Usage*.  
   <https://www.gnu.org/software/coreutils/manual/html_node/cat-invocation.html>


[1]: https://www.boehringer-ingelheim.com/in/animal-health/companion-animals/pets/history-cats

[2]: https://www.ascii-code.com/

[3]: https://www.gnu.org/software/coreutils/manual/html_node/cat-invocation.html