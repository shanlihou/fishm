// this page use for read comic image

import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/provider/comic_provider.dart';
import 'package:toonfu/utils/utils_general.dart';
import "../../api/flutter_call_lua/method.dart";
import '../../const/general_const.dart';
import "../../models/api/chapter_detail.dart";
import 'package:preload_page_view/preload_page_view.dart';

import '../../models/db/read_history_model.dart';
import '../../types/context/net_iamge_context.dart';
import '../../types/gesture_processor.dart';
import '../widget/net_image.dart';

class ComicReaderPage extends StatefulWidget {
  final String chapterId;
  final String comicId;
  final String chapterTitle;
  final String extensionName;
  final int? initPage;
  final String? initChapterId;
  final Map<String, dynamic> extra;

  const ComicReaderPage(this.extensionName, this.chapterId, this.comicId,
      this.chapterTitle, this.extra,
      {super.key, this.initPage, this.initChapterId});

  @override
  _ComicReaderPageState createState() => _ComicReaderPageState(chapterId);
}

class _ComicReaderPageState extends State<ComicReaderPage> {
  String curChapterId;
  final PreloadPageController preloadController = PreloadPageController();
  List<String> images = [];
  GestureProcessor? gestureProcessor;
  bool isFristJump = true;
  ReadHistoryModel? lastRecordHistory;

  _ComicReaderPageState(this.curChapterId);

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    updateChapterAsync();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!updateReadHistory()) {
        return;
      }

      recordReadHistory();
      setState(() {});
    });
  }

  bool updateReadHistory() {
    if (lastRecordHistory != null &&
        lastRecordHistory!.chapterId == curChapterId &&
        lastRecordHistory!.index == preloadController.page?.toInt()) {
      return false;
    }

    lastRecordHistory =
        ReadHistoryModel(curChapterId, preloadController.page?.toInt() ?? 0);
    return true;
  }

  Future<void> recordReadHistory() async {
    ComicProvider comicProvider = context.read<ComicProvider>();
    comicProvider.recordReadHistory(
        getComicUniqueId(widget.comicId, widget.extensionName),
        curChapterId,
        preloadController.page?.toInt() ?? 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> updateChapterAsync() async {
    var detail = await getChapterDetail(
        widget.extensionName, curChapterId, widget.comicId, widget.extra);
    ChapterDetail chapterDetail =
        ChapterDetail.fromJson(detail as Map<String, dynamic>);
    updateImages(chapterDetail.images);
    if (isFristJump &&
        widget.initChapterId != null &&
        widget.initChapterId == curChapterId) {
      preloadController.jumpToPage(widget.initPage ?? 0);
      isFristJump = false;
    }
  }

  Future<bool> preChapter(BuildContext buildContext) async {
    var comicModel = buildContext.read<ComicProvider>().getHistoryComicModel(
        getComicUniqueId(widget.comicId, widget.extensionName));

    if (comicModel == null) return false;
    String? preChapterId = comicModel.preChapterId(curChapterId);
    if (preChapterId == null) return false;

    curChapterId = preChapterId;
    await updateChapterAsync();
    preloadController.jumpToPage(images.length - 1);
    return true;
  }

  Future<bool> nextChapter(BuildContext buildContext) async {
    var comicModel = buildContext.read<ComicProvider>().getHistoryComicModel(
        getComicUniqueId(widget.comicId, widget.extensionName));

    if (comicModel == null) return false;
    String? nextChapterId = comicModel.nextChapterId(curChapterId);
    if (nextChapterId == null) return false;
    curChapterId = nextChapterId;
    await updateChapterAsync();
    preloadController.jumpToPage(0);
    return true;
  }

  void updateImages(List<String> newImages) {
    setState(() {
      images = newImages;
    });
  }

  void nextPage(BuildContext buildContext) {
    int currentIndex = preloadController.page?.toInt() ?? 0;
    if (currentIndex < images.length - 1) {
      preloadController.jumpToPage(currentIndex + 1);
    } else {
      nextChapter(buildContext);
    }
  }

  void prevPage(BuildContext buildContext) {
    int currentIndex = preloadController.page?.toInt() ?? 0;
    if (currentIndex > 0) {
      preloadController.jumpToPage(currentIndex - 1);
    } else {
      preChapter(buildContext);
    }
  }

  String getPageText() {
    try {
      return '${(preloadController.page?.toInt() ?? 0) + 1}/${images.length}';
    } catch (e) {
      return '0/0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: GestureDetector(
          onPanStart: (details) {
            gestureProcessor = GestureProcessor(
                details.globalPosition, preloadController.position.pixels);
          },
          onPanUpdate: (details) {
            gestureProcessor?.update(details.globalPosition);
          },
          onPanEnd: (details) {
            gestureProcessor?.end(details.globalPosition);
            var result = gestureProcessor?.getResult();
            if (result == GestureResult.prevTap) {
              prevPage(context);
            } else if (result == GestureResult.nextTap) {
              nextPage(context);
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: PreloadPageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: images.length,
                  physics: null,
                  preloadPagesCount: 4,
                  controller: preloadController,
                  itemBuilder: (context, index) {
                    return NetImage(
                      NetImageType.reader,
                      NetImageContextReader(
                          widget.extensionName,
                          widget.comicId,
                          curChapterId,
                          images[index],
                          index,
                          widget.extra),
                      1.sw,
                      1.sh,
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Text(
                  getPageText(),
                  style: TextStyle(color: CupertinoColors.black),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
