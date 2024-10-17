import 'package:lua_dardo_co/lua.dart';
import "../action.dart";

class Gallery extends Payload {
  int page;

  Gallery(this.page);

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('page');
    ls.pushInteger(page);
    ls.setTable(-3);
  }

  static Action toAction(int retId, String plugin, int page) {
    return Action('gallery', Gallery(page), retId: retId, plugin: plugin);
  }
}
