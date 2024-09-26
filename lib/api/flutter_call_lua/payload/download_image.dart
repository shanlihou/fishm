import 'package:lua_dardo_co/lua.dart';
import "../action.dart";
import "../../../utils/lua_table.dart";

class DownloadImage extends Payload {
  final Map<String, dynamic> extra;
  final String url;
  final String downloadPath;

  DownloadImage(this.extra, this.url, this.downloadPath);

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('extra');
    pushJsonMap(ls, extra);
    ls.setTable(-3);
    ls.pushString('url');
    ls.pushString(url);
    ls.setTable(-3);
    ls.pushString('downloadPath');
    ls.pushString(downloadPath);
    ls.setTable(-3);
  }

  static Action toAction(int retId, String plugin, Map<String, dynamic> extra,
      String url, String downloadPath) {
    return Action('download_image', DownloadImage(extra, url, downloadPath),
        retId: retId, plugin: plugin);
  }
}
