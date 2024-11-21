import 'package:toonfu/models/api/chapter_detail.dart';

import '../../common/log.dart';
import 'reader_chapter_base.dart';

mixin ReaderChapters {
  final List<ChapterDetail> chapters = [];
  final List<String> chapterIds = [];

  void addChapter(ChapterDetail detail, String id) {
    chapters.add(detail);
    chapterIds.add(id);
  }

  void frontPop() {
    while (chapters.length > 2) {
      chapters.removeAt(0);
      chapterIds.removeAt(0);
    }
  }

  int? chapterFirstPageIndex(String chapterId) {
    int ret = 1;
    for (var i = 0; i < chapters.length; i++) {
      if (chapterIds[i] == chapterId) {
        return ret;
      }

      ret += chapters[i].imageCount;
      ret += 1;
    }

    return null;
  }

  void backPop() {
    while (chapters.length > 2) {
      chapters.removeAt(chapters.length - 1);
      chapterIds.removeAt(chapterIds.length - 1);
    }
  }

  int firstMiddlePageIndex() {
    return chapters.first.imageCount + 1;
  }

  void addChapterHead(ChapterDetail detail, String id) {
    chapters.insert(0, detail);
    chapterIds.insert(0, id);
  }

  String firstChapterId() {
    return chapterIds.first;
  }

  String lastChapterId() {
    return chapterIds.last;
  }

  // [min, max] close range
  (int, int)? getChapterIamgeRange(String chapterId) {
    int start = 1;
    for (var i = 0; i < chapters.length; i++) {
      var chapter = chapters[i];
      if (chapterIds[i] == chapterId) {
        return (start, start + chapter.imageCount - 1);
      }

      start += chapter.imageCount + 1;
    }

    return null;
  }

  int getChapterImageCount(String chapterId) {
    int index = chapterIds.indexWhere((e) => e == chapterId);
    if (index == -1) return 0;
    return chapters[index].imageCount;
  }

  int get imageCount {
    int count = 0;
    for (var chapter in chapters) {
      count += chapter.imageCount;
    }
    return count + 1 + chapters.length;
  }

  int? calcPage(String chapterId, int page) {
    int ret = 1;
    for (int i = 0; i < chapters.length; i++) {
      var chapter = chapters[i];
      if (chapterIds[i] == chapterId) {
        return ret + page - 1;
      }

      ret += chapter.imageCount;
      ret += 1;
    }
    return null;
  }

  // imageUrl, index, chapterId, count
  (String, int, String, int)? imageUrl(int index) {
    if (index <= 0) {
      return null;
    }

    index--;

    for (var i = 0; i < chapters.length; i++) {
      var chapter = chapters[i];
      if (index < chapter.imageCount) {
        return (
          chapter.images[index],
          index,
          chapterIds[i],
          chapter.imageCount
        );
      }
      index -= chapter.imageCount;

      if (index == 0) {
        return null;
      }
      index--;
    }

    return null;
  }
}
