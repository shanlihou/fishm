import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../models/db/comic_model.dart';
import '../../types/provider/task_provider.dart';
import '../../types/task/task_download.dart';

class DownloadOptionsWidget extends StatefulWidget {
  final ComicModel comicModel;

  const DownloadOptionsWidget({super.key, required this.comicModel});

  @override
  State<DownloadOptionsWidget> createState() => _DownloadOptionsWidgetState();
}

class _DownloadOptionsWidgetState extends State<DownloadOptionsWidget> {
  List<bool> _isDownloading = [];

  @override
  void initState() {
    super.initState();
    _isDownloading = List.filled(widget.comicModel.chapters.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.comicModel.chapters.length,
      itemBuilder: (context, index) {
        final chapter = widget.comicModel.chapters[index];
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (_isDownloading[index]) return;
            String id =
                'down_${widget.comicModel.extensionName}_${widget.comicModel.id}_${chapter.id}';
            var p = context.read<TaskProvider>();
            if (p.isHasTask(id)) {
              return;
            }

            p.addTask(TaskDownload(
                id: id,
                extensionName: widget.comicModel.extensionName,
                comicId: widget.comicModel.id,
                chapterId: chapter.id,
                chapterName: chapter.title,
                comicTitle: widget.comicModel.title));
            setState(() {
              _isDownloading[index] = true;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(chapter.title),
              Icon(CupertinoIcons.cloud_download,
                  color: _isDownloading[index]
                      ? CupertinoColors.systemRed
                      : CupertinoColors.systemGrey),
            ],
          ),
        );
      },
    );
  }
}
