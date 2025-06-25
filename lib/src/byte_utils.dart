import 'dart:typed_data';

double bytesToFloat(List<int> bytes) {
  final byteData = ByteData(4);
  for (int i = 0; i < 4; i++) {
    byteData.setUint8(i, bytes[i]);
  }
  return byteData.getFloat32(0, Endian.big);
}
