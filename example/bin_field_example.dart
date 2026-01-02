import 'package:bin_field/bin_field.dart';
import 'dart:typed_data';

// Custom Field definition
class CustomField extends Field {
  CustomField({required super.name, super.endian}) : super(length: 3);

  @override
  int getValue(List<int> data) {
    // Custom logic to parse 3 bytes
    if (data.length < 3) return 0;
    return (data[0] + data[1] + data[2]);
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

class DemoMessage with ProtocolParser {
  @override
  final List<int> content;
  DemoMessage(this.content);

  @override
  List<Field> get fields => [
        // Using standard types with Field.create
        Field.create(type: FieldType.string, length: 4, name: 'frame-header'),
        Field.create(type: FieldType.byte, name: 'frame-type'),
        Field.create(type: FieldType.float, name: 'float-demo-field'),
        Field.create(type: FieldType.word, name: 'word-demo-field'),
        // Using custom type with Field.create
        Field.create(type: CustomFieldType(), name: 'custom-field'),
      ];
}

void main() {
  Uint8List simulatedBinaryData = Uint8List.fromList([
    // StringField(length: 4) - 4 bytes "DEMO"
    0x44, 0x45, 0x4D, 0x4F, // "DEMO"

    // ByteField - 1 byte frame type
    0x01, // Type = 1

    // FloatField - 4 bytes float (IEEE 754, Big Endian)
    0x41, 0x20, 0x00, 0x00, // 10.0f

    // WordField(length: 2) - 2 bytes word (Big Endian)
    0x30, 0x39, // 12345

    // CustomField(length: 3) - 3 bytes
    0x01, 0x02, 0x03, // Sum = 6
  ]);

  final message = DemoMessage(simulatedBinaryData);

  final frameHeader = message.getValueByKey('frame-header');
  print('Frame Header: $frameHeader'); // Output: DEMO

  final frameType = message.getValueByKey('frame-type');
  print('Frame Type: $frameType'); // Output: 1

  final floatDemoField = message.getValueByKey('float-demo-field');
  print('Float Demo Field: $floatDemoField'); // Output: 10.0

  final wordDemoField = message.getValueByKey('word-demo-field');
  print('Word Demo Field: $wordDemoField'); // Output: 12345

  final customField = message.getValueByKey('custom-field');
  print('Custom Field: $customField'); // Output: 6

  final valMap = message.getValueMap();
  print('Value Map: $valMap');
}
