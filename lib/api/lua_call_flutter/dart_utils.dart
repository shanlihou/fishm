import 'package:hive_flutter/hive_flutter.dart';
import 'package:lua_dardo_co/lua.dart';
import 'dart:io';

import 'package:toonfu/const/lua_const.dart';

import '../../common/log.dart';

class UtilsLib {
  static const Map<String, DartFunction> _utilsFuncs = {
    "cwd": _cwd,
    "main_dir": _mainDir,
    "plugin_dir": _pluginDir,
    "log": _log,
    "get_storage": _getStorage,
    "set_storage": _setStorage,
  };

  static int openUtilsLib(LuaState ls) {
    ls.newLib(_utilsFuncs);
    return 1;
  }

  static int _cwd(LuaState ls) {
    ls.pushString(Directory.current.path);
    return 1;
  }

  static int _mainDir(LuaState ls) {
    ls.pushString(mainDir);
    return 1;
  }

  static int _pluginDir(LuaState ls) {
    ls.pushString(pluginDir);
    return 1;
  }

  static int _log(LuaState ls) {
    String content = ls.checkString(1)!;
    Log.instance.i(content);
    return 0;
  }

  static int _getStorage(LuaState ls) {
    String plugin = ls.checkString(1)!;
    String key = ls.checkString(2)!;
    var box = Hive.box(plugin);
    String value = box.get(key, defaultValue: '');
    ls.pushString(value);
    return 1;
  }

  static int _setStorage(LuaState ls) {
    String plugin = ls.checkString(1)!;
    String key = ls.checkString(2)!;
    String value = ls.checkString(3)!;
    var box = Hive.box(plugin);
    box.put(key, value);
    return 0;
  }
}
