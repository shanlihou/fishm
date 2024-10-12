// this page use for read comic image

import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/common/reader_chapters.dart';
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

enum InitOption {
  none,
  init,
  pre,
  next,
}

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
  PreloadPageController? preloadController;
  List<String> images = [];
  GestureProcessor? gestureProcessor;
  bool isFristJump = true;
  ReadHistoryModel? lastRecordHistory;
  bool lockSwap = false;
  int fingerNum = 0;
  int flags = 0;
  Map<String, ChapterDetail> chapterDetailMap = {};
  final ReaderChapters readerChapters = ReaderChapters();
  InitOption initOption = InitOption.none;

  _ComicReaderPageState(this.curChapterId);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initOption = InitOption.init;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // if (!updateReadHistory()) {
      //   return;
      // }

      // recordReadHistory();
      // setState(() {});
    });
  }

  Future<bool> _initAsync() async {
    print('initAsync: $curChapterId, $initOption');
    int curCount = readerChapters.imageCount;
    if (initOption == InitOption.init) {
      ChapterDetail detail = await _getChapterDetails(curChapterId);
      readerChapters.addChapter(detail, curChapterId);
      preloadController = PreloadPageController(initialPage: 10);
    } else if (initOption == InitOption.pre) {
      int curPage = _page;
      await _supplementChapter(false);
      preloadController = PreloadPageController(
          initialPage: curPage + readerChapters.imageCount - curCount);
    } else if (initOption == InitOption.next) {
      await _supplementChapter(true);
    }

    print('count change from $curCount to ${readerChapters.imageCount}');
    initOption = InitOption.none;
    return true;
  }

  bool updateReadHistory() {
    if (lastRecordHistory != null &&
        lastRecordHistory!.chapterId == curChapterId &&
        lastRecordHistory!.index == _page) {
      return false;
    }

    lastRecordHistory = ReadHistoryModel(curChapterId, _page);
    return true;
  }

  Future<void> recordReadHistory() async {
    ComicProvider comicProvider = context.read<ComicProvider>();
    comicProvider.recordReadHistory(
        getComicUniqueId(widget.comicId, widget.extensionName),
        curChapterId,
        _page);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<ChapterDetail> _getChapterDetails(String chapterId) async {
    var detail = await getChapterDetail(
        widget.extensionName, curChapterId, widget.comicId, widget.extra);
    return ChapterDetail.fromJson(detail as Map<String, dynamic>);
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
      preloadController?.jumpToPage(widget.initPage ?? 0);
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
    preloadController?.jumpToPage(images.length - 1);
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
    preloadController?.jumpToPage(0);
    return true;
  }

  void updateImages(List<String> newImages) {
    setState(() {
      images = newImages;
    });
  }

  int get _page {
    // round to int
    return (preloadController?.page ?? 0).round();
  }

  void nextPage(BuildContext buildContext) {
    if (lockSwap) return;

    int currentIndex = _page;
    if (currentIndex < images.length - 1) {
      preloadController?.jumpToPage(currentIndex + 1);
    } else {
      nextChapter(buildContext);
    }
  }

  void prevPage(BuildContext buildContext) {
    if (lockSwap) return;

    int currentIndex = _page;
    if (currentIndex > 0) {
      preloadController?.jumpToPage(currentIndex - 1);
    } else {
      preChapter(buildContext);
    }
  }

  String getPageText() {
    try {
      return '${_page + 1}/${images.length}';
    } catch (e) {
      return '0/0';
    }
  }

  void _updateFingers() {
    bool oldLockSwap = lockSwap;
    if (fingerNum > 1) {
      flags = bitSet(flags, readerFlagsFinger, true);
    } else {
      flags = bitSet(flags, readerFlagsFinger, false);
    }

    _updateLockSwap();
    if (oldLockSwap != lockSwap) {
      setState(() {});
    }
  }

  void _updateLockSwap() {
    if (bitGet(flags, readerFlagsScale) || bitGet(flags, readerFlagsFinger)) {
      lockSwap = true;
    } else {
      lockSwap = false;
    }
  }

  Widget _buildImage(BuildContext context, int index) {
    var ret = readerChapters.imageUrl(index);

    if (ret == null) {
      return SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: Center(
          child: Text('middle'),
        ),
      );
    }

    return PhotoView.customChild(
        backgroundDecoration: const BoxDecoration(
          color: CupertinoColors.white,
        ),
        wantKeepAlive: true,
        minScale: 1.0,
        initialScale: 1.0,
        onScaleEnd: (context, details, e) {
          // print('onScaleEnd: $details, $e');
          bool oldLockSwap = lockSwap;
          bool isSetFlags = (e.scale ?? 1) > 1.0;
          flags = bitSet(flags, readerFlagsScale, isSetFlags);
          _updateLockSwap();
          if (oldLockSwap != lockSwap) {
            setState(() {});
          }
        },
        child: NetImage(
          NetImageContextReader(widget.extensionName, widget.comicId,
              curChapterId, ret.$1, ret.$2, widget.extra),
          1.sw,
          1.sh,
        ));
  }

  Future<void> _supplementChapter(bool isNext) async {
    var comicModel = context.read<ComicProvider>().getHistoryComicModel(
        getComicUniqueId(widget.comicId, widget.extensionName));

    if (comicModel == null) return;

    if (isNext) {
      String last = readerChapters.lastChapterId();
      String? nextChapterId = comicModel.nextChapterId(last);
      if (nextChapterId == null) return;
      ChapterDetail detail = await _getChapterDetails(nextChapterId);
      readerChapters.addChapter(detail, nextChapterId);
      print('add next title: ${comicModel.getChapterTitle(nextChapterId)}');
    } else {
      String first = readerChapters.firstChapterId();
      String? preChapterId = comicModel.preChapterId(first);
      if (preChapterId == null) return;
      ChapterDetail detail = await _getChapterDetails(preChapterId);
      readerChapters.addChapterHead(detail, preChapterId);
      print('add pre title: ${comicModel.getChapterTitle(preChapterId)}');
    }

    setState(() {});
  }

  Widget buildPageView() {
    return Listener(
      onPointerSignal: (event) {},
      onPointerDown: (event) {
        fingerNum++;
        _updateFingers();
      },
      onPointerUp: (event) {
        fingerNum--;
        if (fingerNum < 0) {
          fingerNum = 0;
        }
        _updateFingers();
      },
      onPointerMove: (event) {
        // print('onPointerMove: $event');
      },
      onPointerCancel: (event) {
        fingerNum--;
        if (fingerNum < 0) {
          fingerNum = 0;
        }
        _updateFingers();
      },
      behavior: HitTestBehavior.translucent,
      child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: readerChapters.imageCount,
          physics: lockSwap ? const NeverScrollableScrollPhysics() : null,
          preloadPagesCount: 4,
          controller: preloadController,
          onPageChanged: (index) {
            print('onPageChanged: $index');
            if (index == 0) {
              initOption = InitOption.pre;
              setState(() {});
            } else if (index == readerChapters.imageCount - 1) {
              initOption = InitOption.next;
              setState(() {});
            }
          },
          itemBuilder: _buildImage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: FutureBuilder(
                future: _initAsync(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Text('loading');
                  } else if (snapshot.hasError) {
                    return Text('error');
                  } else if (!(snapshot.data ?? false)) {
                    return Text('no data');
                  } else {
                    return buildPageView();
                  }
                },
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          prevPage(context);
                        },
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: CupertinoColors.transparent),
                      )),
                  Expanded(flex: 6, child: Container()),
                  Expanded(
                      flex: 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          nextPage(context);
                        },
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: CupertinoColors.transparent),
                      ))
                ],
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
    );
  }
}
