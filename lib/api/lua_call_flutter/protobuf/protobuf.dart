import 'package:lua_dardo_co/lua.dart';
import './state/pb_state.dart';
import './pb_slice.dart';
import './loader/pb_loader.dart';
import './loader/pb_fileinfo.dart';
import './pb_env.dart';
import './common/pb_buffer.dart';
import 'dart:typed_data';

class ProtobufLib {
  static const Map<String, DartFunction> _protobufFuncs = {
    "load": _load,
    "encode": _encode,
    "decode": _decode,
  };

  static int openProtobufLib(LuaState ls) {
    ls.newLib(_protobufFuncs);
    return 1;
  }

  static PbState getState(LuaState ls) {
    ls.getSubTable(luaRegistryIndex, '_PB_STATE');
    LuaType t = ls.getField(-1, 'state');
    if (t == LuaType.luaNil) {
      ls.pop(1);
      Userdata ud = ls.newUserdata();
      PbState state = PbState();
      ud.data = state;
      ls.setField(-2, 'state');
      ls.pop(1);
      return state;
    }
    else {
      Userdata ud = ls.toUserdata(-1)!;
      PbState state = ud.data as PbState;
      ls.pop(2);
      return state;
    }
  }

  static int _load(LuaState ls) {
    PbSlice slice = luaSlice(ls, 1)!;

    PbState state = getState(ls);
    PbLoader loader = PbLoader(slice, false);
    List<PbFileInfo> files = [];
    loader.fileDescriptorSet(files);
    loader.loadFile(state, files);

    ls.pushBoolean(true);
    ls.pushInteger(slice.pos() + 1);

    return 2;
  }

  static int _encode(LuaState ls) {
    PbEnv env = PbEnv(ls, getState(ls), PbBuffer(), PbSlice.empty());
    String typeName = ls.checkString(1)!;
    if (ls.type(2) != LuaType.luaTable) {
      throw Exception("pb encode table excepted");
    }

    var pt = env.ps.findType(typeName)!;
    ls.pushValue(2);
    env.encode(pt, -1);

    Userdata ud = ls.newUserdata();
    ud.data = env.b.toBytes();
    return 1;
  }

  static PbSlice? luaSlice(LuaState ls, int idx) {
    if (ls.type(idx) == LuaType.luaString) {
      String s = ls.checkString(idx)!;
      return PbSlice.fromString(s, 0, s.length);
    }
    else {
      Userdata ud = ls.toUserdata(idx)!;
      if (ud.data is Uint8List) {
        Uint8List data = ud.data as Uint8List;
        return PbSlice(data, 0, data.length);
      }
      else {
        return null;
      }
    }
  }

  static int _decode(LuaState ls) {
    String typeName = ls.checkString(1)!;
    PbSlice s = luaSlice(ls, 2)!;

    PbEnv env = PbEnv(ls, getState(ls), PbBuffer(), s);
    var t = env.ps.findType(typeName);

    ls.setTop(3);

    if (ls.type(3) != LuaType.luaTable) {
      ls.pop(1);

      env.ps.pushTypeTable(ls, t!);
    }

    env.dMessage(t!);
    return 1;
  }
}
