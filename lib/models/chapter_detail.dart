
class ChapterDetail {
  List<String> images;

  ChapterDetail(this.images);

  static ChapterDetail fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    for (var image in json['images']) {
      images.add(image as String);
    }
    return ChapterDetail(images);
  }
}