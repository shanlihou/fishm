import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/api/chapter_detail.dart';
import '../../models/db/comic_model.dart';
import '../../utils/utils_general.dart';
import '../../views/widget/net_image.dart';
import '../../views/widget/select_widget.dart';
import '../provider/comic_provider.dart';
import 'comic_reader_context.dart';
import 'net_iamge_context.dart';

class ExtensionComicReaderContext extends ComicReaderContext<ChapterDetail> {
  final String extensionName;
  final String comicId;
  final String initChapterId;
  final int? initPage;
  final Map<String, dynamic> extra;
  int historyPage = -1;
  String historyChapterId = '';

  ExtensionComicReaderContext(this.extensionName, this.comicId,
      this.initChapterId, this.initPage, this.extra);

  @override
  String getTitle(BuildContext context) {
    return context
            .read<ComicProvider>()
            .getComicModel(getComicUniqueId(comicId, extensionName))
            ?.title ??
        '';
  }

  @override
  String getChapterTitle(BuildContext context, String chapterId) {
    return context
            .read<ComicProvider>()
            .getComicModel(getComicUniqueId(comicId, extensionName))
            ?.getChapterTitle(chapterId) ??
        '';
  }

  @override
  int? preChapter(BuildContext context) {
    var preChapterId = context
        .read<ComicProvider>()
        .getComicModel(getComicUniqueId(comicId, extensionName))
        ?.preChapterId(historyChapterId);

    if (preChapterId == null) {
      return null;
    }

    return readerChapters.chapterFirstPageIndex(preChapterId);
  }

  @override
  int get historyChapterPage => historyPage;

  @override
  int? getAbsolutePage(int chapterPage) {
    return readerChapters.calcPage(historyChapterId, chapterPage);
  }

  @override
  int? nextChapter(BuildContext context) {
    var nextChapterId = context
        .read<ComicProvider>()
        .getComicModel(getComicUniqueId(comicId, extensionName))
        ?.nextChapterId(historyChapterId);

    if (nextChapterId == null) {
      return null;
    }

    return readerChapters.chapterFirstPageIndex(nextChapterId);
  }

  @override
  void recordHistory(BuildContext context, int index) {
    var ret = readerChapters.imageUrl(index);
    if (ret == null) {
      return;
    }

    historyPage = ret.$2 + 1;
    historyChapterId = ret.$3;

    ComicProvider p = context.read<ComicProvider>();
    p.recordReadHistory(getComicUniqueId(comicId, extensionName),
        historyChapterId, historyPage);
  }

  @override
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

    readerChapters.addChapter(detail, initChapterId);
    int initPage = this.initPage ?? 1;

    if (readerChapters.imageUrl(initPage) == null) {
      initPage = 1;
    }

    return initPage;
  }

  @override
  int get imageCount => readerChapters.imageCount;

  @override
  (String?, String?) buildMiddleText(BuildContext context, int index) {
    var preRet = readerChapters.imageUrl(index - 1);
    var nextRet = readerChapters.imageUrl(index + 1);
    var comicModel = context
        .read<ComicProvider>()
        .getComicModel(getComicUniqueId(comicId, extensionName));

    if (comicModel == null) return (null, null);

    if (preRet == null && nextRet == null) {
      return (null, null);
    }

    if (preRet == null) {
      String preChapterId = comicModel.preChapterId(nextRet!.$3) ?? '';
      String? preChapterTitle = comicModel.getChapterTitle(preChapterId);
      String? nextChapterTitle = comicModel.getChapterTitle(nextRet.$3);
      return (preChapterTitle, nextChapterTitle);
    }

    if (nextRet == null) {
      String nextChapterId = comicModel.nextChapterId(preRet.$3) ?? '';
      String? preChapterTitle = comicModel.getChapterTitle(preRet.$3);
      String? nextChapterTitle = comicModel.getChapterTitle(nextChapterId);
      return (preChapterTitle, nextChapterTitle);
    }

    String? preChapterTitle = comicModel.getChapterTitle(preRet.$3);
    String? nextChapterTitle = comicModel.getChapterTitle(nextRet.$3);
    return (preChapterTitle, nextChapterTitle);
  }

  @override
  Widget? getImage(BuildContext context, int index) {
    var ret = readerChapters.imageUrl(index);
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

  @override
  int chapterImageCount() {
    return readerChapters.getChapterImageCount(historyChapterId);
  }

  @override
  String getPageText(BuildContext context, int index) {
    var ret = readerChapters.imageUrl(index);
    if (ret == null) {
      return '';
    }
    var comicModel = context
        .read<ComicProvider>()
        .getComicModel(getComicUniqueId(comicId, extensionName));
    if (comicModel == null) {
      return '';
    }

    String chapterTitle = comicModel.getChapterTitle(ret.$3) ?? '';

    return '$chapterTitle ${ret.$2 + 1}/${ret.$4}';
  }

  @override
  Future<int> supplementChapter(BuildContext context, bool isNext) async {
    var p = context.read<ComicProvider>();
    var comicModel = p.getComicModel(getComicUniqueId(comicId, extensionName));

    if (comicModel == null) return -1;

    if (isNext) {
      String last = readerChapters.lastChapterId();
      String? nextChapterId = comicModel.nextChapterId(last);
      if (nextChapterId == null) {
        return -1;
      }

      ChapterDetail detail = (await getChapterDetails(
          comicModel, extensionName, comicId, nextChapterId))!;
      await p.saveComic(comicModel);
      readerChapters.addChapter(detail, nextChapterId);
      readerChapters.frontPop();
      return readerChapters.firstMiddlePageIndex();
    } else {
      String first = readerChapters.firstChapterId();
      String? preChapterId = comicModel.preChapterId(first);
      if (preChapterId == null) {
        return -1;
      }
      ChapterDetail detail = (await getChapterDetails(
          comicModel, extensionName, comicId, preChapterId))!;
      await p.saveComic(comicModel);
      readerChapters.addChapterHead(detail, preChapterId);
      readerChapters.backPop();
      return readerChapters.firstMiddlePageIndex();
    }
  }

  @override
  List<SelectMenuItem> getChapterItems(BuildContext context) {
    var p = context.read<ComicProvider>();
    var comicModel = p.getComicModel(getComicUniqueId(comicId, extensionName));
    if (comicModel == null) return [];

    List<SelectMenuItem> items = [];
    for (var chapter in comicModel.chapters) {
      items.add(SelectMenuItem(label: chapter.title, chapterId: chapter.id));
    }

    return items;
  }

  @override
  int currentChapterIndex(BuildContext context) {
    var comicModel = context
        .read<ComicProvider>()
        .getComicModel(getComicUniqueId(comicId, extensionName));
    if (comicModel == null) return -1;
    return comicModel.getChapterIndex(historyChapterId);
  }

  @override
  Future<void> jumpToChapter(BuildContext context, String chapterId) async {
    var p = context.read<ComicProvider>();
    var comicModel = p.getComicModel(getComicUniqueId(comicId, extensionName));

    if (comicModel == null) return;

    readerChapters.clear();

    ChapterDetail detail = (await getChapterDetails(
        comicModel, extensionName, comicId, chapterId))!;
    await p.saveComic(comicModel);
    readerChapters.addChapter(detail, chapterId);
  }
}
