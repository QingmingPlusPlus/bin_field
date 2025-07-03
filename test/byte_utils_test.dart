import 'package:test/test.dart';
import 'package:bin_field/src/byte_utils.dart';

void main() {
  group('bytesToFloat', () {
    test('converts IEEE 754 bytes to 10.0', () {
      final bytes = [0x41, 0x20, 0x00, 0x00]; // Represents 10.0 in IEEE 754
      expect(bytesToFloat(bytes), 10.0);
    });

    test('converts IEEE 754 bytes to 0.0', () {
      final bytes = [0x00, 0x00, 0x00, 0x00]; // Represents 0.0 in IEEE 754
      expect(bytesToFloat(bytes), 0.0);
    });

    test('converts IEEE 754 bytes to negative value', () {
      final bytes = [0xC2, 0x00, 0x00, 0x00]; // Represents -32.0 in IEEE 754
      expect(bytesToFloat(bytes), -32.0);
    });

    test('converts IEEE 754 bytes to PI', () {
      final bytes = [0x40, 0x49, 0x0F, 0xDB]; // Represents approx. 3.14159 in IEEE 754
      expect(bytesToFloat(bytes), closeTo(3.14159, 0.00001));
    });

    test('converts IEEE 754 bytes to small decimal', () {
      final bytes = [0x3F, 0x00, 0x00, 0x00]; // Represents 0.5 in IEEE 754
      expect(bytesToFloat(bytes), 0.5);
    });

    test('converts IEEE 754 bytes to NaN', () {
      final bytes = [0x7F, 0xC0, 0x00, 0x00]; // Represents NaN in IEEE 754
      expect(bytesToFloat(bytes).isNaN, true);
    });

    test('converts IEEE 754 bytes to Infinity', () {
      final bytes = [0x7F, 0x80, 0x00, 0x00]; // Represents Infinity in IEEE 754
      expect(bytesToFloat(bytes), double.infinity);
    });

    test('converts IEEE 754 bytes to negative Infinity', () {
      final bytes = [0xFF, 0x80, 0x00, 0x00]; // Represents negative Infinity in IEEE 754
      expect(bytesToFloat(bytes), double.negativeInfinity);
    });

    test('handles byte list with wrong length', () {
      // This is actually not handled in the current implementation
      // and would cause an error. We should consider adding validation.
      expect(() => bytesToFloat([0x41, 0x20, 0x00]), throwsA(isA<RangeError>()));
    });
  });
}
