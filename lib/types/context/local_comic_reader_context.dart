import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../const/general_const.dart';
import '../../views/widget/net_image.dart';
import '../common/reader_chapters.dart';
import '../common/reader_chapters.dart';
import 'comic_reader_context.dart';
import 'net_iamge_context.dart';

class LocalChapterDetail extends ReaderChapter {
  @override
  final List<String> images;

  LocalChapterDetail(this.images);
}

class LocalComicReaderContext extends ComicReaderContext {
  String cbzDir;
  String imageSaveDir = "";
  List<String> _cbzPaths = [];
  int? initCbzIndex;
  int? initCbzPage;
  final ReaderChapters<LocalChapterDetail> _readerChapters = ReaderChapters();

  LocalComicReaderContext(this.cbzDir, {this.initCbzIndex, this.initCbzPage});

  @override
  void recordHistory(BuildContext context, int page) {}

  @override
  Widget? getImage(BuildContext context, int page) {
    var ret = _readerChapters.imageUrl(page);
    if (ret == null) {
      return null;
    } else {
      return NetImage(NetImageContextLocal(ret.$1, ret.$1),
          width: 1.sw, height: 1.sh);
    }
  }

  @override
  (String?, String?) buildMiddleText(BuildContext context, int page) {
    return (null, null);
  }

  @override
  int get imageCount => _readerChapters.imageCount;

  @override
  String getPageText(BuildContext context, int index) {
    var ret = _readerChapters.imageUrl(index);
    if (ret == null) {
      return '0/0';
    }

    return '${ret.$3} ${ret.$2 + 1}/${ret.$4}';
  }

  Future<(List<String>, String)> _loadCbzByIndex(int index) async {
    var curDir = '$imageSaveDir/$index';
    String initCbzPath = _cbzPaths[index];
    final bytes = await File(initCbzPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    int writeIdx = 1;
    List<String> imagePaths = [];
    for (final file in archive) {
      if (file.isFile) {
        var suffix = file.name.split('.').last;
        String newFileName = '$curDir/$writeIdx.$suffix';

        imagePaths.add(newFileName);
        if (File(newFileName).existsSync()) {
          writeIdx++;
          continue;
        }

        final data = file.content as List<int>;
        File(newFileName)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        writeIdx++;
      }
    }

    return (imagePaths, curDir);
  }

  @override
  Future<int?> init(BuildContext context) async {
    // urlencode cbzdir
    var urlEncodedCbzDir = Uri.encodeComponent(cbzDir);
    print('urlEncodedCbzDir: $urlEncodedCbzDir');

    imageSaveDir = '$archiveCbzImageDir/$urlEncodedCbzDir';

    bool isDir = await Directory(cbzDir).exists();
    if (isDir) {
      _cbzPaths = await Directory(cbzDir)
          .list()
          .where((e) => e.path.endsWith('.cbz'))
          .map((e) => e.path)
          .toList();
    } else {
      _cbzPaths = [cbzDir];
    }

    print('cbzPaths: $_cbzPaths');

    var (imagePaths, curDir) = await _loadCbzByIndex(initCbzIndex ?? 0);
    print('imagePaths: $imagePaths');

    _readerChapters.addChapter(LocalChapterDetail(imagePaths), curDir);
    return 1;
  }

  @override
  Future<int> supplementChapter(BuildContext context, bool next) async {
    return 0;
  }

  @override
  int lastChapterFirstPageIndex() {
    return 0;
  }

  @override
  int? preChapter(BuildContext context) {
    return null;
  }

  @override
  int? nextChapter(BuildContext context) {
    return null;
  }

  @override
  int? getAbsolutePage(int page) {
    return null;
  }

  @override
  int chapterImageCount() {
    return 0;
  }

  @override
  int get historyChapterPage => 0;
}
