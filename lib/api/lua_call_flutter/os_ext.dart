import 'package:lua_dardo_co/lua.dart';
import 'dart:io';


class OsExtensionLib {
  static const Map<String, DartFunction> _osExtensionFuncs = {
    "listdir": _listdir,
    "isdir": _isdir,
  };

  static int openOsExtensionLib(LuaState ls) {
    ls.newLib(_osExtensionFuncs);
    return 1;
  }

  static int _listdir(LuaState ls) {
    String path = ls.checkString(1)!;
    Directory dir = Directory(path);
    if (!dir.existsSync()) {
      ls.pushNil();
      ls.pushString("directory not exists");
      return 2;
    }
    List<String> files = dir.listSync().map((e) => e.path).toList();
    ls.newTable();
    for (int i = 0; i < files.length; i++) {
      ls.pushString(files[i]);
      ls.rawSetI(-2, i + 1);
    }
    return 1;
  }

  static int _isdir(LuaState ls) {
    String path = ls.checkString(1)!;
    Directory dir = Directory(path);
    ls.pushBoolean(dir.existsSync());
    return 1;
  }
}
