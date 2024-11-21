import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../models/api/chapter_detail.dart';
import '../../models/db/comic_model.dart';
import '../../utils/utils_general.dart';
import '../provider/comic_provider.dart';
import 'comic_reader_context.dart';

class ExtensionComicReaderContext extends ComicReaderContext<ChapterDetail> {
  final String chapterId;
  final String comicId;
  final String chapterTitle;
  final String extensionName;
  final int? initPage;

  ExtensionComicReaderContext(this.chapterId, this.comicId, this.chapterTitle,
      this.extensionName, super.readerChapters, this.initPage);

  @override
  Future<int?> init(BuildContext context) async {
    var p = context.read<ComicProvider>();
    ComicModel comicModel =
        p.getHistoryComicModel(getComicUniqueId(comicId, extensionName))!;
    var detail =
        await getChapterDetails(comicModel, extensionName, comicId, chapterId);

    if (detail == null) {
      return null;
    }

    await p.saveComic(comicModel);

    readerChapters.addChapter(detail, chapterId);
    int initPage = this.initPage ?? 1;

    if (readerChapters.imageUrl(initPage) == null) {
      initPage = 1;
    }

    return initPage;
  }

  @override
  int get imageCount => readerChapters.imageCount;
}
