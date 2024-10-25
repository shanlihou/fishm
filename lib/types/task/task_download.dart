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
  final String extensionName;
  final String comicId;
  final String chapterId;
  final String chapterName;
  final String comicTitle;
  double _progress = 0;

  @override
  double progress() {
    return _progress;
  }

  @override
  void reset() {
    _progress = 0;
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
      _progress = (i + 1) / detail.images.length;
      yield true;
    }
  }

  TaskDownload(
      {required super.id,
      required this.extensionName,
      required this.comicId,
      required this.chapterId,
      required this.chapterName,
      required this.comicTitle});
}
