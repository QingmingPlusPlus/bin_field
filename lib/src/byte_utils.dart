import 'dart:typed_data';

/// Converts a list of 4 bytes to an IEEE 754 single-precision floating point number.
///
/// This function converts 4 bytes in big-endian order to a floating point value
/// using the IEEE 754 single-precision format.
///
/// [bytes] A list of 4 bytes in big-endian order.
///
/// Returns the floating point value represented by the bytes.
///
/// Example:
/// ```dart
/// final bytes = [0x41, 0x20, 0x00, 0x00]; // Represents 10.0 in IEEE 754
/// final value = bytesToFloat(bytes); // Returns 10.0
/// ```
double bytesToFloat(List<int> bytes) {
  final byteData = ByteData(4);
  for (int i = 0; i < 4; i++) {
    byteData.setUint8(i, bytes[i]);
  }
  return byteData.getFloat32(0, Endian.big);
}
