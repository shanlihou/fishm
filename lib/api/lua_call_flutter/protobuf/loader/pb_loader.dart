import '../pb_slice.dart';
import '../pb_const.dart';
import './pb_fileinfo.dart';
import './pb_typeinfo.dart';
import './pb_fieldinfo.dart';
import './pb_enum_value_info.dart';
import './pb_enum_info.dart';
import '../state/pb_state.dart';
import '../state/pb_type.dart';
import '../state/pb_oneof_entry.dart';
import '../state/pb_field.dart';
import '../common/pb_buffer.dart';


class PbLoader {
  PbSlice s;
  bool isProto3 = false;
  PbLoader(this.s, this.isProto3);
  final PbBuffer b = PbBuffer();

  PbSlice readbytes() {
    int sz;
    PbSlice newSlice;
    (newSlice, sz) = s.readbytes();

    if (sz == 0) {
      throw Exception('readbytes failed');
    }

    return newSlice;
  }

  PbSlice beginmsg() {
    PbSlice slice = readbytes();
    PbSlice backup = s;
    s = slice;
    return backup;
  }

  void endmsg(PbSlice backup) {
    s.reset(backup);
  }

  int readint32() {
    int sz;
    int val;
    (val, sz) = s.readvarint32();
    if (sz == 0) {
      throw Exception('readvarint32 failed');
    }

    return val;
  }

  void fieldOptions(PbFieldInfo fieldinfo) {
    int sz;
    int tag;
    PbSlice backup = beginmsg();
    while (true) {
      (tag, sz) = s.readvarint32();
      if (sz == 0) {
        break;
      }

      switch (tag) {
        case PB_PAIR_2_PB_TVARINT:
          fieldinfo.packed = readint32();
          break;
        default:
          if (s.skipvalue(tag) == 0) {
            throw Exception('fieldOptions skipvalue failed');
          }
      }
    }

    endmsg(backup);
  }

  int fieldDescriptorProto(PbFieldInfo fieldinfo) {
    int sz;
    int tag;
    PbSlice backup = beginmsg();
    fieldinfo.packed = -1;
    while (true) {
      (tag, sz) = s.readvarint32();
      if (sz == 0) {
        break;
      }

      switch (tag) {
        case PB_PAIR_1_PB_TBYTES:
          fieldinfo.name = readbytes();
          break;
        case PB_PAIR_3_PB_TVARINT:
          fieldinfo.number = readint32();
          break;
        case PB_PAIR_4_PB_TVARINT:
          fieldinfo.label = readint32();
          break;
        case PB_PAIR_5_PB_TVARINT:
          fieldinfo.type = readint32();
          break;
        case PB_PAIR_6_PB_TBYTES:
          fieldinfo.typeName = readbytes();
          break;
        case PB_PAIR_2_PB_TBYTES:
          fieldinfo.extendee = readbytes();
          break;
        case PB_PAIR_7_PB_TBYTES:
          fieldinfo.defaultValue = readbytes();
          break;
        case PB_PAIR_8_PB_TBYTES:
          fieldOptions(fieldinfo);
          break;
        case PB_PAIR_9_PB_TVARINT:
          fieldinfo.oneofIndex = readint32();
          ++fieldinfo.oneofIndex;
          break;
        default:
          if (s.skipvalue(tag) == 0) {
            throw Exception('fieldDescriptorProto skipvalue failed');
          }
      }
    }

    endmsg(backup);
    return PB_OK;
  }

  void enumDescriptorProto(PbEnumInfo info) {
    int tag;
    int sz;
    PbSlice backup = beginmsg();

    while (true) {
      (tag, sz) = s.readvarint32();
      if (sz == 0) {
        break;
      }

      switch (tag) {
        case PB_PAIR_1_PB_TBYTES:
          info.name = readbytes();
          break;
        case PB_PAIR_2_PB_TBYTES:
          info.value.add(PbEnumValueInfo());
          enumValueDescriptorProto(info.value.last);
          break;
        default:
          if (s.skipvalue(tag) == 0) {
            throw Exception('enumDescriptorProto skipvalue failed');
          }
      }
    }
    endmsg(backup);
  }


  void enumValueDescriptorProto(PbEnumValueInfo info) {
    int tag;
    int sz;
    PbSlice backup = beginmsg();

    while (true) {
      (tag, sz) = s.readvarint32();
      if (sz == 0) {
        break;
      }

      switch (tag) {
        case PB_PAIR_1_PB_TBYTES:
          info.name = readbytes();
          break;
        case PB_PAIR_2_PB_TVARINT:
          info.number = readint32();
          break;
        default:
          if (s.skipvalue(tag) == 0) {
            throw Exception('enumValueDescriptorProto skipvalue failed');
          }
      }
    }

    endmsg(backup);
  }


  void oneofDescriptorProto(PbTypeInfo info) {
    int tag;
    int sz;
    PbSlice backup = beginmsg();
    while (true) {
      (tag, sz) = s.readvarint32();
      if (sz == 0) {
        break;
      }
      switch (tag) {
        case PB_PAIR_1_PB_TBYTES:
          info.oneofDecl.add(readbytes());
          break;
        default:
          if (s.skipvalue(tag) == 0) {
            throw Exception('oneofDescriptorProto skipvalue failed');
          }
      }
    }
    endmsg(backup);
  }


  void messageOptions(PbTypeInfo info) {
    int tag;
    int sz;
    PbSlice backup = beginmsg();
    while (true) {
      (tag, sz) = s.readvarint32();
      if (sz == 0) {
        break;
      }
      switch (tag) {
        case PB_PAIR_7_PB_TVARINT:
          info.isMap = readint32();
          break;
        default:
          if (s.skipvalue(tag) == 0) {
            throw Exception('messageOptions skipvalue failed');
          }
      }
    }
    endmsg(backup);
  }

  int descriptorProto(PbTypeInfo typeinfo) {
    PbSlice backup = beginmsg();
    int tag;
    int sz;
    while (true) {
      (tag, sz) = s.readvarint32();
      if (sz == 0) {
        break;
      }

      switch (tag) {
        case PB_PAIR_1_PB_TBYTES:
          typeinfo.name = readbytes();
          break;
        case PB_PAIR_2_PB_TBYTES:
          typeinfo.field.add(PbFieldInfo());
          fieldDescriptorProto(typeinfo.field.last);
          break;
        case PB_PAIR_6_PB_TBYTES:
          typeinfo.extension.add(PbFieldInfo());
          fieldDescriptorProto(typeinfo.extension.last);
          break;
        case PB_PAIR_3_PB_TBYTES:
          typeinfo.nestedType.add(PbTypeInfo());
          descriptorProto(typeinfo.nestedType.last);
          break;
        case PB_PAIR_4_PB_TBYTES:
          typeinfo.enumType.add(PbEnumInfo());
          enumDescriptorProto(typeinfo.enumType.last);
          break;
        case PB_PAIR_8_PB_TBYTES:
          oneofDescriptorProto(typeinfo);
          break;
        case PB_PAIR_7_PB_TBYTES:
          messageOptions(typeinfo);
          break;
        default:
          if (s.skipvalue(tag) == 0) {
            throw Exception('descriptorProto skipvalue failed');
          }
      }
    }
    endmsg(backup);
    return PB_OK;
  }

  int fileDescriptorProto(PbFileInfo fileinfo) {
    PbSlice tmp;
    int ret;
    int sz;
    PbSlice backup = beginmsg();

    int tag;
    while (true) {
      (tag, sz) = s.readvarint32();
      if (sz == 0) {
        break;
      }

      switch (tag) {
        case PB_PAIR_2_PB_TBYTES:
          fileinfo.package = readbytes();
          break;
          case PB_PAIR_4_PB_TBYTES:
            fileinfo.messageType.add(PbTypeInfo());
            descriptorProto(fileinfo.messageType.last);
            break;
          case PB_PAIR_5_PB_TBYTES:
            fileinfo.enumType.add(PbEnumInfo());
            enumDescriptorProto(fileinfo.enumType.last);
            break;
          case PB_PAIR_7_PB_TBYTES:
            fileinfo.extension.add(PbFieldInfo());
            fieldDescriptorProto(fileinfo.extension.last);
            break;
          case PB_PAIR_12_PB_TBYTES:
            fileinfo.syntax = readbytes();
            break;
          default:
            if (s.skipvalue(tag) == 0) {
              throw Exception('fileDescriptorProto skipvalue failed');
            }
      }
    }

    endmsg(backup);
    return PB_OK;
  }

  int fileDescriptorSet(List<PbFileInfo> files) {
    int sz;
    int tag;
    while (true) {
      (tag, sz) = s.readvarint32();
      if (sz == 0) {
        break;
      }

      switch (tag) {
        case PB_PAIR_1_PB_TBYTES:
          files.add(PbFileInfo());
          fileDescriptorProto(files.last);
          break;
        default:
          if (s.skipvalue(tag) == 0) {
            throw Exception('fileDescriptorSet skipvalue failed');
          }
      }
    }
    return PB_OK;
  }


// static int pbL_loadFile(pb_State *S, pbL_FileInfo *info, pb_Loader *L) {
//     size_t i, count, j, jcount, curr = 0;
//     pb_Name *syntax;
//     pbCM(syntax = pb_newname(S, pb_slice("proto3"), NULL));
//     for (i = 0, count = pbL_count(info); i < count; ++i) {
//         if (info[i].package.p)
//             pbC(pbL_prefixname(S, info[i].package, &curr, L, NULL));
//         L->is_proto3 = (pb_name(S, info[i].syntax, NULL) == syntax);
//         for (j = 0, jcount = pbL_count(info[i].enum_type); j < jcount; ++j)
//             pbC(pbL_loadEnum(S, &info[i].enum_type[j], L));
//         for (j = 0, jcount = pbL_count(info[i].message_type); j < jcount; ++j)
//             pbC(pbL_loadType(S, &info[i].message_type[j], L));
//         for (j = 0, jcount = pbL_count(info[i].extension); j < jcount; ++j)
//             pbC(pbL_loadField(S, &info[i].extension[j], L, NULL));
//         L->b.size = (unsigned)curr;
//     }
//     return PB_OK;
// }

  int loadEnum(PbState ps, PbEnumInfo info) {
    int curLen = b.length();
    String preName = prefixName(info.name!)!;
    PbType t = ps.newType(preName);
    t.isEnum = true;
    for (int i = 0; i < info.value.length; i++) {
      PbEnumValueInfo cur = info.value[i];
      ps.newField(t, cur.name.toString(), cur.number);
    }
    b.resetLength(curLen);
    return PB_OK;
  }

  int loadField(PbState ps, PbFieldInfo info, PbType? t) {
    PbType? ft;
    if (info.type == PB_Tmessage || info.type == PB_Tenum) {
      ft = ps.newType(info.typeName!.toString());
    }

    t ??= ps.newType(info.extendee!.toString());

    PbField f = ps.newField(t, info.name!.toString(), info.number);

    f.defaultValue = info.defaultValue != null ? info.defaultValue!.toString() : "";
    f.type = ft;

    f.oneofIdx = info.oneofIndex;
    if (f.oneofIdx != 0) {
      ++t.oneofField;
    }

    f.typeId = info.type;
    f.repeated = info.label == PB_Lrepeated;
    f.packed = info.packed >= 0 ? info.packed : (isProto3 && f.repeated) ? 1 : 0;

    if (f.typeId >= 9 && f.typeId <= 12) {
      f.packed = 0;
    }

    f.scalar = f.type == null;
    return PB_OK;
  }

  int loadType(PbState ps, PbTypeInfo info) {
    int curLen = b.length();
    String preName = prefixName(info.name!)!;
    PbType t = ps.newType(preName);
    t.isMap = info.isMap != 0;
    t.isProto3 = isProto3;

    for (int i = 0; i < info.oneofDecl.length; i++) {
      // ps.newField(t, info.oneofDecl[i].toString(), 0);
      PbOneofEntry entry = PbOneofEntry(info.oneofDecl[i].toString(), i + 1);
      t.oneofIndex[entry.index] = entry;
    }

    for (int i = 0; i < info.field.length; i++) {
      loadField(ps, info.field[i], t);
    }

    for (int i = 0; i < info.extension.length; i++) {
      loadField(ps, info.extension[i], null);
    }

    for (int i = 0; i < info.enumType.length; i++) {
      loadEnum(ps, info.enumType[i]);
    }

    for (int i = 0; i < info.nestedType.length; i++) {
      loadType(ps, info.nestedType[i]);
    }

    t.oneofCount = info.oneofDecl.length;
    b.resetLength(curLen);
    return PB_OK;
  }

  String? prefixName(PbSlice s) {
    b.addString(".");
    b.addSlice(s);
    return b.bytesToString();
  }

  int loadFile(PbState ps, List<PbFileInfo> info) {
    for (int i = 0; i < info.length; i++) {
      PbFileInfo cur = info[i];
      isProto3 = cur.syntax != null && cur.syntax!.isSameString('proto3');
      int curLen = b.length();
      if (cur.package != null) {
        prefixName(cur.package!);
      }

      for (int j = 0; j < cur.enumType.length; j++) {
        loadEnum(ps, cur.enumType[j]);
      }

      for (int j = 0; j < cur.messageType.length; j++) {
        loadType(ps, cur.messageType[j]);
      }

      for (int j = 0; j < cur.extension.length; j++) {
        loadField(ps, cur.extension[j], null);
      }

      b.resetLength(curLen);
    }

    return PB_OK;
  }
  // int loadFile(PbFileInfo info) {
  //   int i, count, j, jcount, curr = 0;
  //   for (i = 0, count = info.enumType.length; i < count; ++i) {
  //     enumDescriptorProto(info.enumType[i]);
  //   }
  //
  //   for (i = 0, count = info.messageType.length; i < count; ++i) {
  //     descriptorProto(info.messageType[i]);
  //   }
  //
  //   for (i = 0, count = info.extension.length; i < count; ++i) {
  //     fieldDescriptorProto(info.extension[i]);
  //   }
  //
  //   return PB_OK;
  // }
}


