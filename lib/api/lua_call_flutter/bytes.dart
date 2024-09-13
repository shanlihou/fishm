import 'package:lua_dardo_co/lua.dart';
import 'dart:typed_data';

class BytesLib {
  static const Map<String, DartFunction> _bytesFuncs = {
    "hex": _hex,
    "len": _len,
    "fromhex": _fromHex,
  };

  static int openBytesLib(LuaState ls) {
    ls.newLib(_bytesFuncs);
    return 1;
  }

  static int _hex(LuaState ls) {
    Userdata ud = ls.toUserdata(1)!;
    if (ud.data is Uint8List) {
      Uint8List data = ud.data as Uint8List;
      StringBuffer sb = StringBuffer();
      for (int i = 0; i < data.length; i++) {
        sb.write(data[i].toRadixString(16).padLeft(2, '0'));
        sb.write(" ");
      }
      ls.pushString(sb.toString());
      return 1;
    } else {
      ls.pushNil();
      return 1;
    }
  }

  static int _fromHex(LuaState ls) {
    String hex = ls.checkString(1)!;
    hex = hex.replaceAll(RegExp(r'\s+'), '');
    if (hex.length % 2 != 0) {
      ls.pushNil();
      ls.pushString("invalid hex string");
      return 2;
    }
    Uint8List data = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      String byte = hex.substring(i, i + 2);
      data[i ~/ 2] = int.parse(byte, radix: 16);
    }
    Userdata ud = ls.newUserdata();
    ud.data = data;
    return 1;
  }

  static int _len(LuaState ls) {
    Userdata ud = ls.toUserdata(1)!;
    if (ud.data is Uint8List) {
      Uint8List data = ud.data as Uint8List;
      ls.pushInteger(data.length);
      return 1;
    } else {
      ls.pushNil();
      return 1;
    }
  }
}
