import '../pb_slice.dart';


class PbFieldInfo {
  int packed = 0;
  PbSlice? name;
  int number = 0;
  int label = 0;
  int type = 0;
  PbSlice? typeName;
  PbSlice? extendee;
  PbSlice? defaultValue;
  int oneofIndex = 0;
}
