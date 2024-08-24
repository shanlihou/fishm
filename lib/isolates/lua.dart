import 'dart:io';
import 'package:lua_dardo_co/lua.dart';
import '../api/lua_call_flutter/http.dart';
import '../common/log.dart';


LuaState initLua() {
  LuaState state = LuaState.newState();
  state.openLibs();
  state.requireF('http', HttpLib.openHttpLib, true);
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
    state.getGlobal('loop_once');

    state.pushString("im loop once data");
    state.call(1, 1);
    Log.instance.i(state.toStr(-1)!);
    state.pop(1);
    await Future.delayed(const Duration(seconds: 1));
  }
}
