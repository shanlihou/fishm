import '../pb_slice.dart';
import './pb_typeinfo.dart';
import './pb_enum_info.dart';
import './pb_fieldinfo.dart';

class PbFileInfo {
  PbSlice? package;
  List<PbTypeInfo> messageType = [];
  List<PbEnumInfo> enumType = [];
  List<PbFieldInfo> extension = [];
  PbSlice? syntax;
}
