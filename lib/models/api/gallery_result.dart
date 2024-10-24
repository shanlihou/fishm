import '../../views/class/comic_item.dart';

class GalleryResult {
  final bool success;
  final bool noMore;
  final List<ComicItem> data;

  GalleryResult(this.success, this.data, this.noMore);

  static GalleryResult fromJson(Map<String, dynamic> json) {
    if (json['data'] is! List<Object>) {
      return GalleryResult(json['success'], [], false);
    }

    List<ComicItem> data = [];
    for (var item in json['data']) {
      data.add(ComicItem.fromJson(item as Map<String, dynamic>));
    }

    bool noMore = false;
    if (json['nomore'] == true) {
      noMore = true;
    }

    return GalleryResult(json['success'], data, noMore);
  }

  void extend(GalleryResult galleryResult) {
    data.addAll(galleryResult.data);
  }
}
