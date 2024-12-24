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

  static int _jsonDecode(LuaState ls) {
    String? jsonStr = ls.checkString(-1);

    Object json = const JsonDecoder().convert(jsonStr!);
    if (json is List) {
      pushJsonList(ls, json);
    } else if (json is Map<String, dynamic>) {
      pushJsonMap(ls, json);
    } else {
      ls.pushNil();
    }
    return 1;
  }
}
