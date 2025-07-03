import 'field.dart';

/// A mixin that provides binary protocol parsing capabilities.
///
/// This mixin automatically parses binary data according to a list of field
/// definitions. It supports various field types including fixed-length fields,
/// variable-length strings, and null-terminated strings.
///
/// Classes that use this mixin must implement [fields] and [content] getters.
mixin ProtocolParser {
  /// Indicates whether the binary data has been parsed.
  bool _hasParse = false;

  /// The list of field definitions that describe the protocol structure.
  ///
  /// Each [Field] in this list defines how to parse a specific part of the binary data.
  /// Fields are processed in order, and the parsed values are stored in the [_value] map.
  List<Field> get fields;

  /// The binary content to be parsed.
  ///
  /// This should contain the raw binary data of the protocol message.
  List<int> get content;

  /// Stores the parsed values, with field names as keys.
  final Map<String, dynamic> _value = {};

  /// Parses the binary content according to the field definitions.
  ///
  /// This method processes each field in order, extracting values from the binary
  /// content and storing them in the [_value] map. It handles special field types
  /// like [VarStringField] and [CStringField] with specific parsing logic.
  ///
  /// The parsing is done only once; subsequent calls will have no effect.
  void _parse() {
    // Don't parse more than once
    if (_hasParse) {
      return;
    }

    // Parse the data
    int offset = 0; // Current position in the binary data
    for (int i = 0; i < fields.length; i++) {
      Field field = fields[i];

      // Handle special field types
      if (field is VarStringField) {
        // Variable-length string: get the length from another field
        if (_value.containsKey(field.lengthField)) {
          final strLength = _value[field.lengthField];
          if (strLength is int && offset + strLength <= content.length) {
            final stringData = content.sublist(offset, offset + strLength);
            _value[field.name] = field.getValue(stringData);
            offset += strLength;
          } else {
            // Invalid length or insufficient data
            break;
          }
        } else {
          // Length field not found, skip this field
          continue;
        }
      }
      // Handle C-style strings
      else if (field is CStringField) {
        // C-style string: find the null terminator
        int endIndex = content.indexOf(0, offset);
        if (endIndex == -1) {
          // If no terminator is found, use all remaining data
          endIndex = content.length;
        }

        final stringData = content.sublist(offset, endIndex);
        _value[field.name] = field.getValue(stringData);

        // Move offset past the terminator
        offset = endIndex + 1;
      }
      // Handle standard fixed-length fields
      else {
        // Normal fixed-length field processing
        if (offset + field.length <= content.length) {
          final currentData = content.sublist(offset, offset + field.length);
          final value = field.getValue(currentData);
          _value[field.name] = value;

          offset += field.length; // Move to the next field
        } else {
          // Insufficient data to parse all fields
          break;
        }
      }
    }
    _hasParse = true; // Mark as parsed
  }

  /// Retrieves a parsed value by its field name.
  ///
  /// This method triggers parsing if it hasn't been done yet, then
  /// returns the value associated with the specified field name.
  ///
  /// [key] The name of the field to retrieve.
  ///
  /// Returns the parsed value for the specified field, or null if the field
  /// doesn't exist or couldn't be parsed.
  dynamic getValueByKey(String key) {
    if (!_hasParse) {
      _parse();
    }
    if (_value.containsKey(key)) {
      return _value[key];
    } else {
      return null;
    }
  }

  /// Returns a map of all parsed values.
  ///
  /// This method triggers parsing if it hasn't been done yet, then
  /// returns a map containing all the parsed field values, with field names as keys.
  ///
  /// Returns a map of field names to their parsed values.
  Map<String, dynamic> getValueMap() {
    if (!_hasParse) {
      _parse();
    }
    return _value;
  }
}
