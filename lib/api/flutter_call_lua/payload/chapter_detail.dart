import 'package:lua_dardo_co/lua.dart';
import '../../../utils/lua_table.dart';
import "../action.dart";

class ChapterDetail extends Payload {
  final String chapterId;
  final String comicId;
  final Map<String, dynamic> extra;

  ChapterDetail(this.chapterId, this.comicId, this.extra);

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('chapter_id');
    ls.pushString(chapterId);
    ls.setTable(-3);
    ls.pushString('comic_id');
    ls.pushString(comicId);
    ls.setTable(-3);
    ls.pushString('extra');
    pushJsonMap(ls, extra);
    ls.setTable(-3);
  }

  static Action toAction(int retId, String plugin, String chapterId,
      String comicId, Map<String, dynamic> extra) {
    return Action('chapter_detail', ChapterDetail(chapterId, comicId, extra),
        retId: retId, plugin: plugin);
  }
}
