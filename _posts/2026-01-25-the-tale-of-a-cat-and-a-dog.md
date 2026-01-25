---
title: 'The Tale of a Cat and a Dog - Part I'
date: 2026-01-20 13:00:00
categories: [Software Development, Utils]
tags: [python, cli, cat, coreutils, pyutils, unix, linux]
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

#### cat -E / --show-ends

This option simply puts the `"$"` character at the end of each line. 
This can be useful in certain scenarios like when dealing with non-printing characters so that end of line is easier to spot in the output.

#### cat -n / --number

As I already mentioned:

> -n / --number enumerates and displays line numbers for the complete output.

In other words, cat will print line numbers even for empty lines.

#### cat -s / --squeeze-blank

In cases when the input contains two or more consecutive blank lines the `-s` or `--squeeze-blank` 
option can be used to merge / squash / squeeze them into a single line to not waste the precious screen space.

#### cat -T / --show-tabs

The name of this option is explanatory enough. Whenever cat encounters a `TAB` character, 
instead of indenting the remainder of the text it will simply output `"^I"` instead.

#### cat -v / --show-nonprinting

This one I find the most interesting as it handles non-printing characters in a special way. If we have a look at the standard ASCII table [[2]] we'll find the following definitions:

| Characters (DEC) | Description |
| 0-31 | Non-printing characters which usually have special meaning related to peripherals. |
| 32-127 | Printable characters which denote alphanumeric values, punctuation marks and other. |
| 128-255   | Extended ASCII characters set.

Characters with high-bit (`0x80`) set will be printed in meta notation (`M-`) if the option for non-printing characters is set.

#### cat --help

Prints the help section which explains the usage and all the supported options.

#### cat --version

This option will print some standard information about current utility version, authors and similar.

#### Compounds options

Now we come back to the compund options that represent a combination of other options. 

- `-A` / `--show-all option` - Starting with `-A` / `--show-all option`, it gives the user a possibility to enable functionalities provided by options: `-v`, `-E`, `-T`. 
In other words this option will output file contents in such way that `"$"` signs are printed for line endings combined with `"^I"` 
as a replacement for `TAB` characters. It will also print the non-printing characters as explained earlier.

- `cat -e` - Similarly as the one above, this option will enable `"$"` signs for line endings combined with non-printing characters.

- `cat -t` - This one will simultaneously enable functionalities provided by `-v` and `-T` options to show non-printing characters in the output together with `TAB` characters displayed as `"^I"`.

## Conclusion

In this first part of the blog an overview of the `cat` command was given with explanations for each of the supported options.
In the second part I'll explain one way how to implement this utility by going through the implementation details of my own `cat` clone - `dog`.

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