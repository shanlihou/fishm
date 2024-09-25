class ComicItem {
  final String title;
  final String imageUrl;
  final String comicId;
  final Map<String, dynamic> extra;

  ComicItem({
    required this.title,
    required this.imageUrl,
    required this.extra,
    required this.comicId,
  });

  factory ComicItem.fromJson(Map<String, dynamic> json) {
    return ComicItem(
      title: json['title'],
      imageUrl: json['cover'],
      extra: json['extra'],
      comicId: json['comic_id'],
    );
  }
}
