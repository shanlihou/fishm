import 'package:flutter/widgets.dart';

import '../common/reader_chapter_base.dart';
import '../common/reader_chapters.dart';

abstract class ComicReaderContext {
  Future<int?> init(BuildContext context);
  int get imageCount;

  Future<void> recordReadHistory(BuildContext context, int page);
}
