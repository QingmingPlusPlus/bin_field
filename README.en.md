# bin_field

> ⚠️ **Note: This library is still under development, and the API may change at any time. Currently, only Big Endian is supported!**

[English](./README.en.md) | [中文](./README.zh.md)

`bin_field` is a Dart library for binary field operations and protocol parsing, suitable for scenarios such as parsing and packaging custom binary protocols.

## Features
- Supports common binary field types (Byte, Word, Dword, Qword, Float, fixed-length/variable-length/zero-padded strings, C-style strings, etc.)
- Field parsing adopts a declarative method, which is easy to expand
- Supports automatic parsing and field mapping of protocol messages
- Only supports Big Endian

## Installation

Add dependency in `pubspec.yaml`:

```bash
pub add bin_field
```

## Quick Start

```dart
import 'package:bin_field/bin_field.dart';
import 'dart:typed_data';

class DemoMessage with ProtocolParser {
  @override
  final List<int> content;
  DemoMessage(this.content);

  @override
  List<Field> get fields => [
        StringField(length: 4, name: 'frame-header'),
        ByteField(name: 'cmd-word'),
        DwordField(name: 'body-length'),
        StringField(lengthField: 'body-length', name: 'body'),
        CrcField(name: 'crc'),
      ];

  String get frameHeader => getValue('frame-header');
  int get cmdWord => getValue('cmd-word');
  int get bodyLength => getValue('body-length');
  String get body => getValue('body');
  int get crc => getValue('crc');
}

void main() {
  // Example message (hex): 4a 5a 59 4b 01 00 00 00 05 48 65 6c 6c 6f 33 c8
  final message = DemoMessage([
    0x4a, 0x5a, 0x59, 0x4b, 0x01, 0x00, 0x00, 0x00, 0x05, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x33, 0xc8
  ]);

  // Parse
  message.parse();

  // Access fields
  print('Frame Header: ${message.frameHeader}');
  print('CMD Word: ${message.cmdWord}');
  print('Body Length: ${message.bodyLength}');
  print('Body: ${message.body}');
  print('CRC: ${message.crc}');
}
```

## Custom Field Types

You can define your own field types by extending `Field` and `FieldType`.

```dart
// 1. Define your custom field
class MyCustomField extends Field {
  MyCustomField({required super.name, super.endian}) : super(length: 3);

  @override
  int getValue(List<int> data) {
    // Implement your parsing logic
    return 42; 
  }
}

// 2. Define the FieldType for it
class MyCustomFieldType implements FieldType {
  const MyCustomFieldType();

  @override
  Field create(String name,
      {int length = 0, String? lengthField, Endian endian = Endian.big}) {
    return MyCustomField(name: name, endian: endian);
  }
}

// 3. Use it with Field.create
class MyMessage with ProtocolParser {
   // ...
   @override
   List<Field> get fields => [
     Field.create(type: MyCustomFieldType(), name: 'custom'),
   ];
}
```

