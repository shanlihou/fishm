import 'package:dio/dio.dart';

import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';
import '../../const/general_const.dart';
import '../../utils/utils_general.dart';

abstract class NetImageContext {
  String imageUrl;
  String get imagePath;
  Future<bool> fetchImage();

  NetImageContext(this.imageUrl);

  String _getImageType() {
    String imgType = imageUrl.split('.').last;
    if (imgType == 'jpg' || imgType == 'png' || imgType == 'webp') {
      return imgType;
    }
    return 'jpg';
  }
}

class NetImageContextCover extends NetImageContext {
  final String extensionName;
  final String comicId;

  NetImageContextCover(this.extensionName, this.comicId, super.imageUrl);

  @override
  String get imagePath =>
      '$archiveImageDir/$extensionName/$comicId/cover.${_getImageType()}';

  @override
  Future<bool> fetchImage() async {
    var ret = await downloadImage(extensionName, {}, imageUrl, imagePath)
        as Map<String, dynamic>;

    int code = ret['code'] as int;
    if (code != 200) {
      Log.instance.e('download net cover image failed: $ret');
      return false;
    }

    return true;
  }
}

class NetImageContextReader extends NetImageContext {
  final String extensionName;
  final String comicId;
  final String chapterId;
  final int index;
  final Map<String, dynamic> extra;

  NetImageContextReader(this.extensionName, this.comicId, this.chapterId,
      super.imageUrl, this.index, this.extra);

  @override
  String get imagePath =>
      '${imageChapterFolder(extensionName, comicId, chapterId)}/$index.${_getImageType()}';

  @override
  Future<bool> fetchImage() async {
    var ret = await downloadImage(extensionName, extra, imageUrl, imagePath)
        as Map<String, dynamic>;

    int code = ret['code'] as int;

    if (code != 200) {
      Log.instance.e('download net reader image failed: $ret');
      return false;
    }

    return true;
  }
}
