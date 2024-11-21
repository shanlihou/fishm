import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../const/assets_const.dart';
import '../../models/db/comic_model.dart';
import '../../types/provider/comic_provider.dart';
import '../../types/provider/task_provider.dart';
import '../../types/task/task_download.dart';
import '../../utils/utils_general.dart';

enum ComicChapterStatus {
  loading,
  downloading,
  downloaded,
  normal,
}

class ComicChapterStatusWidget extends StatefulWidget {
  final String extensionName;
  final String comicId;
  final String chapterId;

  const ComicChapterStatusWidget(
      {super.key,
      required this.extensionName,
      required this.comicId,
      required this.chapterId});

  @override
  State<ComicChapterStatusWidget> createState() =>
      _ComicChapterStatusWidgetState();
}

class _ComicChapterStatusWidgetState extends State<ComicChapterStatusWidget> {
  @override
  void initState() {
    super.initState();
  }

  int _getImageCount() {
    String folder = imageChapterFolder(
        widget.extensionName, widget.comicId, widget.chapterId);
    Directory dir = Directory(folder);
    if (!dir.existsSync()) {
      return 0;
    }
    return dir.listSync().where((entity) {
      String path = entity.path.toLowerCase();
      return path.endsWith('.png') || path.endsWith('.jpg');
    }).length;
  }

  ComicChapterStatus _getChapterStatus(
      ComicProvider comicProvider, TaskProvider taskProvider) {
    ComicModel? comicModel = comicProvider
        .getComicModel(getComicUniqueId(widget.comicId, widget.extensionName));
    if (comicModel == null) {
      return ComicChapterStatus.loading;
    }

    ChapterModel? chapterModel = comicModel.getChapterModel(widget.chapterId);
    if (chapterModel == null) {
      return ComicChapterStatus.loading;
    }

    if (chapterModel.images.isEmpty) {
      return ComicChapterStatus.downloading;
    }

    int cnt = _getImageCount();
    if (cnt == chapterModel.images.length) {
      return ComicChapterStatus.downloaded;
    }

    var taskId =
        buildTaskId(widget.extensionName, widget.comicId, widget.chapterId);
    if (taskProvider.isHasTask(taskId)) {
      return ComicChapterStatus.downloading;
    }

    return ComicChapterStatus.normal;
  }

  Widget _buildIconAndText(
      ComicChapterStatus status, ComicProvider comicProvider) {
    if (status == ComicChapterStatus.normal) {
      return Row(
        children: [
          Image.asset(download2),
          Text(status.name),
        ],
      );
    } else if (status == ComicChapterStatus.downloading) {
      int cnt = _getImageCount();
      int total = comicProvider
              .getComicModel(
                  getComicUniqueId(widget.comicId, widget.extensionName))
              ?.getChapterModel(widget.chapterId)
              ?.images
              .length ??
          0;
      var text = '$cnt/$total';

      return Text(text);
    } else {
      return Text(status.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    var comicProvider = context.watch<ComicProvider>();
    var taskProvider = context.watch<TaskProvider>();
    ComicChapterStatus status = _getChapterStatus(comicProvider, taskProvider);

    return GestureDetector(
      onTap: () {
        if (status != ComicChapterStatus.normal) {
          return;
        }

        var id =
            buildTaskId(widget.extensionName, widget.comicId, widget.chapterId);
        taskProvider.addTask(TaskDownload(
            id: id,
            extensionName: widget.extensionName,
            comicId: widget.comicId,
            chapterId: widget.chapterId,
            chapterName: widget.chapterId,
            comicTitle: widget.comicId));
      },
      child: _buildIconAndText(status, comicProvider),
    );
  }
}
