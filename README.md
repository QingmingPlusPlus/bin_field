# bin_field
> ⚠️ **Note: This library is still under development, and the API may change at any time. Currently, only Big Endian is supported!**

> ⚠️ **注意：本库仍处于开发阶段，API 可能随时变动。当前仅支持大端字节序（Big Endian）！**

[English](./README.en.md) | [中文](./README.zh.md)

## Overview / 概述

`bin_field` is a Dart library for parsing binary data with a declarative approach. It allows you to define binary protocol structures using field definitions and automatically handle the parsing of binary messages into structured data. The library supports various field types including integers of different sizes (byte, word, dword, qword), floating-point numbers, fixed-length strings, variable-length strings, and null-terminated C-style strings, all in big-endian byte order.

`bin_field` 是一个用于以声明式方式解析二进制数据的 Dart 库。它允许您使用字段定义来描述二进制协议结构，并自动将二进制消息解析为结构化数据。该库支持多种字段类型，包括不同大小的整数（byte、word、dword、qword）、浮点数、固定长度字符串、变长字符串和以空字符结尾的 C 风格字符串，所有这些都采用大端字节序。

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