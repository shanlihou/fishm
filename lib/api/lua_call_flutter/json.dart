import 'package:lua_dardo_co/lua.dart';
import 'dart:convert';
import '../../utils/lua_table.dart';

class JsonLib {
  static const Map<String, DartFunction> _jsonFuncs = {
    "encode": _jsonEncode,
    "decode": _jsonDecode,
  };

  static int openJsonLib(LuaState ls) {
    ls.newLib(_jsonFuncs);
    return 1;
  }

  static int _jsonEncode(LuaState ls) {
    LuaTable? json = ls.checkTable(-1);
    if (json == null) {
      return 0;
    }

    String jsonStr = const JsonEncoder().convert(fromLuaMap(json));

    ls.pushString(jsonStr);
    return 1;
  }

  static void _pushJsonMap(LuaState ls, Map<String, dynamic> json) {
    ls.newTable();
    json.forEach((key, value) {
      ls.pushString(key);
      if (value is String) {
        ls.pushString(value);
      } else if (value is int) {
        ls.pushInteger(value);
      } else if (value is double) {
        ls.pushNumber(value);
      } else if (value is bool) {
        ls.pushBoolean(value);
      } else if (value is Map<String, dynamic>) {
        _pushJsonMap(ls, value);
      } else {
        ls.pushNil();
      }
      ls.setTable(-3);
    });
  }

  static int _jsonDecode(LuaState ls) {
    String? jsonStr = ls.checkString(-1);
    if (jsonStr == null) {
      return 0;
    }

    Map<String, dynamic> json = const JsonDecoder().convert(jsonStr);
    _pushJsonMap(ls, json);
    return 1;
  }

}
