
import 'package:lua_dardo_co/lua.dart';
import "../action.dart";

class ChapterDetail extends Payload {
  final int chapterId;
  final int comicId;

  ChapterDetail(this.chapterId, this.comicId);

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('chapter_id');
    ls.pushInteger(chapterId);
    ls.setTable(-3);
    ls.pushString('comic_id');
    ls.pushInteger(comicId);
    ls.setTable(-3);
  }

  static Action toAction(int retId, String plugin, int chapterId, int comicId) {
    return Action('chapter_detail', ChapterDetail(chapterId, comicId), retId: retId, plugin: plugin);
  }
}