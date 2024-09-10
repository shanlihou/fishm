import '../pb_slice.dart';
import './pb_fieldinfo.dart';
import './pb_enum_info.dart';

class PbTypeInfo {
  PbSlice? name;
  List<PbFieldInfo> field = [];
  List<PbFieldInfo> extension = [];
  List<PbTypeInfo> nestedType = [];
  List<PbEnumInfo> enumType = [];
  List<PbSlice> oneofDecl = [];
  int isMap = 0;
}
