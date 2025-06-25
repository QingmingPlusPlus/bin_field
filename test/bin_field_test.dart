import 'package:bin_field/bin_field.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

// 测试用的消息类
class TestMessage with ProtocolParser {
  @override
  final List<int> content;
  TestMessage(this.content);

  @override
  List<Field> get fields => [
        StringField(length: 4, name: 'header'),
        ByteField(name: 'type'),
        WordField(name: 'length'),
        FloatField(name: 'value'),
        DwordField(name: 'timestamp'),
      ];
}

// 测试变长字符串的消息类
class VarStringMessage with ProtocolParser {
  @override
  final List<int> content;
  VarStringMessage(this.content);

  @override
  List<Field> get fields => [
        ByteField(name: 'str_length'),
        VarStringField(name: 'message', lengthField: 'str_length'),
      ];
}

// 测试C字符串的消息类
class CStringMessage with ProtocolParser {
  @override
  final List<int> content;
  CStringMessage(this.content);

  @override
  List<Field> get fields => [
        CStringField(name: 'text'),
        ByteField(name: 'flag'),
      ];
}

void main() {
  group('Field Tests', () {
    test('ByteField should parse single byte correctly', () {
      final field = ByteField(name: 'test');
      expect(field.getValue([0xFF]), equals(255));
      expect(field.getValue([0x00]), equals(0));
      expect(field.getValue([0x80]), equals(128));
    });

    test('ByteField should throw on empty data', () {
      final field = ByteField(name: 'test');
      expect(() => field.getValue([]), throwsException);
    });

    test('WordField should parse 2 bytes correctly (big endian)', () {
      final field = WordField(name: 'test');
      expect(field.getValue([0x12, 0x34]), equals(0x1234));
      expect(field.getValue([0xFF, 0xFF]), equals(0xFFFF));
      expect(field.getValue([0x00, 0x01]), equals(0x0001));
    });

    test('WordField should throw on insufficient data', () {
      final field = WordField(name: 'test');
      expect(() => field.getValue([0x12]), throwsException);
      expect(() => field.getValue([]), throwsException);
    });

    test('DwordField should parse 4 bytes correctly (big endian)', () {
      final field = DwordField(name: 'test');
      expect(field.getValue([0x12, 0x34, 0x56, 0x78]), equals(0x12345678));
      expect(field.getValue([0xFF, 0xFF, 0xFF, 0xFF]), equals(0xFFFFFFFF));
      expect(field.getValue([0x00, 0x00, 0x00, 0x01]), equals(0x00000001));
    });

    test('DwordField should throw on insufficient data', () {
      final field = DwordField(name: 'test');
      expect(() => field.getValue([0x12, 0x34, 0x56]), throwsException);
    });

    test('QwordField should parse 8 bytes correctly (big endian)', () {
      final field = QwordField(name: 'test');
      expect(field.getValue([0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0]),
          equals(0x123456789ABCDEF0));
    });

    test('FloatField should parse IEEE 754 float correctly', () {
      final field = FloatField(name: 'test');
      // 10.0f in big endian: 0x41200000
      final result = field.getValue([0x41, 0x20, 0x00, 0x00]);
      expect(result, closeTo(10.0, 0.001));
    });

    test('StringField should parse string correctly', () {
      final field = StringField(length: 4, name: 'test');
      expect(field.getValue([0x44, 0x45, 0x4D, 0x4F]), equals('DEMO'));
      expect(field.getValue([0x48, 0x65, 0x6C, 0x6C]), equals('Hell'));
    });

    test('LeftPadStringField should handle left-padded strings', () {
      final field = LeftPadStringField(length: 6, name: 'test');
      // "\0\0TEST"
      expect(
          field.getValue([0x00, 0x00, 0x54, 0x45, 0x53, 0x54]), equals('TEST'));
      // "HELLO!" (no padding)
      expect(field.getValue([0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x21]),
          equals('HELLO!'));
    });

    test('CStringField should handle null-terminated strings', () {
      final field = CStringField(name: 'test');
      expect(field.getValue([0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x00, 0x21]),
          equals('Hello'));
      expect(field.getValue([0x54, 0x65, 0x73, 0x74]),
          equals('Test')); // no null terminator
    });
  });

  group('Field Factory Tests', () {
    test('Field.create should create correct field types', () {
      expect(
          Field.create(type: FieldType.byte, name: 'test'), isA<ByteField>());
      expect(
          Field.create(type: FieldType.word, name: 'test'), isA<WordField>());
      expect(
          Field.create(type: FieldType.dword, name: 'test'), isA<DwordField>());
      expect(
          Field.create(type: FieldType.qword, name: 'test'), isA<QwordField>());
      expect(
          Field.create(type: FieldType.float, name: 'test'), isA<FloatField>());
      expect(Field.create(type: FieldType.string, name: 'test', length: 10),
          isA<StringField>());
      expect(
          Field.create(type: FieldType.leftPadString, name: 'test', length: 10),
          isA<LeftPadStringField>());
      expect(
          Field.create(
              type: FieldType.varString, name: 'test', lengthField: 'len'),
          isA<VarStringField>());
      expect(Field.create(type: FieldType.cString, name: 'test'),
          isA<CStringField>());
    });
  });

  group('ProtocolParser Tests', () {
    test('should parse complete message correctly', () {
      final data = Uint8List.fromList([
        // header: "TEST" (4 bytes)
        0x54, 0x45, 0x53, 0x54,
        // type: 0x01 (1 byte)
        0x01,
        // length: 0x1234 (2 bytes, big endian)
        0x12, 0x34,
        // value: 10.0f (4 bytes, big endian IEEE 754)
        0x41, 0x20, 0x00, 0x00,
        // timestamp: 0x12345678 (4 bytes, big endian)
        0x12, 0x34, 0x56, 0x78,
      ]);

      final message = TestMessage(data);

      expect(message.getValueByKey('header'), equals('TEST'));
      expect(message.getValueByKey('type'), equals(1));
      expect(message.getValueByKey('length'), equals(0x1234));
      expect(message.getValueByKey('value'), closeTo(10.0, 0.001));
      expect(message.getValueByKey('timestamp'), equals(0x12345678));
    });

    test('should return complete value map', () {
      final data = Uint8List.fromList([
        0x54, 0x45, 0x53, 0x54, // "TEST"
        0x01, // type
        0x12, 0x34, // length
        0x41, 0x20, 0x00, 0x00, // 10.0f
        0x12, 0x34, 0x56, 0x78, // timestamp
      ]);

      final message = TestMessage(data);
      final valueMap = message.getValueMap();

      expect(valueMap.keys.length, equals(5));
      expect(valueMap['header'], equals('TEST'));
      expect(valueMap['type'], equals(1));
      expect(valueMap['length'], equals(0x1234));
      expect(valueMap['value'], closeTo(10.0, 0.001));
      expect(valueMap['timestamp'], equals(0x12345678));
    });

    test('should handle variable length strings', () {
      final data = Uint8List.fromList([
        0x05, // str_length = 5
        0x48, 0x65, 0x6C, 0x6C, 0x6F, // "Hello"
      ]);

      final message = VarStringMessage(data);

      expect(message.getValueByKey('str_length'), equals(5));
      expect(message.getValueByKey('message'), equals('Hello'));
    });

    test('should handle C-style strings', () {
      final data = Uint8List.fromList([
        0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x00, // "Hello\0"
        0xFF, // flag
      ]);

      final message = CStringMessage(data);

      expect(message.getValueByKey('text'), equals('Hello'));
      expect(message.getValueByKey('flag'), equals(255));
    });

    test('should return null for non-existent keys', () {
      final data = Uint8List.fromList([0x01]);
      final message = TestMessage(data);

      expect(message.getValueByKey('non_existent'), isNull);
    });

    test('should handle insufficient data gracefully', () {
      final data = Uint8List.fromList([0x54, 0x45]); // only 2 bytes
      final message = TestMessage(data);

      // Should not throw, but fields that can't be parsed won't be in the map
      final valueMap = message.getValueMap();
      expect(valueMap.isEmpty, isTrue);
    });

    test('should not re-parse on multiple calls', () {
      final data = Uint8List.fromList([
        0x54, 0x45, 0x53, 0x54, // "TEST"
        0x01, // type
        0x12, 0x34, // length
        0x41, 0x20, 0x00, 0x00, // 10.0f
        0x12, 0x34, 0x56, 0x78, // timestamp
      ]);

      final message = TestMessage(data);

      // First call should parse
      final value1 = message.getValueByKey('header');
      // Second call should return cached result
      final value2 = message.getValueByKey('header');

      expect(value1, equals(value2));
      expect(value1, equals('TEST'));
    });
  });
}
