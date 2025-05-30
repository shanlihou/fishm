import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';
import '../../const/general_const.dart';
import '../../utils/utils_general.dart';

abstract class NetImageContext {
  String imageUrl;
  String get imagePath;
  Future<bool> fetchImage();

  NetImageContext(this.imageUrl);
}

class NetImageContextLocal extends NetImageContext {
  final String localPath;

  NetImageContextLocal(super.imageUrl, this.localPath);

  @override
  String get imagePath => localPath;

  @override
  Future<bool> fetchImage() async {
    return true;
  }
}

class NetImageContextCover extends NetImageContext {
  final String extensionName;
  final String comicId;

  NetImageContextCover(this.extensionName, this.comicId, super.imageUrl);

  @override
  String get imagePath =>
      '$archiveImageDir/$extensionName/$comicId/cover.${getImageType(imageUrl)}';

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
      downloadImagePath(extensionName, comicId, chapterId, index, imageUrl);

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
