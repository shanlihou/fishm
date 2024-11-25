import 'package:flutter/widgets.dart';

abstract class ComicReaderContext {
  void recordHistory(BuildContext context, int page);
  Widget? getImage(BuildContext context, int page);
  (String?, String?) buildMiddleText(BuildContext context, int page);

  int get imageCount;

  String getPageText(BuildContext context, int page);

  Future<int?> init(BuildContext context);

  Future<int> supplementChapter(BuildContext context, bool next);

  int lastChapterFirstPageIndex();

  int? preChapter(BuildContext context);

  int? nextChapter(BuildContext context);

  int? getAbsolutePage(int page);

  int chapterImageCount();

  int get historyChapterPage;
}
