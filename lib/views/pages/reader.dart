// this page use for read comic image

import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
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
  bool lockSwap = false;
  final PageController pageController = PageController();
  int fingerNum = 0;
  int flags = 0;

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

  // Widget buildPageView() {
  //   return Container(
  //       child: PhotoViewGallery.builder(
  //     builder: (BuildContext context, int index) {
  //       return PhotoViewGalleryPageOptions(
  //           imageProvider: NetImageProvider(
  //         NetImageContextReader(widget.extensionName, widget.comicId,
  //             curChapterId, images[index], index, widget.extra),
  //       ));
  //     },
  //     itemCount: images.length,
  //     loadingBuilder: (context, event) => Center(
  //       child: Container(
  //         width: 20.0,
  //         height: 20.0,
  //         child: const CupertinoActivityIndicator(),
  //       ),
  //     ),
  //     backgroundDecoration: BoxDecoration(
  //       color: CupertinoColors.black,
  //     ),
  //     pageController: pageController,
  //     onPageChanged: (index) {
  //       print('onPageChanged: $index');
  //     },
  //   ));
  // }

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
          itemCount: images.length,
          physics: lockSwap ? const NeverScrollableScrollPhysics() : null,
          preloadPagesCount: 4,
          controller: preloadController,
          itemBuilder: (context, index) {
            return PhotoView.customChild(
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
                // child: Image(
                //   image: NetImageProvider(NetImageContextReader(
                //       widget.extensionName,
                //       widget.comicId,
                //       curChapterId,
                //       images[index],
                //       index,
                //       widget.extra)),
                // ),
                child: NetImage(
                  NetImageContextReader(widget.extensionName, widget.comicId,
                      curChapterId, images[index], index, widget.extra),
                  1.sw,
                  1.sh,
                ));
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: buildPageView(),
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
