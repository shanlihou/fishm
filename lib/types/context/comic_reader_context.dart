import 'package:flutter/widgets.dart';

import '../common/reader_chapter_base.dart';
import '../common/reader_chapters.dart';

abstract class ComicReaderContext<T extends ReaderChapterBase> {
  ReaderChapters<T> readerChapters;
  ComicReaderContext(this.readerChapters);

  Future<int?> init(BuildContext context);
  int get imageCount;
}
