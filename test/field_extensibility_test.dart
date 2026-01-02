import 'dart:typed_data';
import 'package:bin_field/bin_field.dart';
import 'package:test/test.dart';

// Custom Field definition
class CustomField extends Field {
  CustomField({required super.name, super.endian}) : super(length: 3);

  @override
  int getValue(List<int> data) {
    return 42; // Dummy implementation
  }
}

// Custom FieldType definition
class CustomFieldType implements FieldType {
  const CustomFieldType();

  @override
  Field create(String name,
      {int length = 0, String? lengthField, Endian endian = Endian.big}) {
    return CustomField(name: name, endian: endian);
  }
}

void main() {
  group('Field.create extensibility', () {
    test('Standard types work correctly', () {
      expect(
          Field.create(type: FieldType.byte, name: 'byte'), isA<ByteField>());
      expect(
          Field.create(type: FieldType.word, name: 'word'), isA<WordField>());
      expect(Field.create(type: FieldType.dword, name: 'dword'),
          isA<DwordField>());
      expect(Field.create(type: FieldType.qword, name: 'qword'),
          isA<QwordField>());
      expect(Field.create(type: FieldType.float, name: 'float'),
          isA<FloatField>());
      expect(Field.create(type: FieldType.string, name: 'string', length: 10),
          isA<StringField>());
      expect(
          Field.create(
              type: FieldType.leftPadString, name: 'leftPad', length: 10),
          isA<LeftPadStringField>());
      expect(
          Field.create(
              type: FieldType.varString, name: 'varString', lengthField: 'len'),
          isA<VarStringField>());
      expect(Field.create(type: FieldType.cString, name: 'cString'),
          isA<CStringField>());
    });

    test('Custom types work correctly', () {
      final customType = CustomFieldType();
      final field = Field.create(type: customType, name: 'custom');
      expect(field, isA<CustomField>());
      expect(field.length, 3);
      expect(field.getValue([]), 42);
    });
  });
}
