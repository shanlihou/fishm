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

Future<Object> gallery(String extensionName, int page) async {
  Completer<Object> completer = Completer<Object>();
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(Gallery.toAction(retId, extensionName, page));

  completerManager.addCompleter(retId, completer);
  var ret = await completer.future;

  return ret;
}

Future<Object> getDetail(
    String extensionName, String comicId, Map<String, dynamic> extra) async {
  Completer<Object> completer = Completer<Object>();
  int retId = completerManager.genCompleteId();

  actionsManager
      .addAction(GetDetail.toAction(retId, extensionName, comicId, extra));

  completerManager.addCompleter(retId, completer);
  var ret = await completer.future;
  return ret;
}

Future<Object> getChapterDetail(String extensionName, String chapterId,
    String comicId, Map<String, dynamic> extra) async {
  Completer<Object> completer = Completer<Object>();
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(
      ChapterDetail.toAction(retId, extensionName, chapterId, comicId, extra));

  completerManager.addCompleter(retId, completer);
  var ret = await completer.future;
  return ret;
}

Future<Object> downloadImage(String extensionName, Map<String, dynamic> extra,
    String url, String downloadPath) async {
  Completer<Object> completer = Completer<Object>();
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(
      DownloadImage.toAction(retId, extensionName, extra, url, downloadPath));

  completerManager.addCompleter(retId, completer);
  var ret = await completer.future;
  return ret;
}

Future<Object> getBaseVersion() async {
  Completer<Object> completer = Completer<Object>();
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(GetBaseVersion.toAction(retId));

  completerManager.addCompleter(retId, completer);
  var ret = await completer.future;
  return ret;
}

Future<Object> search(String extensionName, String keyword, int page) async {
  Completer<Object> completer = Completer<Object>();
  int retId = completerManager.genCompleteId();

  actionsManager
      .addAction(Search.toAction(retId, extensionName, keyword, page));

  completerManager.addCompleter(retId, completer);
  var ret = await completer.future;
  return ret;
}

Future<Object> getConfigKeys(String extensionName) async {
  Completer<Object> completer = Completer<Object>();
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(GetConfigKeys.toAction(retId, extensionName));

  completerManager.addCompleter(retId, completer);
  var ret = await completer.future;
  return ret;
}
