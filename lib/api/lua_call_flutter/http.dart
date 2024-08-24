import 'package:lua_dardo_co/lua.dart';
import 'package:dio/dio.dart';
import '../../common/log.dart';


class HttpLib {
  static const Map<String, DartFunction> _httpFuncs = {
    "get": _httpGet,
  };

  static int openHttpLib(LuaState ls) {
    ls.newLib(_httpFuncs);
    return 1;
  }

  static void _get(url) async {
    Dio dio = Dio();
    var ret = await dio.get(url);
    Log.instance.d("get $url: $ret");
  }

  static int _httpGet(LuaState ls) {
    String? url = ls.checkString(1);
    Log.instance.d('will get $url');
    _get(url);
    return 0;
  }
}
