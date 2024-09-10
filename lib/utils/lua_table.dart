import 'package:lua_dardo_co/lua.dart';

List<Object> fromLuaTable(LuaTable t) {
  List<Object> list = [];
  if (t.length() != 0) {
    for (int i = 0; i < t.length(); i++) {
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
        if (value.length() != 0) {
          list.add(fromLuaTable(value));
        }
        else {
          list.add(fromLuaMap(value));
        }
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


void pushJsonList(LuaState ls, List<dynamic> list) {
  ls.newTable();
  for (int i = 0; i < list.length; i++) {
    ls.pushInteger(i + 1);
    if (list[i] is String) {
      ls.pushString(list[i]);
    } else if (list[i] is int) {
      ls.pushInteger(list[i]);
    } else if (list[i] is double) {
      ls.pushNumber(list[i]);
    } else if (list[i] is bool) {
      ls.pushBoolean(list[i]);
    } else if (list[i] is List) {
      pushJsonList(ls, list[i]);
    } else if (list[i] is Map<String, dynamic>) {
      pushJsonMap(ls, list[i]);
    } else {
      ls.pushNil();
    }
    ls.setTable(-3);
  }
}

void pushJsonMap(LuaState ls, Map<String, dynamic> json) {
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
      pushJsonMap(ls, value);
    } else if (value is List) {
      pushJsonList(ls, value);
    } else {
      ls.pushNil();
    }
    ls.setTable(-3);
  });
}

