import 'dart:async';
import "../../types/manager/completer.dart";
import "../../types/manager/actions.dart";
import "./payload/gallery.dart";
import "./payload/get_detail.dart";
import "./payload/chapter_detail.dart";
import "payload/download_image.dart";
import "payload/get_base_version.dart";
import "payload/get_config_keys.dart";
import "payload/search.dart";
import "payload/set_configs.dart";

Future<Object> gallery(String extensionName, int page) async {
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(Gallery.toAction(retId, extensionName, page));

  var completer = completerManager.addCompleter(
      retId, 'gallery ext:$extensionName page:$page');
  var ret = await completer.future;

  return ret;
}

Future<Object> getDetail(
    String extensionName, String comicId, Map<String, dynamic> extra) async {
  int retId = completerManager.genCompleteId();

  actionsManager
      .addAction(GetDetail.toAction(retId, extensionName, comicId, extra));

  var completer = completerManager.addCompleter(
      retId, 'getDetail ext:$extensionName comicId:$comicId');
  var ret = await completer.future;
  return ret;
}

Future<Object> getChapterDetail(String extensionName, String chapterId,
    String comicId, Map<String, dynamic> extra) async {
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(
      ChapterDetail.toAction(retId, extensionName, chapterId, comicId, extra));

  var completer = completerManager.addCompleter(retId,
      'getChapterDetail ext:$extensionName chapterId:$chapterId comicId:$comicId');
  var ret = await completer.future;
  return ret;
}

Future<Object> downloadImage(String extensionName, Map<String, dynamic> extra,
    String url, String downloadPath) async {
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(
      DownloadImage.toAction(retId, extensionName, extra, url, downloadPath));

  var completer = completerManager.addCompleter(retId,
      'downloadImage ext:$extensionName url:$url downloadPath:$downloadPath');
  var ret = await completer.future;
  return ret;
}

Future<Object> getBaseVersion() async {
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(GetBaseVersion.toAction(retId));

  var completer = completerManager.addCompleter(retId, 'getBaseVersion');
  var ret = await completer.future;
  return ret;
}

Future<Object> search(String extensionName, String keyword, int page) async {
  int retId = completerManager.genCompleteId();

  actionsManager
      .addAction(Search.toAction(retId, extensionName, keyword, page));

  var completer = completerManager.addCompleter(
      retId, 'search ext:$extensionName keyword:$keyword page:$page');
  var ret = await completer.future;
  return ret;
}

Future<Object> getConfigKeys(String extensionName) async {
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(GetConfigKeys.toAction(retId, extensionName));

  var completer =
      completerManager.addCompleter(retId, 'getConfigKeys ext:$extensionName');
  var ret = await completer.future;
  return ret;
}

Future<Object> setConfigs(
    String extensionName, Map<String, String> configs) async {
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(SetConfigs.toAction(retId, extensionName, configs));

  var completer = completerManager.addCompleter(
      retId, 'setConfigs ext:$extensionName configs:$configs');
  var ret = await completer.future;
  return ret;
}
