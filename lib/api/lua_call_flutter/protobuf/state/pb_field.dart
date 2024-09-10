import './pb_type.dart';

class PbField {
  String name;
  PbType? type;
  int number;
  String defaultValue = '';
  int oneofIdx = 0;
  int typeId = 0;
  bool repeated = false;
  int packed = 0;
  bool scalar = false;

  PbField(this.type, this.name, this.number);
}
