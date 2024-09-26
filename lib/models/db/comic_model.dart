import 'package:hive/hive.dart';

import '../api/comic_detail.dart';

part 'comic_model.g.dart';

@HiveType(typeId: 4)
class ChapterModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  ChapterModel(this.id, this.title);
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
        chapters =
            detail.chapters.map((e) => ChapterModel(e.id, e.title)).toList(),
        cover = detail.cover;
}
