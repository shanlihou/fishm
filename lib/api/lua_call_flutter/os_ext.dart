import 'package:lua_dardo_co/lua.dart';
import 'dart:io';

import '../../types/manager/actions.dart';
import '../flutter_call_lua/payload/delay_reponse.dart';

class OsExtensionLib {
  static const Map<String, DartFunction> _osExtensionFuncs = {
    "listdir": _listdir,
    "isdir": _isdir,
    "delay": _delay,
    "now": _now,
    "get_duration_ms": _getDurationMs,
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

  static Future<void> _delayAsync(int ms, int cbid) async {
    await Future.delayed(Duration(milliseconds: ms));
    actionsManager.addAction(DelayResponse.toAction(cbid));
  }

  static int _delay(LuaState ls) {
    int? cbid = ls.checkInteger(1);
    int ms = ls.checkInteger(2)!;
    _delayAsync(ms, cbid!);
    return 0;
  }

  static int _now(LuaState ls) {
    var ud = ls.newUserdata();
    ud.data = DateTime.now();
    return 1;
  }

  static int _getDurationMs(LuaState ls) {
    var ud = ls.toUserdata(1);
    var now = DateTime.now();
    var duration = now.difference(ud?.data as DateTime);
    ls.pushInteger(duration.inMilliseconds);
    return 1;
  }
}
