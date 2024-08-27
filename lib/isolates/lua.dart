import 'package:lua_dardo_co/lua.dart';
import '../api/lua_call_flutter/http.dart';
import '../common/log.dart';
import '../types/manager/actions.dart';


LuaState initLua() {
  LuaState state = LuaState.newState();
  state.openLibs();
  state.requireF('dart_http', HttpLib.openHttpLib, true);
  state.pop(1);
  return state;
}

void luaLoop(void _) async {
  LuaState state = initLua();
  if (!state.doFile("lua/main.lua")) {
    Log.instance.e("error: ${state.toStr(-1)}");
    state.pop(1);
  }

  while (true) {
    if (actionsManager.hasActions()) {
      state.getGlobal('loop_once');
      actionsManager.toTableList(state);
      state.call(1, 1);
      state.pop(1);
    }

    await Future.delayed(const Duration(seconds: 1));
  }
}
