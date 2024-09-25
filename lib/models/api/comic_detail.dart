class Chpater {
  final String title;
  final String id;

  Chpater(this.title, this.id);
}

class ComicDetail {
  String title;
  String id;
  Map<String, dynamic> extra;

  List<Chpater> chapters;

  ComicDetail(this.title, this.chapters, this.id, this.extra);

  static ComicDetail fromJson(Map<String, dynamic> json) {
    List<Chpater> chapters = [];
    if (json['chapters'].isNotEmpty) {
      for (var item in json['chapters']) {
        chapters.add(Chpater(item['title'], item['id']));
      }
    }
    return ComicDetail(json['title'], chapters, json['id'], json['extra']);
  }
}
