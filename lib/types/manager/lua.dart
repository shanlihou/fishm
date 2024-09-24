import 'package:lua_dardo_co/lua.dart';
import 'package:toonfu/const/path.dart';
import 'dart:io';
import '../../types/manager/actions.dart';
import '../../api/lua_call_flutter/http.dart';
import '../../api/lua_call_flutter/json.dart';
import '../../api/lua_call_flutter/crypto.dart';
import '../../api/lua_call_flutter/bytes.dart';
import '../../api/lua_call_flutter/utils.dart';
import '../../api/lua_call_flutter/os_ext.dart';
import '../../api/lua_call_flutter/protobuf/protobuf.dart';
import '../../common/log.dart';
import '../../utils/lua_table.dart';
import './completer.dart';
import '../../const/lua_const.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';

class LuaManager {
  final LuaState ls = LuaState.newState();
  bool initOk = false;

  Future<void> downloadMainLua() async {
    // download repo zip and then unzip to code, the url is mainRelease
    Dio dio = Dio();
    await dio.download(mainRelease, mainReleaseDownloadPath);
    // unzip to code without first class folder
    final bytes = await File(mainReleaseDownloadPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      String filename = file.name;
      if (filename.contains('/')) {
        filename = filename.substring(filename.indexOf('/') + 1);
      }
      print(filename);
      if (file.isFile) {
        final data = file.content as List<int>;
        File('$mainDir/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }
  }

  Future<void> initLua() async {
    ls.openLibs();
    ls.requireF('dart_http', HttpLib.openHttpLib, true);
    ls.requireF('dart_json', JsonLib.openJsonLib, true);
    ls.requireF('dart_crypto', CryptoLib.openCryptoLib, true);
    ls.requireF('dart_bytes', BytesLib.openBytesLib, true);
    ls.requireF('dart_pb', ProtobufLib.openProtobufLib, true);
    ls.requireF('dart_utils', UtilsLib.openUtilsLib, true);
    ls.requireF('dart_os_ext', OsExtensionLib.openOsExtensionLib, true);
    ls.pop(1);
    // HookContext ctx = HookContext(1, 837, "protoc", () {
    //   Log.instance.i("hooked");
    // });
    // ls.setHook(ctx);
    // if (!ls.doFile("lua/main.lua")) {
    //   Log.instance.e("error: ${ls.toStr(-1)}");
    //   ls.pop(1);
    // }

    // judge if lua/main.lua exists
    if (!(await File('$mainDir/main.lua').exists())) {
      await downloadMainLua();
    }

    ls.loadString(
        """package.path = package.path .. ';./$mainDir/?.lua;./$mainDir/?/init.lua'""");
    ls.pCall(0, 0, 0);

    if (!ls.doFile("$mainDir/main.lua")) {
      Log.instance.e("error: ${ls.toStr(-1)}");
      ls.pop(1);
    }

    initOk = true;
  }

  void loopOnce() {
    if (!initOk) return;
    if (!actionsManager.hasActions()) return;

    ls.getGlobal('loop_once');
    actionsManager.toTableList(ls);
    if (ls.pCall(1, 1, 0) != ThreadStatus.luaOk) {
      Log.instance.e("error: ${ls.toStr(-1)}");
    } else {
      int idx = 1;
      while (ls.getI(-1, idx) != LuaType.luaNil) {
        LuaTable response = ls.checkTable(-1)!;

        Map<String, dynamic> map = fromLuaMap(response);

        int retId = map['retId'];

        completerManager.commplete(retId, map['data']);
        idx++;
        ls.pop(1);
      }
    }

    ls.pop(ls.getTop());
  }
}
