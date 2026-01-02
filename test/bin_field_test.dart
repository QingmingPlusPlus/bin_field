import 'dart:typed_data';
import 'package:bin_field/bin_field.dart';
import 'package:test/test.dart';

class TestMessage with ProtocolParser {
  @override
  final List<int> content;

  TestMessage(this.content);

  @override
  List<Field> get fields => [
        WordField(name: 'be_word'),
        DwordField(name: 'be_dword'),
        QwordField(name: 'be_qword'),
        FloatField(name: 'be_float'),
        StringField(name: 'str', length: 3),
        WordField(name: 'le_word', endian: Endian.little),
        DwordField(name: 'le_dword', endian: Endian.little),
        QwordField(name: 'le_qword', endian: Endian.little),
        FloatField(name: 'le_float', endian: Endian.little),
        StringField(name: 'le_str', length: 3, endian: Endian.little),
      ];
}

void main() {
  group('Endianness Tests', () {
    test('ProtocolParser handles mixed endian fields correctly', () {
      final data = [
        // Big Endian fields
        0x12, 0x34, // Word: 0x1234
        0x12, 0x34, 0x56, 0x78, // Dword: 0x12345678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
        0x08, // Qword: 0x0102030405060708
        0x41, 0x20, 0x00, 0x00, // Float: 10.0
        0x61, 0x62, 0x63, // String: abc

        // Little Endian fields
        0x34, 0x12, // Word: 0x1234
        0x78, 0x56, 0x34, 0x12, // Dword: 0x12345678
        0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02,
        0x01, // Qword: 0x0102030405060708
        0x00, 0x00, 0x20, 0x41, // Float: 10.0
        0x64, 0x65, 0x66, // String: def
      ];

      final msg = TestMessage(data);

      expect(msg.getValueByKey('be_word'), 0x1234);
      expect(msg.getValueByKey('be_dword'), 0x12345678);
      expect(msg.getValueByKey('be_qword'), 0x0102030405060708);
      expect(msg.getValueByKey('be_float'), 10.0);
      expect(msg.getValueByKey('str'), 'abc');

      expect(msg.getValueByKey('le_word'), 0x1234);
      expect(msg.getValueByKey('le_dword'), 0x12345678);
      expect(msg.getValueByKey('le_qword'), 0x0102030405060708);
      expect(msg.getValueByKey('le_float'), 10.0);
      expect(msg.getValueByKey('le_str'),
          'def'); // Strings should allow the parameter but likely ignore it for parsing logic implies just char codes
    });

    test('Individual Field classes handle endianness correctly', () {
      // WordField
      expect(WordField(name: 'be').getValue([0x12, 0x34]), 0x1234);
      expect(
          WordField(name: 'le', endian: Endian.little).getValue([0x34, 0x12]),
          0x1234);

      // DwordField
      expect(DwordField(name: 'be').getValue([0x12, 0x34, 0x56, 0x78]),
          0x12345678);
      expect(
          DwordField(name: 'le', endian: Endian.little)
              .getValue([0x78, 0x56, 0x34, 0x12]),
          0x12345678);

      // FloatField
      expect(FloatField(name: 'be').getValue([0x41, 0x20, 0x00, 0x00]), 10.0);
      expect(
          FloatField(name: 'le', endian: Endian.little)
              .getValue([0x00, 0x00, 0x20, 0x41]),
          10.0);
    });
  });
}
