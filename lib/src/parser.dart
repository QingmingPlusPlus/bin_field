import 'field.dart';

mixin ProtocolParser {
  bool _hasParse = false; // 是否已经解析过
  List<Field> get fields; // 宿主类的定义的字段解析规则
  List<int> get content; // 宿主类的数据
  final Map<String, dynamic> _value = {}; // 解析后的数据

  void _parse() {
    //不重复解析
    if (_hasParse) {
      return;
    }

    // 解析数据
    int offset = 0; // 数据偏移量
    for (int i = 0; i < fields.length; i++) {
      Field field = fields[i];

      // 处理特殊字段类型
      if (field is VarStringField) {
        // 变长字符串字段：获取指定的长度字段值
        if (_value.containsKey(field.lengthField)) {
          final strLength = _value[field.lengthField];
          if (strLength is int && offset + strLength <= content.length) {
            final stringData = content.sublist(offset, offset + strLength);
            _value[field.name] = field.getValue(stringData);
            offset += strLength;
          } else {
            // 长度无效或数据不足
            break;
          }
        } else {
          // 找不到指定的长度字段，跳过该字段
          continue;
        }
      }
      // 处理C风格字符串
      else if (field is CStringField) {
        // C风格字符串：查找终止符'\0'
        int endIndex = content.indexOf(0, offset);
        if (endIndex == -1) {
          // 如果没有找到终止符，使用剩余所有数据
          endIndex = content.length;
        }

        final stringData = content.sublist(offset, endIndex);
        _value[field.name] = field.getValue(stringData);

        // 移动偏移量（包括终止符）
        offset = endIndex + 1;
      }
      //处理普通字段
      else {
        // 正常固定长度字段处理
        if (offset + field.length <= content.length) {
          final currentData = content.sublist(offset, offset + field.length);
          final value = field.getValue(currentData);
          _value[field.name] = value;

          offset += field.length; // 移动偏移量到下一个字段
        } else {
          // 数据不足以解析完所有字段
          break;
        }
      }
    }
    _hasParse = true; // 标记为已解析
  }

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

  Map<String, dynamic> getValueMap() {
    if (!_hasParse) {
      _parse();
    }
    return _value;
  }
}
