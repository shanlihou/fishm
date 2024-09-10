import 'package:lua_dardo_co/lua.dart';

class BytesLib {
  static const Map<String, DartFunction> _bytesFuncs = {
  };

  static int openBytesLib(LuaState ls) {
    ls.newLib(_bytesFuncs);
    return 1;
  }


}
