# bin_field

> ⚠️ **注意：本库仍处于开发阶段，API 可能随时变动。**

[English](./README.en.md) | [中文](./README.zh.md)


`bin_field` 是一个用于二进制字段操作和协议解析的 Dart 库，适用于自定义二进制协议的解析、打包等场景。

## 特性
- 支持常见二进制字段类型（Byte、Word、Dword、Qword、Float、定长/变长/左补零字符串、C风格字符串等）
- 字段解析采用声明式方式，易于扩展
- 支持协议消息的自动解析与字段映射
- 支持大端序（Big Endian）和小端序（Little Endian）配置

## 安装

```bash
pub add bin_field
```

## 快速开始

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
  // 示例消息（16进制）: 4a 5a 59 4b 01 00 00 00 05 48 65 6c 6c 6f 33 c8
  final message = DemoMessage([
    0x4a, 0x5a, 0x59, 0x4b, 0x01, 0x00, 0x00, 0x00, 0x05, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x33, 0xc8
  ]);

  // 解析
  message.parse();

  // 访问字段
  print('Frame Header: ${message.frameHeader}');
  print('CMD Word: ${message.cmdWord}');
  print('Body Length: ${message.bodyLength}');
  print('Body: ${message.body}');
  print('CRC: ${message.crc}');
  print('CRC: ${message.crc}');
}

class LittleEndianMessage with ProtocolParser {
  @override
  final List<int> content;
  LittleEndianMessage(this.content);

  @override
  List<Field> get fields => [
        WordField(name: 'le-word', endian: Endian.little),
        DwordField(name: 'le-dword', endian: Endian.little),
      ];


  int get leWord => getValue('le-word');
  int get leDword => getValue('le-dword');
}
```

## 自定义字段类型

你可以通过继承 `Field` 和 `FieldType` 来定义自己的字段类型。

```dart
// 1. 定义你的自定义字段
class MyCustomField extends Field {
  MyCustomField({required super.name, super.endian}) : super(length: 3);

  @override
  int getValue(List<int> data) {
    // 实现你的解析逻辑
    return 42; 
  }
}

// 2. 定义对应的 FieldType
class MyCustomFieldType implements FieldType {
  const MyCustomFieldType();

  @override
  Field create(String name,
      {int length = 0, String? lengthField, Endian endian = Endian.big}) {
    return MyCustomField(name: name, endian: endian);
  }
}

// 3. 使用 Field.create 创建
class MyMessage with ProtocolParser {
   // ...
   @override
   List<Field> get fields => [
     Field.create(type: MyCustomFieldType(), name: 'custom'),
   ];
}
```

