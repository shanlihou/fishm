import 'package:lua_dardo_co/lua.dart';
import 'package:fishm/api/flutter_call_lua/action.dart';

class Search extends Payload {
  String keyword;
  int page;

  Search(this.keyword, this.page);

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('keyword');
    ls.pushString(keyword);
    ls.setTable(-3);
    ls.pushString('page');
    ls.pushInteger(page);
    ls.setTable(-3);
  }

  static Action toAction(int retId, String plugin, String keyword, int page) {
    return Action('search', Search(keyword, page),
        retId: retId, plugin: plugin);
  }
}
