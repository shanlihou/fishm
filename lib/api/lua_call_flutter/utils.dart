import 'package:lua_dardo_co/lua.dart';
import 'dart:io';


class UtilsLib {
  static const Map<String, DartFunction> _utilsFuncs = {
    "cwd": _cwd,
  };

  static int openUtilsLib(LuaState ls) {
    ls.newLib(_utilsFuncs);
    return 1;
  }

  static int _cwd(LuaState ls) {
    ls.pushString(Directory.current.path);
    return 1;
  }

}
