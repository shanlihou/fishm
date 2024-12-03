import 'package:flutter/widgets.dart';

import '../../views/widget/select_widget.dart';
import '../common/reader_chapters.dart';

abstract class ComicReaderContext<T extends ReaderChapter> {
  final ReaderChapters<T> readerChapters = ReaderChapters();

  void recordHistory(BuildContext context, int page);
  Widget? getImage(BuildContext context, int page);
  (String?, String?) buildMiddleText(BuildContext context, int page);

  int get imageCount;

  List<SelectMenuItem> getChapterItems(BuildContext context);

  String getTitle(BuildContext context);

  String getChapterTitle(BuildContext context, String chapterId);

  String getPageText(BuildContext context, int page);

  Future<int?> init(BuildContext context);

  Future<int> supplementChapter(BuildContext context, bool next);

  int lastChapterFirstPageIndex() {
    var ret =
        readerChapters.getChapterIamgeRange(readerChapters.lastChapterId());

    return ret?.$1 ?? 0;
  }

  int? preChapter(BuildContext context);

  int? nextChapter(BuildContext context);

  int? getAbsolutePage(int page);

  int chapterImageCount();

  int get historyChapterPage;

  int currentChapterIndex(BuildContext context);

  Future<void> jumpToChapter(BuildContext context, String chapterId);
}
