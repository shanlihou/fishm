import 'package:lua_dardo_co/lua.dart';

import '../action.dart';

class GetConfigKeys extends Payload {
  GetConfigKeys();

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
  }

  static Action toAction(int retId, String plugin) {
    return Action('get_config', GetConfigKeys(), retId: retId, plugin: plugin);
  }
}
