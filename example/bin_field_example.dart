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
  Uint8List simulatedBinaryData = Uint8List.fromList([
    // StringField(length: 4) - 4字节字符串 "DEMO"
    0x44, 0x45, 0x4D, 0x4F, // "DEMO"

    // ByteField - 1字节帧类型
    0x01, // 帧类型 = 1

    // FloatField - 4字节浮点数 (IEEE 754格式，大端序)
    0x41, 0x20, 0x00, 0x00, // 10.0f 的大端序表示

    // WordField(length: 2) - 2字节字 (大端序)
    0x30, 0x39, // 12345 的大端序表示 (高字节在前)
  ]);

  final message = DemoMessage(simulatedBinaryData);

  final frameHeader = message.getValueByKey('frame-header');
  print('Frame Header: $frameHeader'); // 输出: DEMO

  final frameType = message.getValueByKey('frame-type');
  print('Frame Type: $frameType'); // 输出: 1

  final floatDemoField = message.getValueByKey('float-demo-field');
  print('Float Demo Field: $floatDemoField'); // 输出: 10.0

  final wordDemoField = message.getValueByKey('word-demo-field');
  print('Word Demo Field: $wordDemoField'); // 输出: 12345

  final valMap = message.getValueMap();
  print(
      'Value Map: $valMap'); // 输出: {frame-header: DEMO, frame-type: 1, float-demo-field: 10.0, word-demo-field: 12345}
}
