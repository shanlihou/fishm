import 'package:flutter/widgets.dart';

import 'comic_reader_context.dart';

class LocalComicReaderContext extends ComicReaderContext {
  @override
  void recordHistory(BuildContext context, int page) {}

  @override
  Widget? getImage(BuildContext context, int page) {
    return null;
  }

  @override
  (String?, String?) buildMiddleText(BuildContext context, int page) {
    return (null, null);
  }

  @override
  int get imageCount => 0;

  @override
  String getPageText(BuildContext context, int page) {
    return '';
  }

  @override
  Future<int?> init(BuildContext context) async {
    return null;
  }

  @override
  Future<int> supplementChapter(BuildContext context, bool next) async {
    return 0;
  }

  @override
  int lastChapterFirstPageIndex() {
    return 0;
  }

  @override
  int? preChapter(BuildContext context) {
    return null;
  }

  @override
  int? nextChapter(BuildContext context) {
    return null;
  }

  @override
  int? getAbsolutePage(int page) {
    return null;
  }

  @override
  int chapterImageCount() {
    return 0;
  }

  @override
  int get historyChapterPage => 0;
}
