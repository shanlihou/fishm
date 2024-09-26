import 'package:lua_dardo_co/lua.dart';
import "../action.dart";
import "../../../utils/lua_table.dart";

class GetDetail extends Payload {
  final String comicId;
  final Map<String, dynamic> extra;

  GetDetail(this.comicId, this.extra);

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('comic_id');
    ls.pushString(comicId);
    ls.setTable(-3);
    ls.pushString('extra');
    pushJsonMap(ls, extra);
    ls.setTable(-3);
  }

  static Action toAction(
      int retId, String plugin, String comicId, Map<String, dynamic> extra) {
    return Action('get_detail', GetDetail(comicId, extra),
        retId: retId, plugin: plugin);
  }
}
