import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../models/db/comic_model.dart';
import '../../types/provider/task_provider.dart';
import '../../types/task/task_download.dart';

class DownloadOptionsWidget extends StatelessWidget {
  final Map<String, (int, int)> chapterDownCnts;
  final ComicModel comicModel;

  const DownloadOptionsWidget(
      {super.key, required this.comicModel, required this.chapterDownCnts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: comicModel.chapters.length,
      itemBuilder: (context, index) {
        final chapter = comicModel.chapters[index];
        var p = context.watch<TaskProvider>();
        String id =
            'down_${comicModel.extensionName}_${comicModel.id}_${chapter.id}';

        Widget statusWidget;

        var (cnt, total) = chapterDownCnts[chapter.id] ?? (0, 0);

        if (cnt == total && cnt > 0) {
          statusWidget = const Icon(CupertinoIcons.checkmark_seal);
        } else if (p.isHasTask(id)) {
          statusWidget = const Icon(CupertinoIcons.cloud_download,
              color: CupertinoColors.systemRed);
        } else {
          statusWidget = CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              p.addTask(TaskDownload(
                  id: id,
                  extensionName: comicModel.extensionName,
                  comicId: comicModel.id,
                  chapterId: chapter.id,
                  chapterName: chapter.title,
                  comicTitle: comicModel.title));
            },
            child: const Icon(CupertinoIcons.cloud_download,
                color: CupertinoColors.systemGrey),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(chapter.title),
            statusWidget,
          ],
        );
      },
    );
  }
}
