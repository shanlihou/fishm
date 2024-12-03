import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toonfu/utils/utils_general.dart';

import '../../const/general_const.dart';
import '../../views/widget/net_image.dart';
import '../../views/widget/select_widget.dart';
import '../common/reader_chapters.dart';
import 'comic_reader_context.dart';
import 'net_iamge_context.dart';

class LocalChapterDetail extends ReaderChapter {
  @override
  final List<String> images;

  LocalChapterDetail(this.images);
}

class LocalComicReaderContext extends ComicReaderContext<LocalChapterDetail> {
  String cbzDir;
  String imageSaveDir = "";
  List<String> _cbzPaths = [];
  int? initCbzIndex;
  int? initCbzPage;
  int historyPage = 0;
  String historyChapterId = "";

  LocalComicReaderContext(this.cbzDir, {this.initCbzIndex, this.initCbzPage});

  @override
  String getTitle(BuildContext context) {
    return osPathSplit(cbzDir).last.split('.').first;
  }

  @override
  String getChapterTitle(BuildContext context, String chapterId) {
    return osPathSplit(chapterId).last.split('.').first;
  }

  @override
  void recordHistory(BuildContext context, int index) {
    var ret = readerChapters.imageUrl(index);
    if (ret == null) {
      return;
    }

    historyPage = ret.$2 + 1;
    historyChapterId = ret.$3;
  }

  @override
  Widget? getImage(BuildContext context, int page) {
    var ret = readerChapters.imageUrl(page);
    if (ret == null) {
      return null;
    } else {
      return NetImage(NetImageContextLocal(ret.$1, ret.$1),
          width: 1.sw, height: 1.sh);
    }
  }

  @override
  (String?, String?) buildMiddleText(BuildContext context, int page) {
    var preRet = readerChapters.imageUrl(page - 1);
    var nextRet = readerChapters.imageUrl(page + 1);

    if (preRet == null && nextRet == null) {
      return (null, null);
    }

    if (preRet == null) {
      String preChapterId = _getPreChapterId(nextRet!.$3) ?? '';
      String preChapterTitle = _chapterTitle(preChapterId);
      String nextChapterTitle = _chapterTitle(nextRet.$3);
      return (preChapterTitle, nextChapterTitle);
    }

    if (nextRet == null) {
      String nextChapterId = _getNextChapterId(preRet.$3) ?? '';
      String preChapterTitle = _chapterTitle(preRet.$3);
      String nextChapterTitle = _chapterTitle(nextChapterId);
      return (preChapterTitle, nextChapterTitle);
    }

    String preChapterTitle = _chapterTitle(preRet.$3);
    String nextChapterTitle = _chapterTitle(nextRet.$3);
    return (preChapterTitle, nextChapterTitle);
  }

  String _chapterTitle(String chapterId) {
    return osPathSplit(chapterId).last.split('.').first;
  }

  @override
  int get imageCount => readerChapters.imageCount;

  @override
  String getPageText(BuildContext context, int index) {
    var ret = readerChapters.imageUrl(index);
    if (ret == null) {
      return '0/0';
    }

    String chapterName = _chapterTitle(ret.$3);

    return '$chapterName ${ret.$2 + 1}/${ret.$4}';
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

    int curIndex = initCbzIndex ?? 0;

    var (imagePaths, curDir) = await _loadCbzByIndex(curIndex);
    print('imagePaths: $imagePaths');

    readerChapters.addChapter(
        LocalChapterDetail(imagePaths), _cbzPaths[curIndex]);
    return 1;
  }

  String? _getNextChapterId(String curChapterId) {
    int idx = _cbzPaths.indexOf(curChapterId);
    if (idx == _cbzPaths.length - 1) return null;

    return _cbzPaths[idx + 1];
  }

  String? _getPreChapterId(String curChapterId) {
    int idx = _cbzPaths.indexOf(curChapterId);
    if (idx == 0) return null;

    return _cbzPaths[idx - 1];
  }

  @override
  Future<int> supplementChapter(BuildContext context, bool isNext) async {
    if (isNext) {
      String last = readerChapters.lastChapterId();
      String? nextChapterId = _getNextChapterId(last);
      if (nextChapterId == null) return -1;

      int nextIndex = _cbzPaths.indexOf(nextChapterId);
      var (imagePaths, curDir) = await _loadCbzByIndex(nextIndex);
      readerChapters.addChapter(LocalChapterDetail(imagePaths), nextChapterId);
      readerChapters.frontPop();
      return readerChapters.firstMiddlePageIndex();
    } else {
      String first = readerChapters.firstChapterId();
      String? preChapterId = _getPreChapterId(first);
      if (preChapterId == null) return -1;

      int preIndex = _cbzPaths.indexOf(preChapterId);
      var (imagePaths, curDir) = await _loadCbzByIndex(preIndex);
      readerChapters.addChapterHead(
          LocalChapterDetail(imagePaths), preChapterId);
      readerChapters.backPop();
      return readerChapters.firstMiddlePageIndex();
    }
  }

  @override
  int? preChapter(BuildContext context) {
    String? preChapterId = _getPreChapterId(historyChapterId);
    if (preChapterId == null) return null;

    return readerChapters.chapterFirstPageIndex(preChapterId);
  }

  @override
  int? nextChapter(BuildContext context) {
    String? nextChapterId = _getNextChapterId(historyChapterId);
    if (nextChapterId == null) return null;

    return readerChapters.chapterFirstPageIndex(nextChapterId);
  }

  @override
  int? getAbsolutePage(int page) {
    return readerChapters.calcPage(historyChapterId, page);
  }

  @override
  int chapterImageCount() {
    return readerChapters.getChapterImageCount(historyChapterId);
  }

  @override
  int get historyChapterPage => historyPage;

  @override
  List<SelectMenuItem> getChapterItems(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  int currentChapterIndex(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Future<void> jumpToChapter(BuildContext context, String chapterId) async {
    throw UnimplementedError();
  }
}
