class ChapterDetail {
  List<String> images;
  Map<String, dynamic> extra;

  ChapterDetail(this.images, this.extra);

  static ChapterDetail fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    for (var image in json['images']) {
      images.add(image as String);
    }
    return ChapterDetail(images, json['extra']);
  }
}
