import '../../types/manager/actions.dart';
import '../../types/manager/lua.dart';

mixin LuaMixin {
  final LuaManager luaManager = LuaManager();

  void initLua() {
    luaManager.initLua();
  }

  void loopOnce() {
    if (actionsManager.needResetMainLua) {
      actionsManager.needResetMainLua = false;
      luaManager.initLua();
      return;
    }

    luaManager.loopOnce();
  }
}
