import '../../common/log.dart';

abstract class ReaderChapter {
  List<String> get images;
}

class ReaderChapters<T extends ReaderChapter> {
  final List<T> chapters = [];
  final List<String> chapterIds = [];

  void clear() {
    chapters.clear();
    chapterIds.clear();
  }

  void addChapter(T detail, String id) {
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

      ret += chapters[i].images.length;
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
    return chapters.first.images.length + 1;
  }

  void addChapterHead(T detail, String id) {
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
        return (start, start + chapter.images.length - 1);
      }

      start += chapter.images.length + 1;
    }

    return null;
  }

  int getChapterImageCount(String chapterId) {
    int index = chapterIds.indexWhere((e) => e == chapterId);
    if (index == -1) return 0;
    return chapters[index].images.length;
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

  int? calcPage(String chapterId, int page) {
    int ret = 1;
    for (int i = 0; i < chapters.length; i++) {
      var chapter = chapters[i];
      if (chapterIds[i] == chapterId) {
        return ret + page - 1;
      }

      ret += chapter.images.length;
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
