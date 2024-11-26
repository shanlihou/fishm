import '../../types/common/reader_chapters.dart';

class ChapterDetail extends ReaderChapter {
  @override
  List<String> images;
  Map<String, dynamic> extra;

  ChapterDetail(this.images, this.extra);

  int get imageCount => images.length;

  static ChapterDetail fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    for (var image in json['images']) {
      images.add(image as String);
    }
    return ChapterDetail(images, json['extra']);
  }
}
