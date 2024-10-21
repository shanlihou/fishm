import 'package:lua_dardo_co/lua.dart';

import '../action.dart';

class DelayResponse extends Payload {
  DelayResponse();

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
  }

  static Action toAction(int cbid) {
    return Action('delay_response', DelayResponse(), coId: cbid);
  }
}
