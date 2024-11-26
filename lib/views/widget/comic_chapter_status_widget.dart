import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../const/assets_const.dart';
import '../../const/general_const.dart';
import '../../models/db/comic_model.dart';
import '../../types/provider/comic_provider.dart';
import '../../types/provider/task_provider.dart';
import '../../types/task/task_download.dart';
import '../../utils/utils_general.dart';

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

  Widget _buildIconAndText(
      ComicChapterStatus status, ComicProvider comicProvider) {
    if (status == ComicChapterStatus.downloaded) {
      return Image.asset(goToRead, width: 60.w, height: 60.h);
    } else if (status == ComicChapterStatus.downloading) {
      int cnt = getChapterImageCount(
          widget.extensionName, widget.comicId, widget.chapterId);
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
      return Image.asset(download2, width: 60.w, height: 60.h);
    }
  }

  @override
  Widget build(BuildContext context) {
    var comicProvider = context.watch<ComicProvider>();
    var taskProvider = context.watch<TaskProvider>();
    ComicChapterStatus status = getChapterStatus(comicProvider, taskProvider,
        widget.comicId, widget.extensionName, widget.chapterId);

    return GestureDetector(
      onTap: () {
        if (status == ComicChapterStatus.downloaded ||
            status == ComicChapterStatus.downloading) {
          return;
        }

        ComicModel? comicModel = comicProvider.getComicModel(
            getComicUniqueId(widget.comicId, widget.extensionName));
        if (comicModel == null) {
          return;
        }

        ChapterModel? chapterModel =
            comicModel.getChapterModel(widget.chapterId);
        if (chapterModel == null) {
          return;
        }

        var id =
            buildTaskId(widget.extensionName, widget.comicId, widget.chapterId);
        taskProvider.addTask(TaskDownload(
            id: id,
            extensionName: widget.extensionName,
            comicId: widget.comicId,
            chapterId: widget.chapterId,
            chapterName: chapterModel.title,
            comicTitle: comicModel.title,
            imageCount: chapterModel.images.length));
      },
      child: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 10.w, 0),
          child: _buildIconAndText(status, comicProvider)),
    );
  }
}
