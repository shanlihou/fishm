import 'package:lua_dardo_co/lua.dart';

import '../../../utils/lua_table.dart';
import '../action.dart';

class SetConfigs extends Payload {
  final Map<String, String> configs;

  SetConfigs(this.configs);

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('configs');
    pushJsonMap(ls, configs);
    ls.setTable(-3);
  }

  static Action toAction(
      int retId, String plugin, Map<String, String> configs) {
    return Action('set_configs', SetConfigs(configs),
        retId: retId, plugin: plugin);
  }
}
