import 'byte_utils.dart';

enum FieldType {
  byte,
  word,
  dword,
  qword,
  float,
  string,
  leftPadString,
  varString,
  cString
}

abstract class Field {
  final int length;
  final String name;

  getValue(List<int> data);

  const Field({required this.length, required this.name});

  factory Field.create({
    required FieldType type,
    required String name,
    int length = 0,
    String? lengthField,
  }) {
    switch (type) {
      case FieldType.byte:
        return ByteField(name: name);
      case FieldType.word:
        return WordField(name: name);
      case FieldType.dword:
        return DwordField(name: name);
      case FieldType.qword:
        return QwordField(name: name);
      case FieldType.string:
        return StringField(name: name, length: length);
      case FieldType.leftPadString:
        return LeftPadStringField(name: name, length: length);
      case FieldType.varString:
        return VarStringField(name: name, lengthField: lengthField ?? '');
      case FieldType.cString:
        return CStringField(name: name);
      default:
        throw Exception('Unsupported field type');
    }
  }
}

class ByteField extends Field {
  ByteField({required super.name}) : super(length: 1);

  @override
  int getValue(List<int> data) {
    if (data.isEmpty) {
      throw Exception('Data is empty');
    }
    return data[0];
  }
}

class WordField extends Field {
  WordField({required super.name}) : super(length: 2);

  @override
  int getValue(List<int> data) {
    if (data.length < 2) {
      throw Exception('Data length is less than 2');
    }
    return (data[0] << 8) | data[1];
  }
}

class DwordField extends Field {
  DwordField({required super.name}) : super(length: 4);

  @override
  int getValue(List<int> data) {
    if (data.length < 4) {
      throw Exception('Data length is less than 4');
    }
    return (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
  }
}

class QwordField extends Field {
  QwordField({required super.name}) : super(length: 8);

  @override
  int getValue(List<int> data) {
    if (data.length < 8) {
      throw Exception('Data length is less than 8');
    }
    return (data[0] << 56) |
        (data[1] << 48) |
        (data[2] << 40) |
        (data[3] << 32) |
        (data[4] << 24) |
        (data[5] << 16) |
        (data[6] << 8) |
        data[7];
  }
}

class FloatField extends Field {
  FloatField({required super.name}) : super(length: 4);

  @override
  double getValue(List<int> data) {
    if (data.length < 4) {
      throw Exception('Data length is less than 4');
    }
    final bytes = data.sublist(0, 4);
    return bytesToFloat(bytes);
  }
}

class StringField extends Field {
  StringField({required super.length, required super.name});

  @override
  String getValue(List<int> data) {
    return String.fromCharCodes(data);
  }
}

class LeftPadStringField extends Field {
  LeftPadStringField({required super.length, required super.name});

  @override
  String getValue(List<int> data) {
    if (data.length < length) {
      throw Exception('Data length is less than expected');
    }
    //去除前面左补的0
    int start = data.indexWhere((byte) => byte != 0);
    if (start == -1) {
      start = 0;
    }
    final data_ = data.sublist(start);
    return String.fromCharCodes(data_);
  }
}

class VarStringField extends Field {
  final String lengthField; // 指定长度的字段名

  VarStringField({required super.name, required this.lengthField})
      : super(length: 0); // 初始长度为0，实际长度会在解析时根据lengthField确定

  @override
  String getValue(List<int> data) {
    // 实际的getValue逻辑将在ProtocolParser中处理
    // 因为这里不能访问到其他字段的值
    return String.fromCharCodes(data);
  }
}

class CStringField extends Field {
  CStringField({required super.name}) : super(length: 0); // 长度在解析时确定

  @override
  String getValue(List<int> data) {
    // 寻找结束符'\0'的位置
    int endIndex = data.indexOf(0);
    if (endIndex == -1) {
      // 如果没有找到结束符，使用整个数据
      endIndex = data.length;
    }
    return String.fromCharCodes(data.sublist(0, endIndex));
  }
}
