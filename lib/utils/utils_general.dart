import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yaml/yaml.dart';

import '../api/flutter_call_lua/method.dart';
import '../common/log.dart';
import '../const/general_const.dart';
import '../const/lua_const.dart';
import '../const/path.dart';
import '../models/api/chapter_detail.dart';
import '../models/db/comic_model.dart';
import '../models/db/extensions.dart' as model_extensions;
import '../types/common/alias.dart';
import '../types/manager/global_manager.dart';
import '../types/provider/comic_provider.dart';
import '../types/provider/task_provider.dart';
import '../types/task/task_download.dart';
import 'package:flutter/services.dart' show rootBundle;

void openAppSettings() {
  if (Platform.isAndroid) {}
}

Future<bool> getAndroidPermission() async {
  final DeviceInfoPlugin info =
      DeviceInfoPlugin(); // import 'package:device_info_plus/device_info_plus.dart';
  final AndroidDeviceInfo androidInfo = await info.androidInfo;
  var strVersion = androidInfo.version.release;
  Log.instance.d('releaseVersion string: $strVersion');
  if (strVersion.contains('.')) {
    strVersion = strVersion.split('.').first;
  }
  final int androidVersion = int.parse(strVersion);
  Log.instance.d('androidVersion int: $androidVersion');

  if (androidVersion >= 13) {
    final request = await [
      Permission.videos,
      Permission.photos,
      Permission.audio,
    ].request(); //import 'package:permission_handler/permission_handler.dart';

    return request.values.every((status) => status == PermissionStatus.granted);
  } else {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}

Future<bool> getStoragePermission() async {
  bool ret = true;
  if (Platform.isAndroid) {
    ret = await getAndroidPermission();
  } else {
    // TODO: check iOS permission
    return ret;
  }

  return ret;
}

List<String> osPathSplit(String path) {
  if (Platform.isWindows) {
    return path.split('\\');
  } else {
    return path.split('/');
  }
}

Future<bool> initDirectory() async {
  if (!await getStoragePermission()) {
    Log.instance.e("no storage permission");
    return false;
  }

  if (Platform.isAndroid) {
    var externalDir = await getExternalStorageDirectory();
    var applicationDir = await getApplicationDocumentsDirectory();
    Directory.current = externalDir ?? applicationDir;
    Log.instance.d('external: $externalDir, application: $applicationDir');
  } else if (Platform.isWindows) {
    // var externalDir = await getExternalStorageDirectory();
    // var applicationDir = await getApplicationDocumentsDirectory();
    // Log.instance.d('external: $externalDir, application: $applicationDir');
  } else if (Platform.isIOS) {
    final tempDir = await getTemporaryDirectory();
    Log.instance.d('Temporary directory: ${tempDir.path}');

    final appSupportDir = await getApplicationSupportDirectory();
    Log.instance.d('Application support directory: ${appSupportDir.path}');

    final appDocumentsDir = await getApplicationDocumentsDirectory();
    Log.instance.d('Application documents directory: ${appDocumentsDir.path}');
    Directory.current = appDocumentsDir;
  }

  Log.instance.d('external: ${Directory.current}');
  return true;
}

Future<bool> downloadMainLua() async {
  Dio dio = Dio();
  for (var url in mainRelease) {
    try {
      if (globalManager.enableProxy) {
        setDioProxy(globalManager.proxyHost, globalManager.proxyPort, dio);
      }
      await dio.download(url, mainYamlDownloadPath);
    } catch (e) {
      Log.instance.e('downloadMainLuaTmp down yaml error: $e');
      continue;
    }

    final mainContent = await File(mainYamlDownloadPath).readAsString();
    var doc = loadYaml(mainContent);
    for (var data in doc[yamlMainKey]) {
      try {
        await downloadMainLuaByUrl(data['url']);
        return true;
      } catch (e) {
        Log.instance.e('downloadMainLuaTmp down url: ${data['url']} error: $e');
        continue;
      }
    }
  }

  return false;
}

Future<void> downloadMainLuaByUrl(String mainUrl) async {
  // download repo zip and then unzip to code, the url is mainRelease
  Dio dio = Dio();
  await dio.download(mainUrl, mainReleaseDownloadPath);
  // unzip to code without first class folder
  final bytes = await File(mainReleaseDownloadPath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);
  for (final file in archive) {
    String filename = file.name;
    if (filename.contains('/')) {
      filename = filename.substring(filename.indexOf('/') + 1);
    }
    Log.instance.d('downloadMainLuaByUrl: $filename');
    if (file.isFile) {
      final data = file.content as List<int>;
      File('$mainDir/$filename')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }
}

Future<void> exportComicChapter(String sourceDir, String targetPath) async {
  final encoder = ZipFileEncoder();
  await encoder.zipDirectoryAsync(Directory(sourceDir), filename: targetPath);
}

bool isStartWithDot(String path) {
  List<String> pathes;
  if (Platform.isWindows) {
    pathes = path.split('\\');
  } else {
    pathes = path.split('/');
  }
  for (var p in pathes) {
    if (p.startsWith('.')) {
      return true;
    }
  }
  return false;
}

Future<void> copyDir(String source, String target) async {
  final sourceDir = Directory(source);
  final targetDir = Directory(target);

  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }

  await for (var entity in sourceDir.list(recursive: true)) {
    if (entity is File) {
      final relativePath = entity.path.substring(sourceDir.path.length + 1);

      String fullPath;
      if (Platform.isWindows) {
        fullPath = '${targetDir.path}\\$relativePath';
      } else {
        fullPath = '${targetDir.path}/$relativePath';
      }

      if (isStartWithDot(relativePath)) {
        continue;
      }

      final newFile = File(fullPath);
      if (await newFile.exists()) {
        await newFile.delete();
      }
      await newFile.create(recursive: true);
      await entity.copy(newFile.path);
    }
  }
}

Future<void> copyMainLuaLocal(String mainLuaDebugPath) async {
  await copyDir(mainLuaDebugPath, mainDir);
}

Future<bool> resetMainLua(String mainLuaDebugPath) async {
  if (mainLuaDebugPath.isEmpty) {
    return await downloadMainLua();
  } else {
    await copyMainLuaLocal(mainLuaDebugPath);
  }
  return true;
}

Future<void> initMainLua(String mainLuaDebugPath) async {
  if (!(await File('$mainDir/main.lua').exists())) {
    await resetMainLua(mainLuaDebugPath);
  }
}

int getTimestamp() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

String getComicUniqueId(String id, String extensionName) {
  return '$id-$extensionName';
}

int bitSet(int flags, int flag, bool value) {
  if (value) {
    return flags | (1 << flag);
  } else {
    return flags & ~(1 << flag);
  }
}

bool bitGet(int flags, int flag) {
  return (flags & (1 << flag)) != 0;
}

/// return 1 if version1 > version2, -1 if version1 < version2, 0 if version1 == version2
int judgeVersion(String version1, String version2) {
  var v1 = version1.split('.');
  var v2 = version2.split('.');
  if (v1.length != v2.length) {
    return v1.length - v2.length;
  }

  for (var i = 0; i < v1.length; i++) {
    if (int.parse(v1[i]) > int.parse(v2[i])) {
      return 1;
    } else if (int.parse(v1[i]) < int.parse(v2[i])) {
      return -1;
    }
  }

  return 0;
}

Future<void> _downloadExtension(model_extensions.Extension extension) async {
  Dio dio = Dio();
  Log.instance.d('downloadExtension: ${extension.url}');
  await dio.download(extension.url, tempExtDownloadPath);
  final bytes = await File(tempExtDownloadPath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);
  for (final file in archive) {
    String filename = file.name;
    if (filename.contains('/')) {
      filename = filename.substring(filename.indexOf('/') + 1);
    }
    if (file.isFile) {
      final data = file.content as List<int>;
      String fullPath = '$pluginDir/${extension.name}/$filename';
      Log.instance.d('downloadExtension: $fullPath');
      File(fullPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }
}

Future<void> _copyLocalExtension(model_extensions.Extension extension) async {
  await copyDir(extension.url, '$pluginDir/${extension.name}');
}

Future<model_extensions.Extension?> installExtension(
    model_extensions.Extension extension) async {
  try {
    if (extension.url.startsWith("http")) {
      await _downloadExtension(extension);
    } else {
      await _copyLocalExtension(extension);
    }
  } catch (s, e) {
    Log.instance.e('_installExtension error $extension: $e, stackTrace: $s');
    return null;
  }

  var clone = extension.clone();
  clone.status = extensionStatusInstalled;
  return clone;
}

Future<Exts> _loadRemoteExtensionsFromNet(String source) async {
  Exts extensions = [];
  Dio dio = Dio();
  await dio.download(source, tempSrcDownloadPath);
  final srcFileContent = await File(tempSrcDownloadPath).readAsString();
  Log.instance.d('srcFileContent: $srcFileContent');
  var doc = loadYaml(srcFileContent);
  for (var ext in doc[yamlExtensionKey]) {
    extensions.add(model_extensions.Extension.fromYaml(ext));
  }
  return extensions;
}

Future<Exts> _loadRemoteExtensionsFromFile(String path) async {
  Exts extensions = [];
  final srcFileContent = await File(path).readAsString();
  var doc = loadYaml(srcFileContent);
  for (var ext in doc[yamlExtensionKey]) {
    extensions.add(model_extensions.Extension.fromYaml(ext));
  }
  return extensions;
}

Future<Exts> loadRemoteExtensions(List<String> sources) async {
  Exts extensions = [];
  for (var src in sources) {
    try {
      if (src.startsWith('http')) {
        extensions = mergeExtensions(
            extensions, await _loadRemoteExtensionsFromNet(src));
      } else {
        extensions = mergeExtensions(
            extensions, await _loadRemoteExtensionsFromFile(src));
      }
    } catch (e, s) {
      Log.instance.e('_loadRemoteExtensions error $src: $e, stackTrace: $s');
    }
  }
  return extensions;
}

Exts mergeExtensions(Exts extensions1, Exts extensions2) {
  for (var ext in extensions2) {
    int index = extensions1.indexWhere((e) => e.name == ext.name);
    if (index != -1) {
      if (judgeVersion(extensions1[index].version, ext.version) < 0) {
        extensions1[index] = ext;
      }
    } else {
      extensions1.add(ext);
    }
  }
  return extensions1;
}

void setDioProxy(String proxyHost, int proxyPort, Dio dio) {
  if (proxyHost.isEmpty || proxyPort == 0) {
    return;
  }

  dio.httpClientAdapter = IOHttpClientAdapter()
    ..createHttpClient = () {
      HttpClient client = HttpClient();
      client.findProxy = (uri) {
        return 'PROXY $proxyHost:$proxyPort';
      };
      return client;
    };
}

Future<ChapterDetail?> getChapterDetails(ComicModel comicModel,
    String extensionName, String comicId, String chapterId) async {
  var detail = comicModel.getChapterDetail(chapterId);
  if (detail != null) {
    return detail;
  }

  var obj = await getChapterDetail(
      extensionName, chapterId, comicId, comicModel.extra);

  try {
    detail = ChapterDetail.fromJson(obj as Map<String, dynamic>);
  } catch (e) {
    Log.instance.e('getChapterDetails error $e');
    return null;
  }

  comicModel.addChapterDetail(chapterId, detail);
  return detail;
}

String getImageType(String url) {
  String imgType = url.split('.').last;
  if (imgType == 'jpg' || imgType == 'png' || imgType == 'webp') {
    return imgType;
  }
  return 'jpg';
}

String imageChapterFolder(
    String extensionName, String comicId, String chapterId) {
  return '$archiveImageDir/$extensionName/$comicId/$chapterId';
}

String downloadImagePath(String extensionName, String comicId, String chapterId,
    int index, String imageUrl) {
  return '${imageChapterFolder(extensionName, comicId, chapterId)}/$index.${getImageType(imageUrl)}';
}

bool isMobile() {
  return Platform.isIOS || Platform.isAndroid;
}

double pm(double pcValue, double mobileValue) {
  if (Platform.isIOS || Platform.isAndroid) {
    return mobileValue;
  }

  return pcValue;
}

String buildTaskId(String extensionName, String comicId, String chapterId) {
  return 'down_${extensionName}_${comicId}_$chapterId';
}

int getChapterImageCount(
    String extensionName, String comicId, String chapterId) {
  String folder = imageChapterFolder(extensionName, comicId, chapterId);
  Directory dir = Directory(folder);
  if (!dir.existsSync()) {
    return 0;
  }
  return dir.listSync().where((entity) {
    String path = entity.path.toLowerCase();
    return path.endsWith('.png') || path.endsWith('.jpg');
  }).length;
}

ComicChapterStatus getChapterStatus(
    ComicProvider comicProvider,
    TaskProvider taskProvider,
    String comicId,
    String extensionName,
    String chapterId) {
  ComicModel? comicModel =
      comicProvider.getComicModel(getComicUniqueId(comicId, extensionName));

  ChapterModel? chapterModel = comicModel!.getChapterModel(chapterId);
  if (chapterModel == null) {
    return ComicChapterStatus.loading;
  }

  if (chapterModel.images.isEmpty) {
    return ComicChapterStatus.loading;
  }

  int cnt = getChapterImageCount(extensionName, comicId, chapterId);
  if (cnt == chapterModel.images.length) {
    return ComicChapterStatus.downloaded;
  }

  var taskId = buildTaskId(extensionName, comicId, chapterId);
  if (taskProvider.isHasTask(taskId)) {
    return ComicChapterStatus.downloading;
  }

  return ComicChapterStatus.normal;
}

void addDownloadTask(
    ComicProvider comicProvider,
    TaskProvider taskProvider,
    String comicId,
    String extensionName,
    String chapterId,
    ComicChapterStatus? status) {
  status ??= getChapterStatus(
      comicProvider, taskProvider, comicId, extensionName, chapterId);

  if (status != ComicChapterStatus.normal) {
    return;
  }

  ComicModel? comicModel =
      comicProvider.getComicModel(getComicUniqueId(comicId, extensionName));

  ChapterModel? chapterModel = comicModel!.getChapterModel(chapterId);
  if (chapterModel == null) {
    return;
  }

  var id = buildTaskId(extensionName, comicId, chapterId);
  taskProvider.addTask(TaskDownload(
      id: id,
      extensionName: extensionName,
      comicId: comicId,
      chapterId: chapterId,
      chapterName: chapterModel.title,
      comicTitle: comicModel.title,
      imageCount: chapterModel.images.length));
}

Future<File> assetToFile(String assetPath, String writePath) async {
  final data = await rootBundle.load(assetPath);
  return File(writePath)
    ..writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

double vh(double horizontalValue, double verticalValue) {
  if (globalManager.isLandscape) {
    return horizontalValue;
  }

  return verticalValue;
}
