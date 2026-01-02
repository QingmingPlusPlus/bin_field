# bin_field
> ⚠️ **Note: This library is still in development, API may change at any time.**


[English](./README.en.md) | [中文](./README.zh.md)

## Overview / 概述

`bin_field` is a Dart library for parsing binary data with a declarative approach. It allows you to define binary protocol structures using field definitions and automatically handle the parsing of binary messages into structured data.

## Key Features

- Support common binary field types (Byte, Word, Dword, Qword, Float, Fixed/Variable length String, C-style String, etc.)
- Declarative field parsing, easy to extend
- Automatic parsing of protocol messages and field mapping
- Support Big Endian and Little Endian configuration

`bin_field` 是一个用于以声明式方式解析二进制数据的 Dart 库。它允许您使用字段定义来描述二进制协议结构，并自动将二进制消息解析为结构化数据。该库支持多种字段类型，包括不同大小的整数（byte、word、dword、qword）、浮点数、固定长度字符串、变长字符串和以空字符结尾的 C 风格字符串。

## Key Features / 主要特性

- **Declarative API**: Define your binary protocol structure using field definitions
- **Multiple Data Types**: Support for various integer sizes, floating-point numbers, and string types
- **Flexible Parsing**: Handle fixed-length fields, variable-length fields, and null-terminated strings
- **Easy Integration**: Mix the `ProtocolParser` into your classes for automatic binary data parsing
- **Type-Safe Access**: Retrieve parsed values with their proper types

- **声明式 API**：使用字段定义描述您的二进制协议结构
- **多种数据类型**：支持各种大小的整数、浮点数和字符串类型
- **灵活的解析**：处理固定长度字段、变长字段和以空字符结尾的字符串
- **易于集成**：将 `ProtocolParser` 混入到您的类中，实现自动二进制数据解析
- **类型安全访问**：以正确的类型检索解析后的值