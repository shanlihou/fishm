import './pb_type.dart';
import './pb_field.dart';

class PbState {
  Map<String, int> nameTable = {};
  Map<String, PbType> types = {};
  bool encodeOrder = false;
  bool encodeDefaultValues = false;

  PbType newType(String name) {
    if (types.containsKey(name)) {
      return types[name]!;
    }

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
    PbField? f;
    if (type.fieldNames.containsKey(name)) {
      f = type.fieldNames[name]!;
    }

    if (type.fieldTags.containsKey(number)) {
      f = type.fieldTags[number]!;
    }

    f ??= PbField(type, name, number);

    type.fieldNames[name] = f;
    type.fieldTags[number] = f;
    return f;
  }
}
