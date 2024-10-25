import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../const/general_const.dart';
import '../../models/db/comic_model.dart';
import '../../types/provider/comic_provider.dart';
import '../../utils/utils_general.dart';

class ComicChapterStatusController {
  ValueChanged<ComicChapterStatus>? onChanged;

  void setStatus(ComicChapterStatus status) {
    onChanged?.call(status);
  }

  ComicChapterStatusController();
}

class ComicChapterStatusWidget extends StatefulWidget {
  final ComicChapterStatusController controller;
  final String extensionName;
  final String comicId;
  final String chapterId;

  const ComicChapterStatusWidget(
      {super.key,
      required this.controller,
      required this.extensionName,
      required this.comicId,
      required this.chapterId});

  @override
  State<ComicChapterStatusWidget> createState() =>
      _ComicChapterStatusWidgetState();
}

class _ComicChapterStatusWidgetState extends State<ComicChapterStatusWidget> {
  ComicChapterStatus _status = ComicChapterStatus.normal;

  @override
  void initState() {
    super.initState();
    widget.controller.onChanged = _onStatusChanged;
  }

  void _onStatusChanged(ComicChapterStatus status) {
    setState(() {
      _status = status;
    });
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

  @override
  Widget build(BuildContext context) {
    String text = '';
    ComicModel? comicModel = context
        .read<ComicProvider>()
        .getComicModel(getComicUniqueId(widget.comicId, widget.extensionName));
    if (comicModel != null) {
      ChapterModel? chapterModel = comicModel.getChapterModel(widget.chapterId);
      if (chapterModel != null) {
        int max = chapterModel.images.length;
        int cnt = _getImageCount();
        text = '$cnt/$max';
      }
    }
    return Text(text);
  }
}
