import 'dart:typed_data';

import 'byte_utils.dart';

/// Defines the data types for binary fields.
///
/// Used in the [Field.create] factory method to specify the type of field to create.
enum FieldType {
  /// Represents a 1-byte integer field
  byte,

  /// Represents a 2-byte integer field
  word,

  /// Represents a 4-byte integer field
  dword,

  /// Represents an 8-byte integer field
  qword,

  /// Represents a 4-byte floating point field
  float,

  /// Represents a fixed-length string field
  string,

  /// Represents a left-padded fixed-length string field, usually for removing leading zeros
  leftPadString,

  /// Represents a variable-length string field where the length is determined by another field
  varString,

  /// Represents a null-terminated C-style string field
  cString
}

/// Abstract base class for binary fields.
///
/// All concrete field types inherit from this class and implement the [getValue] method
/// to extract specific types of values from byte data.
abstract class Field {
  /// The length of the field in bytes.
  ///
  /// For fixed-length fields, this is a constant value.
  /// For variable-length fields (like [CStringField] or [VarStringField]), this may initially be 0.
  final int length;

  /// The name of the field.
  ///
  /// Used to identify the field during parsing.
  final String name;

  /// The endianness of the field (Big Endian or Little Endian).
  final Endian endian;

  /// Extracts the field's value from raw byte data.
  ///
  /// [data] The byte array containing the data to parse.
  ///
  /// Returns the parsed value, type depends on the specific field implementation.
  getValue(List<int> data);

  /// Creates a field instance.
  ///
  /// [length] The length of the field in bytes.
  /// [name] The name of the field.
  /// [endian] The endianness of the field (default is Big Endian).
  const Field({
    required this.length,
    required this.name,
    this.endian = Endian.big,
  });

  /// Creates a field instance based on the specified type.
  ///
  /// This factory method simplifies the process of creating different types of fields.
  ///
  /// [type] The type of field to create, from the [FieldType] enum.
  /// [name] The name of the field.
  /// [length] The length of the field in bytes, only used for field types that require a specified length.
  /// [lengthField] For [VarStringField], specifies the name of the field that contains length information.
  /// [endian] The endianness of the field (default is Big Endian).
  ///
  /// Returns the created field instance.
  ///
  /// Throws an exception if an unsupported field type is specified.
  factory Field.create({
    required FieldType type,
    required String name,
    int length = 0,
    String? lengthField,
    Endian endian = Endian.big,
  }) {
    switch (type) {
      case FieldType.byte:
        return ByteField(name: name, endian: endian);
      case FieldType.word:
        return WordField(name: name, endian: endian);
      case FieldType.dword:
        return DwordField(name: name, endian: endian);
      case FieldType.qword:
        return QwordField(name: name, endian: endian);
      case FieldType.float:
        return FloatField(name: name, endian: endian);
      case FieldType.string:
        return StringField(name: name, length: length, endian: endian);
      case FieldType.leftPadString:
        return LeftPadStringField(name: name, length: length, endian: endian);
      case FieldType.varString:
        return VarStringField(
            name: name, lengthField: lengthField ?? '', endian: endian);
      case FieldType.cString:
        return CStringField(name: name, endian: endian);
    }
  }
}

/// Represents a 1-byte unsigned integer field.
///
/// Value range: 0-255
class ByteField extends Field {
  /// Creates a byte field.
  ///
  /// [name] The name of the field.
  /// [endian] The endianness of the field (default is Big Endian).
  ByteField({required super.name, super.endian}) : super(length: 1);

  @override

  /// Extracts a single byte value from the byte data.
  ///
  /// [data] Data containing at least 1 byte.
  ///
  /// Returns the first byte as an integer value.
  /// Throws an exception if the data is empty.
  int getValue(List<int> data) {
    if (data.isEmpty) {
      throw Exception('Data is empty');
    }
    return data[0];
  }
}

/// Represents a 2-byte unsigned integer (word) field.
///
/// Value range: 0-65535
/// Uses specified byte order.
class WordField extends Field {
  /// Creates a word field.
  ///
  /// [name] The name of the field.
  /// [endian] The endianness of the field (default is Big Endian).
  WordField({required super.name, super.endian}) : super(length: 2);

  @override

  /// Extracts a 2-byte integer value from the byte data.
  ///
  /// [data] Data containing at least 2 bytes.
  ///
  /// Returns a 16-bit integer value composed of the first two bytes according to endianness.
  /// Throws an exception if the data length is less than 2.
  int getValue(List<int> data) {
    if (data.length < 2) {
      throw Exception('Data length is less than 2');
    }
    if (endian == Endian.little) {
      return (data[1] << 8) | data[0];
    }
    return (data[0] << 8) | data[1];
  }
}

/// Represents a 4-byte unsigned integer (double word) field.
///
/// Value range: 0-4,294,967,295
/// Uses specified byte order.
class DwordField extends Field {
  /// Creates a double word field.
  ///
  /// [name] The name of the field.
  /// [endian] The endianness of the field (default is Big Endian).
  DwordField({required super.name, super.endian}) : super(length: 4);

  @override

  /// Extracts a 4-byte integer value from the byte data.
  ///
  /// [data] Data containing at least 4 bytes.
  ///
  /// Returns a 32-bit integer value composed of the first four bytes according to endianness.
  /// Throws an exception if the data length is less than 4.
  int getValue(List<int> data) {
    if (data.length < 4) {
      throw Exception('Data length is less than 4');
    }
    if (endian == Endian.little) {
      return (data[3] << 24) | (data[2] << 16) | (data[1] << 8) | data[0];
    }
    return (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
  }
}

/// Represents an 8-byte unsigned integer (quad word) field.
///
/// Value range: 0-18,446,744,073,709,551,615
/// Uses specified byte order.
class QwordField extends Field {
  /// Creates a quad word field.
  ///
  /// [name] The name of the field.
  /// [endian] The endianness of the field (default is Big Endian).
  QwordField({required super.name, super.endian}) : super(length: 8);

  @override

  /// Extracts an 8-byte integer value from the byte data.
  ///
  /// [data] Data containing at least 8 bytes.
  ///
  /// Returns a 64-bit integer value composed of the first eight bytes according to endianness.
  /// Throws an exception if the data length is less than 8.
  int getValue(List<int> data) {
    if (data.length < 8) {
      throw Exception('Data length is less than 8');
    }
    if (endian == Endian.little) {
      return (data[7] << 56) |
          (data[6] << 48) |
          (data[5] << 40) |
          (data[4] << 32) |
          (data[3] << 24) |
          (data[2] << 16) |
          (data[1] << 8) |
          data[0];
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

/// Represents a 4-byte IEEE 754 floating point field.
///
/// Uses the standard IEEE 754 single-precision format.
class FloatField extends Field {
  /// Creates a float field.
  ///
  /// [name] The name of the field.
  /// [endian] The endianness of the field (default is Big Endian).
  FloatField({required super.name, super.endian}) : super(length: 4);

  @override

  /// Extracts a floating point value from the byte data.
  ///
  /// [data] Data containing at least 4 bytes.
  ///
  /// Returns a double value converted from the IEEE 754 single-precision representation.
  /// Throws an exception if the data length is less than 4.
  double getValue(List<int> data) {
    if (data.length < 4) {
      throw Exception('Data length is less than 4');
    }
    final bytes = data.sublist(0, 4);
    return bytesToFloat(bytes, endian);
  }
}

/// Represents a fixed-length string field.
///
/// The string is decoded from the byte data using UTF-8 encoding.
class StringField extends Field {
  /// Creates a string field with a fixed length.
  ///
  /// [length] The fixed length of the string in bytes.
  /// [name] The name of the field.
  /// [endian] The endianness of the field (default is Big Endian).
  StringField({required super.length, required super.name, super.endian});

  @override

  /// Extracts a string value from the byte data.
  ///
  /// [data] The byte array containing the string data.
  ///
  /// Returns the string decoded from the byte data.
  String getValue(List<int> data) {
    return String.fromCharCodes(data);
  }
}

/// Represents a fixed-length string field with left padding.
///
/// This field type is used for strings that are padded with zeros on the left side.
/// When parsing, the leading zeros are removed before converting to a string.
class LeftPadStringField extends Field {
  /// Creates a left-padded string field with a fixed length.
  ///
  /// [length] The fixed length of the string in bytes, including padding.
  /// [name] The name of the field.
  /// [endian] The endianness of the field (default is Big Endian).
  LeftPadStringField(
      {required super.length, required super.name, super.endian});

  @override

  /// Extracts a string value from the byte data, removing leading zeros.
  ///
  /// [data] The byte array containing the string data with potential leading zeros.
  ///
  /// Returns the string decoded from the byte data after removing leading zeros.
  /// Throws an exception if the data length is less than the expected length.
  String getValue(List<int> data) {
    if (data.length < length) {
      throw Exception('Data length is less than expected');
    }
    // Remove leading zeros
    int start = data.indexWhere((byte) => byte != 0);
    if (start == -1) {
      start = 0;
    }
    final data_ = data.sublist(start);
    return String.fromCharCodes(data_);
  }
}

/// Represents a variable-length string field.
///
/// The length of this string is determined by another field in the protocol.
class VarStringField extends Field {
  /// The name of the field that specifies the length of this string.
  final String lengthField;

  /// Creates a variable-length string field.
  ///
  /// [name] The name of the field.
  /// [lengthField] The name of another field that contains the length of this string.
  /// [endian] The endianness of the field (default is Big Endian).
  VarStringField({required super.name, required this.lengthField, super.endian})
      : super(
            length:
                0); // Initial length is 0, actual length will be determined during parsing based on lengthField

  @override

  /// Extracts a string value from the byte data.
  ///
  /// [data] The byte array containing the string data.
  ///
  /// Returns the string decoded from the byte data.
  /// Note: The actual parsing logic will be handled in ProtocolParser,
  /// as this method cannot access the values of other fields.
  String getValue(List<int> data) {
    // The actual getValue logic will be handled in ProtocolParser
    // because we can't access other field values here
    return String.fromCharCodes(data);
  }
}

/// Represents a null-terminated C-style string field.
///
/// This field reads characters until a null terminator (byte value 0) is encountered.
/// The length of this field is determined during parsing by locating the null terminator.
class CStringField extends Field {
  /// Creates a C-style string field.
  ///
  /// [name] The name of the field.
  /// [endian] The endianness of the field (default is Big Endian).
  CStringField({required super.name, super.endian})
      : super(length: 0); // Length is determined during parsing

  @override

  /// Extracts a null-terminated string value from the byte data.
  ///
  /// [data] The byte array containing the string data with a null terminator.
  ///
  /// Returns the string decoded from the byte data up to the null terminator.
  /// If no null terminator is found, uses the entire data.
  String getValue(List<int> data) {
    // Find the position of the null terminator
    int endIndex = data.indexOf(0);
    if (endIndex == -1) {
      // If no null terminator is found, use the entire data
      endIndex = data.length;
    }
    return String.fromCharCodes(data.sublist(0, endIndex));
  }
}
