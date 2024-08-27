import 'package:lua_dardo_co/lua.dart';
import "../action.dart";


class Gallery extends Payload {

  Gallery();

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
  }

  static Action toAction(int retId, String plugin) {
    return Action('gallery', Gallery(), retId: retId, plugin: plugin);
  }
}


