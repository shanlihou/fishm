import 'package:lua_dardo_co/lua.dart';


abstract class Payload {
  void toLuaTable(LuaState ls);
}


class Action {
  final String type;
  final int retId; // flutter -> lua -> flutter #response id
  final int coId; // lua -> flutter -> lua #coroutine id
  final Payload payload;
  final String plugin;

  Action(this.type, this.payload, {this.retId = 0, this.coId = 0, this.plugin = ''});

  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('type');
    ls.pushString(type);
    ls.setTable(-3);
    ls.pushString('payload');
    payload.toLuaTable(ls);
    ls.setTable(-3);
    ls.pushString('plugin');
    ls.pushString(plugin);
    ls.setTable(-3);
    ls.pushString('retId');
    ls.pushInteger(retId);
    ls.setTable(-3);
    ls.pushString('coId');
    ls.pushInteger(coId);
    ls.setTable(-3);
  }
}
