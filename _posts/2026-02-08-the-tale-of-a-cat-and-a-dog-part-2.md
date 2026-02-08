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

#### Supported Arguments

#### Dog Configuration

### Input Reading

#### Reading From The Standard Input

#### Reading From A File

### Input Processing

#### Processor

#### Transformers

## Final Barks