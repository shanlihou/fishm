import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/api/chapter_detail.dart';
import '../../models/db/comic_model.dart';
import '../../utils/utils_general.dart';
import '../../views/widget/net_image.dart';
import '../common/reader_chapters.dart';
import '../provider/comic_provider.dart';
import 'comic_reader_context.dart';
import 'net_iamge_context.dart';

class ExtensionComicReaderContext extends ComicReaderContext {
  final String extensionName;
  final String comicId;
  final String initChapterId;
  final int? initPage;
  final Map<String, dynamic> extra;
  int historyPage = -1;
  String historyChapterId = '';

  ExtensionComicReaderContext(this.extensionName, this.comicId,
      this.initChapterId, this.initPage, this.extra);

  final ReaderChapters _readerChapters = ReaderChapters();

  int? preChapter(BuildContext context) {
    var preChapterId = context
        .read<ComicProvider>()
        .getComicModel(getComicUniqueId(comicId, extensionName))
        ?.preChapterId(historyChapterId);

    if (preChapterId == null) {
      return null;
    }

    return _readerChapters.chapterFirstPageIndex(preChapterId);
  }

  int get historyChapterPage => historyPage;

  int? getAbsolutePage(int chapterPage) {
    return _readerChapters.calcPage(historyChapterId, chapterPage);
  }

  int? nextChapter(BuildContext context) {
    var nextChapterId = context
        .read<ComicProvider>()
        .getComicModel(getComicUniqueId(comicId, extensionName))
        ?.nextChapterId(historyChapterId);

    if (nextChapterId == null) {
      return null;
    }

    return _readerChapters.chapterFirstPageIndex(nextChapterId);
  }

  int lastChapterFirstPageIndex() {
    var ret =
        _readerChapters.getChapterIamgeRange(_readerChapters.lastChapterId());

    return ret?.$1 ?? 0;
  }

  void recordHistory(BuildContext context, int index) {
    var ret = _readerChapters.imageUrl(index);
    if (ret == null) {
      return;
    }

    historyPage = ret.$2 + 1;
    historyChapterId = ret.$3;

    ComicProvider p = context.read<ComicProvider>();
    p.recordReadHistory(getComicUniqueId(comicId, extensionName),
        historyChapterId, historyPage);
  }

  Future<int?> init(BuildContext context) async {
    var p = context.read<ComicProvider>();
    ComicModel comicModel =
        p.getComicModel(getComicUniqueId(comicId, extensionName))!;

    ChapterDetail? detail = await getChapterDetails(
        comicModel, extensionName, comicId, initChapterId);

    if (detail == null) {
      return null;
    }

    await p.saveComic(comicModel);

    _readerChapters.addChapter(detail, initChapterId);
    int initPage = this.initPage ?? 1;

    if (_readerChapters.imageUrl(initPage) == null) {
      initPage = 1;
    }

    return initPage;
  }

  int get imageCount => _readerChapters.imageCount;

  (String?, String?) buildMiddleText(BuildContext context, int index) {
    return ('', '');
  }

  Widget? getImage(BuildContext context, int index) {
    var ret = _readerChapters.imageUrl(index);
    if (ret == null) {
      return null;
    } else {
      return NetImage(
        NetImageContextReader(
            extensionName, comicId, ret.$3, ret.$1, ret.$2, extra),
        width: 1.sw,
        height: 1.sh,
      );
    }
  }

  int chapterImageCount() {
    return _readerChapters.getChapterImageCount(historyChapterId);
  }

  String getPageText(BuildContext context, int index) {
    var ret = _readerChapters.imageUrl(index);
    if (ret == null) {
      return '0/0';
    }
    var comicModel = context
        .read<ComicProvider>()
        .getComicModel(getComicUniqueId(comicId, extensionName));
    if (comicModel == null) {
      return '0/0';
    }

    String chapterTitle = comicModel.getChapterTitle(ret.$3) ?? '';

    return '$chapterTitle ${ret.$2 + 1}/${ret.$4}';
  }

  Future<int> supplementChapter(BuildContext context, bool isNext) async {
    var p = context.read<ComicProvider>();
    var comicModel = p.getComicModel(getComicUniqueId(comicId, extensionName));

    if (comicModel == null) return -1;

    if (isNext) {
      String last = _readerChapters.lastChapterId();
      String? nextChapterId = comicModel.nextChapterId(last);
      if (nextChapterId == null) return -1;
      ChapterDetail detail = (await getChapterDetails(
          comicModel, extensionName, comicId, nextChapterId))!;
      await p.saveComic(comicModel);
      _readerChapters.addChapter(detail, nextChapterId);
      _readerChapters.frontPop();
      return _readerChapters.firstMiddlePageIndex();
    } else {
      String first = _readerChapters.firstChapterId();
      String? preChapterId = comicModel.preChapterId(first);
      if (preChapterId == null) return -1;
      ChapterDetail detail = (await getChapterDetails(
          comicModel, extensionName, comicId, preChapterId))!;
      await p.saveComic(comicModel);
      _readerChapters.addChapterHead(detail, preChapterId);
      _readerChapters.backPop();
      return _readerChapters.firstMiddlePageIndex();
    }
  }
}
