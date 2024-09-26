import 'package:lua_dardo_co/lua.dart';
import "../action.dart";

class GetBaseVersion extends Payload {
  GetBaseVersion();

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
  }

  static Action toAction(int retId) {
    return Action('get_base_version', GetBaseVersion(),
        retId: retId, plugin: "");
  }
}
