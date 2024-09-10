import '../../types/manager/lua.dart';


mixin LuaMixin {
  final LuaManager luaManager = LuaManager();

  void initLua() {
    luaManager.initLua();
  }

  void loopOnce() {
    luaManager.loopOnce();
  }
}
