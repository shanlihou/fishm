import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../const/assets_const.dart';
import '../../const/general_const.dart';
import '../../types/provider/comic_provider.dart';
import '../../types/provider/task_provider.dart';
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

      return Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: pm(20.spMin, 40.spMin)));
    } else if (status == ComicChapterStatus.loading) {
      return Icon(CupertinoIcons.hourglass, size: 60.w);
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
        addDownloadTask(comicProvider, taskProvider, widget.comicId,
            widget.extensionName, widget.chapterId, status);
      },
      child: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 10.w, 0),
          child: _buildIconAndText(status, comicProvider)),
    );
  }
}
