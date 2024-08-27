import 'package:lua_dardo_co/lua.dart';
import 'package:dio/dio.dart';
import '../../common/log.dart';
import '../../types/manager/actions.dart';
import '../flutter_call_lua/payload/http_response.dart';
import '../../utils/lua_table.dart';


class HttpLib {
  static const Map<String, DartFunction> _httpFuncs = {
    "get": _httpGet,
  };

  static int openHttpLib(LuaState ls) {
    ls.newLib(_httpFuncs);
    return 1;
  }

  static void _get(
      String url,
      int cbid,
      Map<String, dynamic> query,
      Map<String, dynamic> headers,
      ) async {
    Dio dio = Dio();
    var ret = await dio.get(
      url,
      queryParameters: query,
      options: Options(
        responseType: ResponseType.json,
        headers: headers,
      ),
    );
    actionsManager.addAction(HttpResponse.toAction(ret.toString(), cbid));
  }

  static int _httpGet(LuaState ls) {
    int? cbid = ls.checkInteger(1);
    String? url = ls.checkString(2);
    Map<String, dynamic> query = {};
    Map<String, dynamic> headers = {};

    if (ls.type(3) == LuaType.luaTable) {
      if (ls.getField(3, 'query') == LuaType.luaTable) {
        query = fromLuaMap(ls.checkTable(-1)!);
      }

      ls.pop(1);

      if (ls.getField(3, 'headers') == LuaType.luaTable) {
        headers = fromLuaMap(ls.checkTable(-1)!);
      }

      ls.pop(1);
    }

    if (cbid == null || url == null) {
      Log.instance.e('cbid is null');
      return 0;
    }

    Log.instance.d('will get $url');
    _get(url, cbid, query, headers);
    return 0;
  }
}
