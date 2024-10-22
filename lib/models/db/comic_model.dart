import 'package:hive/hive.dart';

import '../api/chapter_detail.dart';
import '../api/comic_detail.dart';

part 'comic_model.g.dart';

@HiveType(typeId: 4)
class ChapterModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2, defaultValue: [])
  List<String> images;

  @HiveField(3, defaultValue: {})
  Map<String, dynamic> extra;

  ChapterModel(this.id, this.title, this.images, this.extra);
}

@HiveType(typeId: 3)
class ComicModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  Map<String, dynamic> extra;

  @HiveField(3)
  List<ChapterModel> chapters;

  @HiveField(4)
  String cover;

  @HiveField(5)
  String extensionName;

  String get uniqueId => '$id-$extensionName';

  ComicModel(this.id, this.title, this.extra, this.chapters, this.cover,
      this.extensionName);

  ComicModel.fromComicDetail(ComicDetail detail, this.extensionName)
      : id = detail.id,
        title = detail.title,
        extra = detail.extra,
        chapters = detail.chapters
            .map((e) => ChapterModel(e.id, e.title, [], {}))
            .toList(),
        cover = detail.cover;

  void updateFromComicDetail(ComicDetail detail) {
    List<ChapterModel> newChapters = [];
    for (var chapter in detail.chapters) {
      int index = chapters.indexWhere((e) => e.id == chapter.id);
      if (index == -1) {
        newChapters.add(ChapterModel(chapter.id, chapter.title, [], {}));
      } else {
        newChapters.add(chapters[index]);
      }
    }
    chapters = newChapters;
  }

  String? nextChapterId(String curChapterId) {
    int index = chapters.indexWhere((e) => e.id == curChapterId);
    if (index == -1) return null;
    if (index == 0) return null;
    return chapters[index - 1].id;
  }

  String? getChapterTitle(String chapterId) {
    int index = chapters.indexWhere((e) => e.id == chapterId);
    if (index == -1) return null;
    return chapters[index].title;
  }

  String? preChapterId(String curChapterId) {
    int index = chapters.indexWhere((e) => e.id == curChapterId);
    if (index == -1) return null;
    if (index == chapters.length - 1) return null;
    return chapters[index + 1].id;
  }

  void addChapterDetail(String chapterId, ChapterDetail detail) {
    int index = chapters.indexWhere((e) => e.id == chapterId);
    if (index == -1) return;
    chapters[index].images = detail.images;
    chapters[index].extra = detail.extra;
  }

  ChapterDetail? getChapterDetail(String chapterId) {
    int index = chapters.indexWhere((e) => e.id == chapterId);
    if (index == -1) return null;
    if (chapters[index].images.isEmpty) return null;
    return ChapterDetail(chapters[index].images, chapters[index].extra);
  }
}
