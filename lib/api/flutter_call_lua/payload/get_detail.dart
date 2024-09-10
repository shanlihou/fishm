import 'package:lua_dardo_co/lua.dart';
import "../action.dart";
import "../../../utils/lua_table.dart";


class GetDetail extends Payload {
  Map<String, dynamic> extra;

  GetDetail(this.extra);

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('extra');
    pushJsonMap(ls, extra);
    ls.setTable(-3);
  }

  static Action toAction(int retId, String plugin, Map<String, dynamic> extra) {
    return Action('get_detail', GetDetail(extra), retId: retId, plugin: plugin);
  }
}


