import 'dart:convert';

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

  @HiveField(3, defaultValue: "{}")
  String _extra;

  Map<String, dynamic> get extra => jsonDecode(_extra);

  set extra(Map<String, dynamic> value) => _extra = jsonEncode(value);

  ChapterModel(this.id, this.title, this.images, this._extra);
}

@HiveType(typeId: 3)
class ComicModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2, defaultValue: "{}")
  String _extra;

  Map<String, dynamic> get extra => jsonDecode(_extra);

  set extra(Map<String, dynamic> value) => _extra = jsonEncode(value);

  @HiveField(3)
  List<ChapterModel> chapters;

  @HiveField(4)
  String cover;

  @HiveField(5)
  String extensionName;

  String get uniqueId => '$id-$extensionName';

  ComicModel(this.id, this.title, this._extra, this.chapters, this.cover,
      this.extensionName);

  static ComicModel fromComicDetail(ComicDetail detail, String extensionName) {
    return ComicModel(
        detail.id,
        detail.title,
        jsonEncode(detail.extra),
        detail.chapters
            .map((e) => ChapterModel(e.id, e.title, [], "{}"))
            .toList(),
        detail.cover,
        extensionName);
  }

  void updateFromComicDetail(ComicDetail detail) {
    List<ChapterModel> newChapters = [];
    for (var chapter in detail.chapters) {
      int index = chapters.indexWhere((e) => e.id == chapter.id);
      if (index == -1) {
        newChapters.add(ChapterModel(chapter.id, chapter.title, [], "{}"));
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

  ChapterModel? getChapterModel(String chapterId) {
    int index = chapters.indexWhere((e) => e.id == chapterId);
    if (index == -1) return null;
    return chapters[index];
  }

  ChapterDetail? getChapterDetail(String chapterId) {
    int index = chapters.indexWhere((e) => e.id == chapterId);
    if (index == -1) return null;
    if (chapters[index].images.isEmpty) return null;
    return ChapterDetail(chapters[index].images, chapters[index].extra);
  }
}
