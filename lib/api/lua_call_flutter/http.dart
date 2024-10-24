import 'dart:io';

import 'package:lua_dardo_co/lua.dart';
import 'package:dio/dio.dart';
import 'package:toonfu/utils/utils_general.dart';
import '../../common/log.dart';
import '../../types/manager/actions.dart';
import '../../types/manager/global_manager.dart';
import '../flutter_call_lua/payload/http_response.dart';
import '../../utils/lua_table.dart';
import 'dart:convert';

class HttpLib {
  static const Map<String, DartFunction> _httpFuncs = {
    "get": _httpGet,
    "post": _httpPost,
    "download": _httpDownload,
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
    ResponseType responseType,
  ) async {
    try {
      Dio dio = Dio();

      if (globalManager.enableProxy) {
        setDioProxy(globalManager.proxyHost, globalManager.proxyPort, dio);
      }

      var ret = await dio.get(
        url,
        queryParameters: query,
        options: Options(
          responseType: responseType,
          headers: headers,
        ),
      );

      String data;
      if (ret.data is List || ret.data is Map) {
        data = const JsonEncoder().convert(ret.data);
      } else {
        data = ret.data.toString();
      }

      int code = ret.statusCode ?? 0;

      actionsManager.addAction(HttpResponse.toAction(data, code, cbid));
    } catch (e) {
      Log.instance.e('get $url failed: $e');
      actionsManager.addAction(HttpResponse.toAction('failed', 0, cbid));
    }
  }

  static void _post(
    String url,
    int cbid,
    Map<String, dynamic> data,
    Map<String, dynamic> headers,
    ResponseType responseType,
  ) async {
    try {
      Dio dio = Dio();

      if (globalManager.enableProxy) {
        setDioProxy(globalManager.proxyHost, globalManager.proxyPort, dio);
      }

      dio.options = BaseOptions(
        headers: headers,
        responseType: responseType,
      );

      var ret = await dio.post(
        url,
        data: data,
        options: Options(responseType: responseType),
      );

      String response;
      if (ret.data is List || ret.data is Map) {
        response = const JsonEncoder().convert(ret.data);
      } else {
        response = ret.data.toString();
      }

      int code = ret.statusCode ?? 0;

      actionsManager.addAction(HttpResponse.toAction(response, code, cbid));
    } catch (e) {
      Log.instance.e('post $url failed: $e');
      actionsManager.addAction(HttpResponse.toAction('failed', 0, cbid));
    }
  }

  static int _httpPost(LuaState ls) {
    int cbid = ls.checkInteger(1)!;
    String url = ls.checkString(2)!;
    Map<String, dynamic> data = {};
    Map<String, dynamic> headers = {};
    ResponseType responseType = ResponseType.json;

    if (ls.type(3) == LuaType.luaTable) {
      if (ls.getField(3, 'data') == LuaType.luaTable) {
        data = fromLuaMap(ls.checkTable(-1)!);
      }
      ls.pop(1);

      if (ls.getField(3, 'headers') == LuaType.luaTable) {
        headers = fromLuaMap(ls.checkTable(-1)!);
      }
      ls.pop(1);

      if (ls.getField(3, 'responseType') == LuaType.luaString) {
        if (ls.checkString(-1) == 'json') {
          responseType = ResponseType.json;
        } else if (ls.checkString(-1) == 'plain') {
          responseType = ResponseType.plain;
        }
      }

      ls.pop(1);
    }

    _post(url, cbid, data, headers, responseType);

    return 0;
  }

  static int _httpGet(LuaState ls) {
    int? cbid = ls.checkInteger(1);
    String? url = ls.checkString(2);
    Map<String, dynamic> query = {};
    Map<String, dynamic> headers = {};
    ResponseType responseType = ResponseType.json;

    if (ls.type(3) == LuaType.luaTable) {
      if (ls.getField(3, 'query') == LuaType.luaTable) {
        query = fromLuaMap(ls.checkTable(-1)!);
      }

      ls.pop(1);

      if (ls.getField(3, 'headers') == LuaType.luaTable) {
        headers = fromLuaMap(ls.checkTable(-1)!);
      }

      ls.pop(1);

      if (ls.getField(3, 'responseType') == LuaType.luaString) {
        if (ls.checkString(-1) == 'json') {
          responseType = ResponseType.json;
        } else if (ls.checkString(-1) == 'plain') {
          responseType = ResponseType.plain;
        }
      }
      ls.pop(1);
    }

    if (cbid == null || url == null) {
      Log.instance.e('cbid is null');
      return 0;
    }

    _get(url, cbid, query, headers, responseType);
    return 0;
  }

  static Future<void> _downloadArchive(
    int cbid,
    String url,
    String downloadPath,
    Map<String, dynamic> headers,
  ) async {
    try {
      Dio dio = Dio();

      if (globalManager.enableProxy) {
        setDioProxy(globalManager.proxyHost, globalManager.proxyPort, dio);
      }

      var ret = await dio.get<ResponseBody>(url,
          options:
              Options(headers: headers, responseType: ResponseType.stream));

      if (ret.data == null) {
        Log.instance.e('download $url failed: response data is null');
        actionsManager.addAction(HttpResponse.toAction('failed', 0, cbid));
        return;
      }

      File file = File(downloadPath);
      await for (var res in ret.data!.stream) {
        await file.writeAsBytes(res);
      }

      int code = ret.statusCode ?? 0;
      actionsManager.addAction(HttpResponse.toAction('success', code, cbid));
    } catch (e) {
      Log.instance.e('download $url failed: $e');
      actionsManager.addAction(HttpResponse.toAction('failed', 0, cbid));
    }
  }

  static Future<void> _download(
    int cbid,
    String url,
    String downloadPath,
    Map<String, dynamic> headers,
  ) async {
    try {
      Dio dio = Dio();

      if (globalManager.enableProxy) {
        setDioProxy(globalManager.proxyHost, globalManager.proxyPort, dio);
      }

      var ret = await dio.download(url, downloadPath,
          options: Options(headers: headers));

      int code = ret.statusCode ?? 0;
      actionsManager.addAction(HttpResponse.toAction('success', code, cbid));
    } catch (e) {
      Log.instance.e('download $url failed: $e');
      actionsManager.addAction(HttpResponse.toAction('failed', 0, cbid));
    }
  }

  static int _httpDownload(LuaState ls) {
    int cbid = ls.checkInteger(1)!;
    String url = ls.checkString(2)!;
    String downloadPath = ls.checkString(3)!;
    Map<String, dynamic> headers = {};

    if (ls.type(4) == LuaType.luaTable) {
      if (ls.getField(4, 'headers') == LuaType.luaTable) {
        headers = fromLuaMap(ls.checkTable(-1)!);
      }
      ls.pop(1);
    }

    _download(cbid, url, downloadPath, headers);
    return 0;
  }
}
