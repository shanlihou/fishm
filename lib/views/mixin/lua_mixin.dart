import 'package:lua_dardo_co/lua.dart';
import '../../types/manager/actions.dart';
import '../../api/lua_call_flutter/http.dart';
import '../../api/lua_call_flutter/json.dart';
import '../../common/log.dart';

mixin LuaMixin {
  final LuaState ls = LuaState.newState();

  void initLua() {
    ls.openLibs();
    ls.requireF('dart_http', HttpLib.openHttpLib, true);
    ls.requireF('dart_json', JsonLib.openJsonLib, true);
    ls.pop(1);
    if (!ls.doFile("lua/main.lua")) {
      Log.instance.e("error: ${ls.toStr(-1)}");
      ls.pop(1);
    }
  }

  void loopOnce() {
    if (!actionsManager.hasActions()) return;

    ls.getGlobal('loop_once');
    actionsManager.toTableList(ls);
    if (ls.pCall(1, 1, 0) != ThreadStatus.luaOk) {
      Log.instance.e("error: ${ls.toStr(-1)}");
    }
    ls.pop(1);
  }
}
