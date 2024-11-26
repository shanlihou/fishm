import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';
import '../../const/general_const.dart';
import '../../utils/utils_general.dart';
import '../provider/comic_provider.dart';
import 'task_base.dart';

class TaskDownload extends TaskBase {
  static const int taskType = taskTypeDownload;
  final String extensionName;
  final String comicId;
  final String chapterId;
  final String chapterName;
  final String comicTitle;
  final int imageCount;
  int currentCount;

  @override
  void reset() {
    currentCount = 0;
  }

  @override
  String displayText() {
    return '$chapterName - $comicTitle';
  }

  @override
  Stream<bool> run(BuildContext context) async* {
    var p = context.read<ComicProvider>();
    var comicModel =
        p.getHistoryComicModel(getComicUniqueId(comicId, extensionName));

    if (comicModel == null) {
      yield false;
      return;
    }

    var detail =
        await getChapterDetails(comicModel, extensionName, comicId, chapterId);

    if (detail == null) {
      yield false;
      return;
    }

    p.saveComic(comicModel);

    for (var i = 0; i < detail.images.length; i++) {
      var imageUrl = detail.images[i];
      var imagePath =
          downloadImagePath(extensionName, comicId, chapterId, i, imageUrl);
      if (File(imagePath).existsSync()) {
        continue;
      }

      bool success = false;
      for (var j = 0; j < downloadImageRetry; j++) {
        Log.instance.i('download image $imageUrl retry $j');
        var ret = await downloadImage(extensionName, {}, imageUrl, imagePath)
            as Map<String, dynamic>;

        if (ret['code'] == 200) {
          success = true;
          break;
        }
      }

      if (!success) {
        yield false;
        return;
      }
      currentCount = i + 1;
      yield true;
    }
  }

  @override
  int get taskTypeValue => taskType;

  @override
  String archive() {
    return jsonEncode({
      'extensionName': extensionName,
      'comicId': comicId,
      'chapterId': chapterId,
      'chapterName': chapterName,
      'comicTitle': comicTitle,
      'createTime': createTime?.toIso8601String(),
      'imageCount': imageCount,
      'currentCount': currentCount,
      'id': id,
      'status': status.index,
    });
  }

  static TaskDownload fromJsonString(String jsonString) {
    var json = jsonDecode(jsonString);
    var task = TaskDownload(
      id: json['id'],
      extensionName: json['extensionName'],
      comicId: json['comicId'],
      chapterId: json['chapterId'],
      chapterName: json['chapterName'],
      comicTitle: json['comicTitle'],
      imageCount: json['imageCount'] ?? 0,
      currentCount: json['currentCount'] ?? 0,
    );
    task.createTime = DateTime.parse(json['createTime']);
    task.status = TaskStatus.values[json['status']];
    return task;
  }

  TaskDownload(
      {required super.id,
      required this.extensionName,
      required this.comicId,
      required this.chapterId,
      required this.chapterName,
      required this.comicTitle,
      required this.imageCount,
      this.currentCount = 0});
}
