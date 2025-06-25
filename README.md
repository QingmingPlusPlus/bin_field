# bin_field

> ⚠️ **注意：本库仍处于开发阶段，API 可能随时变动。当前仅支持大端字节序（Big Endian）！**

`bin_field` 是一个用于二进制字段操作和协议解析的 Dart 库，适用于自定义二进制协议的解析、打包等场景。

## 特性
- 支持常见二进制字段类型（Byte、Word、Dword、Qword、Float、定长/变长/左补零字符串、C风格字符串等）
- 字段解析采用声明式方式，易于扩展
- 支持协议消息的自动解析与字段映射
- 仅支持大端字节序（Big Endian）

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  bin_field:
    git:
      url: <your_repo_url>
```

或待发布后：

```yaml
dependencies:
  bin_field: ^0.0.1
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
        ByteField(name: 'frame-type'),
        FloatField(name: 'float-demo-field'),
        WordField(name: 'word-demo-field'),
      ];
}

void main() {
  Uint8List data = Uint8List.fromList([
    0x44, 0x45, 0x4D, 0x4F, // "DEMO"
    0x01,                   // 帧类型
    0x41, 0x20, 0x00, 0x00, // 10.0f
    0x30, 0x39,             // 12345
  ]);
  final msg = DemoMessage(data);
  print(msg.getValueByKey('frame-header')); // DEMO
  print(msg.getValueMap());
}
```

## 字段类型
- `ByteField`：1字节无符号整数
- `WordField`：2字节无符号整数
- `DwordField`：4字节无符号整数
- `QwordField`：8字节无符号整数
- `FloatField`：4字节 IEEE 754 浮点数
- `StringField`：定长字符串
- `LeftPadStringField`：左补零定长字符串
- `VarStringField`：变长字符串（长度由前置字段指定）
- `CStringField`：C风格字符串（以\0结尾）

## 协议解析
通过实现 `ProtocolParser` mixin 并声明 `fields`，即可自动完成二进制数据的字段解析。

## 测试

```bash
dart test
```

## 注意事项
- 当前仅支持大端字节序（Big Endian），小端支持后续版本考虑。
- 本库仍在开发中，API 可能变动。

## License
MIT

---

# bin_field (English)

> ⚠️ **Note: This library is under active development. APIs may change at any time. Currently, only Big Endian byte order is supported!**

`bin_field` is a Dart library for binary field operations and protocol parsing, suitable for custom binary protocol parsing, packing, and similar scenarios.

## Features
- Supports common binary field types (Byte, Word, Dword, Qword, Float, fixed/variable/left-padded strings, C-style strings, etc.)
- Declarative field parsing, easy to extend
- Automatic protocol message parsing and field mapping
- Only supports Big Endian byte order

## Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  bin_field:
    git:
      url: <your_repo_url>
```

Or after release:

```yaml
dependencies:
  bin_field: ^0.0.1
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
        ByteField(name: 'frame-type'),
        FloatField(name: 'float-demo-field'),
        WordField(name: 'word-demo-field'),
      ];
}

void main() {
  Uint8List data = Uint8List.fromList([
    0x44, 0x45, 0x4D, 0x4F, // "DEMO"
    0x01,                   // frame type
    0x41, 0x20, 0x00, 0x00, // 10.0f
    0x30, 0x39,             // 12345
  ]);
  final msg = DemoMessage(data);
  print(msg.getValueByKey('frame-header')); // DEMO
  print(msg.getValueMap());
}
```

## Field Types
- `ByteField`: 1-byte unsigned integer
- `WordField`: 2-byte unsigned integer
- `DwordField`: 4-byte unsigned integer
- `QwordField`: 8-byte unsigned integer
- `FloatField`: 4-byte IEEE 754 float
- `StringField`: fixed-length string
- `LeftPadStringField`: left-padded fixed-length string
- `VarStringField`: variable-length string (length specified by a preceding field)
- `CStringField`: C-style string (null-terminated)

## Protocol Parsing
By implementing the `ProtocolParser` mixin and declaring `fields`, you can automatically parse binary data into fields.

## Testing

```bash
dart test
```

## Notes
- Only Big Endian byte order is supported for now. Little Endian support may be added in future versions.
- This library is under development and APIs may change.

## License
MIT
