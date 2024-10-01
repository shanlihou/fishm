import '../db/comic_model.dart';

class Chpater {
  final String title;
  final String id;

  Chpater(this.title, this.id);
}

class ComicDetail {
  String title;
  String id;
  String cover;
  Map<String, dynamic> extra;

  List<Chpater> chapters;

  ComicDetail(this.title, this.chapters, this.id, this.extra, this.cover);

  static ComicDetail fromJson(Map<String, dynamic> json) {
    List<Chpater> chapters = [];
    if (json['chapters'].isNotEmpty) {
      for (var item in json['chapters']) {
        chapters.add(Chpater(item['title'], item['id']));
      }
    }
    return ComicDetail(
        json['title'], chapters, json['id'], json['extra'], json['cover']);
  }

  String getChapterTitle(String chapterId) {
    for (var chapter in chapters) {
      if (chapter.id == chapterId) {
        return chapter.title;
      }
    }
    return '';
  }

  ComicDetail.fromComicModel(ComicModel comicModel)
      : title = comicModel.title,
        id = comicModel.id,
        cover = comicModel.cover,
        extra = comicModel.extra,
        chapters =
            comicModel.chapters.map((e) => Chpater(e.title, e.id)).toList();
}
