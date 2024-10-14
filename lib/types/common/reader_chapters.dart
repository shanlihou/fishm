import 'package:toonfu/models/api/chapter_detail.dart';

import '../../common/log.dart';

class ReaderChapters {
  final List<ChapterDetail> chapters = [];
  final List<String> chapterIds = [];

  void addChapter(ChapterDetail detail, String id) {
    chapters.add(detail);
    chapterIds.add(id);
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

  void debugPrint() {
    for (var chapter in chapters) {
      for (var image in chapter.images) {
        Log.instance.d('image: $image');
      }

      Log.instance.d('--------------------------------');
    }
  }

  int get imageCount {
    int count = 0;
    for (var chapter in chapters) {
      count += chapter.images.length;
    }
    return count + 1 + chapters.length;
  }

  (String, int, String, int)? imageUrl(int index) {
    if (index == 0) {
      return null;
    }

    index--;

    for (var i = 0; i < chapters.length; i++) {
      var chapter = chapters[i];
      if (index < chapter.images.length) {
        return (
          chapter.images[index],
          index,
          chapterIds[i],
          chapter.images.length
        );
      }
      index -= chapter.images.length;

      if (index == 0) {
        return null;
      }
      index--;
    }

    return null;
  }
}
