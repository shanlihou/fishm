import './pb_field.dart';
import './pb_oneof_entry.dart';

class PbType {
  String name;
  String basename = '';
  bool isEnum = false;
  Map<String, PbField> fieldNames = {};
  Map<int, PbField> fieldTags = {};
  bool isMap = false;
  bool isProto3 = false;
  Map<int, PbOneofEntry> oneofIndex = {};
  int oneofField = 0;
  int oneofCount = 0;

  PbType(this.name) {
    basename = name.split('.').last;
  }

  PbField? findField(String name) {
    return fieldNames[name];
  }
}
