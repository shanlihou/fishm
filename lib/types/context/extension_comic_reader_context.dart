import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../models/api/chapter_detail.dart';
import '../../models/db/comic_model.dart';
import '../../utils/utils_general.dart';
import '../common/reader_chapters.dart';
import '../provider/comic_provider.dart';
import 'comic_reader_context.dart';

class ExtensionComicReaderContext extends ComicReaderContext
    with ReaderChapters {
  final String chapterId;
  final String comicId;
  final String chapterTitle;
  final String extensionName;
  final int? initPage;

  ExtensionComicReaderContext(this.chapterId, this.comicId, this.chapterTitle,
      this.extensionName, this.initPage);

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

    addChapter(detail, chapterId);
    int initPage = this.initPage ?? 1;

    if (imageUrl(initPage) == null) {
      initPage = 1;
    }

    return initPage;
  }

  @override
  Future<void> recordReadHistory(BuildContext context, int page) async {
    var ret = imageUrl(page);
    if (ret == null) return;
    ComicProvider comicProvider = context.read<ComicProvider>();
    comicProvider.recordReadHistory(
        getComicUniqueId(comicId, extensionName), ret.$3, ret.$2 + 1);
  }
}
