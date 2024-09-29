import '../../views/class/comic_item.dart';

class GalleryResult {
  final bool success;
  final List<ComicItem> data;

  GalleryResult(this.success, this.data);

  static GalleryResult fromJson(Map<String, dynamic> json) {
    if (json['data'] is! List<Object>) {
      return GalleryResult(json['success'], []);
    }

    List<ComicItem> data = [];
    for (var item in json['data']) {
      data.add(ComicItem.fromJson(item as Map<String, dynamic>));
    }

    return GalleryResult(json['success'], data);
  }
}
