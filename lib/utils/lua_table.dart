import 'package:lua_dardo_co/lua.dart';

List<Object> fromLuaTable(LuaTable t) {
  List<Object> list = [];
  if (t.length() != 0) {
    for (int i = 1; i <= t.length(); i++) {
      Object? value = t.arr![i];
      if (value is String) {
        list.add(value);
      } else if (value is int) {
        list.add(value);
      } else if (value is double) {
        list.add(value);
      } else if (value is bool) {
        list.add(value);
      } else if (value is LuaTable) {
        list.add(fromLuaTable(value));
      }
    }
  }

  return list;
}

Map<String, dynamic> fromLuaMap(LuaTable t) {
  Map<String, dynamic> map = {};
  if (t.map == null) {
    return map;
  }

  t.map!.forEach((key, value) {
    if (value is String) {
      map[key as String] = value;
    } else if (value is int) {
      map[key as String] = value;
    } else if (value is double) {
      map[key as String] = value;
    } else if (value is bool) {
      map[key as String] = value;
    } else if (value is LuaTable) {
      if (value.length() != 0) {
        map[key as String] = fromLuaTable(value);
      }
      else {
        map[key as String] = fromLuaMap(value);
      }
    }
  });
  return map;
}
