import 'package:lua_dardo_co/lua.dart';
import "../action.dart";


class HttpResponse extends Payload {
  final String content;

  HttpResponse(this.content);

  @override
  void toLuaTable(LuaState ls) {
    ls.newTable();
    ls.pushString('content');
    ls.pushString(content);
    ls.setTable(-3);
  }

  static Action toAction(String content, int coId) {
    return Action('http_response', HttpResponse(content), coId: coId);
  }
}
