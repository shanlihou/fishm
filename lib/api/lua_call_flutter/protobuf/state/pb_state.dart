import 'package:lua_dardo_co/lua.dart';
import './pb_type.dart';
import './pb_field.dart';
import '../pb_const.dart';
import '../utils.dart';
import '../pb_slice.dart';

class PbState {
  Map<String, int> nameTable = {};
  Map<String, PbType> types = {};
  bool encodeOrder = false;
  bool encodeDefaultValues = false;
  int encodeMode = 0;
  PbType mapType = PbType("");
  PbType arrayType = PbType("");
  bool decodeDefaultArray = false;
  int defsIndex = 0;
  bool decodeDefaultMessage = false;
  bool enumAsValue = false;
  int int64Mode = 0;
  bool useDecHooks = false;

  PbState() {
    mapType.isDead = true;
    arrayType.isDead = true;
  }

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

  void pushDefTable(LuaState ls) {
    defsIndex = refTable(ls, defsIndex);
  }

  bool fetchTable(LuaState ls, PbField f, PbType t) {
    if (ls.getField(-1, f.name) == LuaType.luaNil) {
      ls.pop(1);
      ls.newTable();
      ls.pushValue(-1);
      ls.setField(-3, f.name);
    }

    if (t.isDead) {
      return true;
    }

    if (ls.getMetatable(-1)) {
      ls.pop(1);
    }
    else {
      pushDefMeta(ls, t);
      ls.setMetatable(-2);
    }
    return true;
  }

  bool pushDefField(LuaState ls, PbField? f, bool isProto3) {
    if (f == null) {
      return false;
    }
    PbType? type;
    bool ret = false;
    switch (f.typeId) {
      case PB_Tenum:
        if ((type = f.type) == null) {
          return false;
        }

        if ((f = type!.findField(f.defaultValue)) != null) {
          if (enumAsValue) {
            pushInteger(ls, f!.number, true, int64Mode);
          }
          else {
            ls.pushString(f!.name);
          }
          ret = true;
        }
        else if (isProto3) {
          if ((f = type.findFieldByTag(0)) == null || enumAsValue) {
            ls.pushInteger(0);
            ret = true;
          }
          else {
            ls.pushString(f!.name);
            ret = true;
          }
        }
        break;

      case PB_Tmessage:
        pushTypeTable(ls, f.type!);
        ret = true;
        break;

      case PB_Tbytes: case PB_Tstring:
        if (f.defaultValue.isNotEmpty) {
          ls.pushString(f.defaultValue);
          ret = true;
        }
        break;

      case PB_Tbool:
        if (f.defaultValue.isNotEmpty) {
          if (f.defaultValue == "true") {
            ls.pushBoolean(true);
            ret = true;
          }
          else if (f.defaultValue == "false") {
            ls.pushBoolean(false);
            ret = true;
          }
        }
        else if (isProto3) {
          ls.pushBoolean(false);
          ret = true;
        }
        break;

      case PB_Tdouble: case PB_Tfloat:
        if (f.defaultValue.isNotEmpty) {
          throw Exception("Not implemented");
        }
        else if (isProto3) {
          ls.pushNumber(0.0);
          ret = true;
        }
        break;

      case PB_Tuint64: case PB_Tuint32: case PB_Tfixed64: case PB_Tfixed32:
        continue defaultGoto;

      defaultGoto:
      default:
        if (f!.defaultValue.isNotEmpty) {
          throw Exception("Not implemented");
        }
        else if (isProto3) {
          ls.pushInteger(0);
          ret = true;
        }
        break;
    }

    return ret;
  }

  void readType(LuaState ls, int type, PbSlice s) {
    int len;
    int u;
    switch (type) {
      case PB_Tbool:  case PB_Tenum:
      case PB_Tint32: case PB_Tuint32: case PB_Tsint32:
      case PB_Tint64: case PB_Tuint64: case PB_Tsint64:
        (u, len) = s.readvarint64();
        if (len == 0) {
          throw Exception("invalid varint value at offset ${s.pos()}");
        }
        switch (type) {
          case PB_Tbool:
            ls.pushBoolean(u != 0); break;
          case PB_Tint32:
            pushInteger(ls, u, false, int64Mode); break;
          case PB_Tuint32:
            pushInteger(ls, u, true, int64Mode); break;
          case PB_Tsint32:
            pushInteger(ls, pbDecodeSint32(u), false, int64Mode); break;
          case PB_Tint64:
            pushInteger(ls, u, false, int64Mode); break;
          case PB_Tuint64:
            pushInteger(ls, u, true, int64Mode); break;
          case PB_Tsint64:
            pushInteger(ls, pbDecodeSint64(u), false, int64Mode); break;
        }
        break;

      case PB_Tfloat:
      case PB_Tfixed32:
      case PB_Tsfixed32:
        (u, len) = s.readfixed32();
        if (len == 0) {
          throw Exception("invalid fixed32 value at offset ${s.pos()}");
        }
        switch (type) {
          case PB_Tfloat:
            ls.pushNumber(pbDecodeFloat(u)); break;
          case PB_Tfixed32:
            pushInteger(ls, u, true, int64Mode); break;
          case PB_Tsfixed32:
            pushInteger(ls, u, false, int64Mode); break;
        }
        break;

      case PB_Tdouble:
      case PB_Tfixed64:
      case PB_Tsfixed64:
        (u, len) = s.readfixed64();
        if (len == 0) {
          throw Exception("invalid fixed64 value at offset ${s.pos()}");
        }
        switch (type) {
          case PB_Tdouble:
            ls.pushNumber(pbDecodeDouble(u)); break;
          case PB_Tfixed64:
            pushInteger(ls, u, true, int64Mode); break;
          case PB_Tsfixed64:
            pushInteger(ls, u, false, int64Mode); break;
        }
        break;

      case PB_Tbytes:
      case PB_Tstring:
      case PB_Tmessage:
        PbSlice sv;
        (sv, len) = s.readbytes();
        ls.pushString(sv.toString());
        break;
      default:
        throw Exception("unknown type $type");
    }
  }
  void setDefFields(LuaState ls, PbType t, int flags) {
    for (var f in t.fieldTags.values) {
      PbType fetchType = (f.type != null && f.type!.isMap) ? mapType : arrayType;
      bool hasField;
      if (f.repeated) {
        hasField = (flags & USE_REPEAT != 0) && (t.isProto3 || decodeDefaultArray)
            && (fetchTable(ls, f, fetchType) && true);
      }
      else {
        hasField =
            (f.oneofIdx == 0)
            && ((f.typeId != PB_Tmessage) ?
                    (flags & USE_FIELD != 0) :
                    ((flags & USE_MESSAGE != 0) && decodeDefaultMessage))
            && pushDefField(ls, f, t.isProto3);
      }

      if (hasField) {
        ls.setField(-2, f.name);
      }
    }
  }

  void pushDefMeta(LuaState ls, PbType t) {
    // throw Exception("Not implemented");
    pushDefTable(ls);
    if (ls.rawGetP(-1, t) != LuaType.luaTable) {
      ls.pop(1);
      ls.newTable();
      setDefFields(ls, t, USE_FIELD);
      ls.pushValue(-1);
      ls.setField(-2, "__index");
      ls.pushValue(-1);
      ls.rawSetP(-3, t);
    }
    ls.remove(-2);
  }

  void pushTypeTable(LuaState ls, PbType t) {
    int mode = encodeMode;
    ls.newTable();
    switch ((t.isProto3 && mode == LPB_DEFDEF) ? LPB_COPYDEF : mode) {
      case LPB_COPYDEF:
        setDefFields(ls, t, (USE_FIELD | USE_REPEAT | USE_MESSAGE));
        break;

      case LPB_METADEF:
        setDefFields(ls, t, (USE_REPEAT | USE_MESSAGE));
        pushDefMeta(ls, t);
        ls.setMetatable(-2);

      default:
        if (decodeDefaultArray || decodeDefaultMessage) {
          setDefFields(ls, t, (USE_REPEAT | USE_MESSAGE));
        }
        break;
    }
  }
}
