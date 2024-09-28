class GalleryResult {
  final bool success;
  final List<Object> data;

  GalleryResult(this.success, this.data);

  static GalleryResult fromJson(Map<String, dynamic> json) {
    if (json['data'] is! List<Object>) {
      return GalleryResult(json['success'], []);
    }
    return GalleryResult(json['success'], json['data']);
  }
}
