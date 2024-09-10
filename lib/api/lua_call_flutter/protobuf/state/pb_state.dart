import './pb_type.dart';
import './pb_field.dart';

class PbState {
  Map<String, int> nameTable = {};
  Map<String, PbType> types = {};
  bool encodeOrder = false;
  bool encodeDefaultValues = false;

  PbType newType(String name) {
    var type = PbType(name);
    types[name] = type;
    return type;
  }

  PbType? findType(String name) {
    if (!name.startsWith(".")) {
      return types[".$name"];
    }
    return types[name];
  }

  PbField newField(PbType type, String name, int number) {
    var field = PbField(type, name, number);
    type.fieldNames[name] = field;
    type.fieldTags[number] = field;
    return field;
  }
}
