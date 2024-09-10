import 'package:lua_dardo_co/lua.dart';
import "../action.dart";


class HttpResponse extends Payload {
  final String content;
  final int code;

  HttpResponse(this.content, this.code);

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('content');
    ls.pushString(content);
    ls.setTable(-3);
    ls.pushString('code');
    ls.pushInteger(code);
    ls.setTable(-3);
  }

  static Action toAction(String content, int code, int coId) {
    return Action('http_response', HttpResponse(content, code), coId: coId);
  }
}
