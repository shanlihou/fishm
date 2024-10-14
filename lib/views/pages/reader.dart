// this page use for read comic image

import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/common/reader_chapters.dart';
import 'package:toonfu/types/provider/comic_provider.dart';
import 'package:toonfu/utils/utils_general.dart';
import "../../api/flutter_call_lua/method.dart";
import '../../common/log.dart';
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
  _ComicReaderPageState createState() => _ComicReaderPageState();
}

class _ComicReaderPageState extends State<ComicReaderPage> {
  PreloadPageController? _preloadController;
  ReadHistoryModel? _lastRecordHistory;
  int _fingerNum = 0;
  int _flags = 0;
  Map<String, ChapterDetail> _chapterDetailMap = {};
  final ReaderChapters _readerChapters = ReaderChapters();
  InitOption _initOption = InitOption.none;
  Timer? _timer;

  // value notifier
  ValueNotifier<String> _pageText = ValueNotifier('0/0');
  ValueNotifier<bool> _lockSwap = ValueNotifier(false);

  _ComicReaderPageState();

  @override
  void initState() {
    super.initState();
    _initOption = InitOption.init;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_needUpdateReadHistory()) {
        return;
      }

      _recordReadHistory();
      _pageText.value = _getPageText();
    });
  }

  Future<bool> _initAsync() async {
    int curCount = _readerChapters.imageCount;
    if (_initOption == InitOption.init) {
      ChapterDetail detail = await _getChapterDetails(widget.chapterId);
      _readerChapters.addChapter(detail, widget.chapterId);
      _preloadController =
          PreloadPageController(initialPage: widget.initPage ?? 1);
    } else if (_initOption == InitOption.pre) {
      int newPage = await _supplementChapter(false);
      _preloadController = PreloadPageController(initialPage: newPage);
    } else if (_initOption == InitOption.next) {
      int newPage = await _supplementChapter(true);
      _preloadController = PreloadPageController(initialPage: newPage);
    }

    print('count change from $curCount to ${_readerChapters.imageCount}');
    _initOption = InitOption.none;
    return true;
  }

  bool _needUpdateReadHistory() {
    try {
      var ret = _readerChapters.imageUrl(_page);
      if (ret == null) return false;

      if (_lastRecordHistory != null &&
          _lastRecordHistory!.chapterId == ret.$3 &&
          _lastRecordHistory!.index == ret.$2 + 1) {
        return false;
      }

      _lastRecordHistory = ReadHistoryModel(ret.$3, ret.$2 + 1);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _recordReadHistory() async {
    ComicProvider comicProvider = context.read<ComicProvider>();
    comicProvider.recordReadHistory(
        getComicUniqueId(widget.comicId, widget.extensionName),
        _lastRecordHistory!.chapterId,
        _lastRecordHistory!.index);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<ChapterDetail> _getChapterDetails(String chapterId) async {
    if (_chapterDetailMap.containsKey(chapterId)) {
      return _chapterDetailMap[chapterId]!;
    }

    var detail = await getChapterDetail(
        widget.extensionName, chapterId, widget.comicId, widget.extra);

    ChapterDetail chapterDetail =
        ChapterDetail.fromJson(detail as Map<String, dynamic>);
    _chapterDetailMap[chapterId] = chapterDetail;

    return chapterDetail;
  }

  int get _page {
    return (_preloadController?.page ?? 0).round();
  }

  void _nextPage(BuildContext buildContext) {
    if (_lockSwap.value) return;

    try {
      int currentIndex = _page;
      if (currentIndex < _readerChapters.imageCount - 1) {
        _preloadController?.jumpToPage(currentIndex + 1);
      }
    } catch (e) {
      Log.instance.e('error: $e');
    }
  }

  void _prevPage(BuildContext buildContext) {
    if (_lockSwap.value) return;

    try {
      int currentIndex = _page;
      if (currentIndex > 0) {
        _preloadController?.jumpToPage(currentIndex - 1);
      }
    } catch (e) {
      Log.instance.e('error: $e');
    }
  }

  String _getPageText() {
    try {
      var ret = _readerChapters.imageUrl(_page);
      if (ret == null) return '0/0';

      var comicModel = context.read<ComicProvider>().getHistoryComicModel(
          getComicUniqueId(widget.comicId, widget.extensionName));
      if (comicModel == null) return '0/0';
      String chapterTitle = comicModel.getChapterTitle(ret.$3) ?? '';
      return ' $chapterTitle ${ret.$2 + 1}/${ret.$4}';
    } catch (e) {
      return '0/0';
    }
  }

  void _updateFingers() {
    if (_fingerNum > 1) {
      _flags = bitSet(_flags, readerFlagsFinger, true);
    } else {
      _flags = bitSet(_flags, readerFlagsFinger, false);
    }

    _updateLockSwap();
  }

  void _updateLockSwap() {
    if (bitGet(_flags, readerFlagsScale) || bitGet(_flags, readerFlagsFinger)) {
      _lockSwap.value = true;
    } else {
      _lockSwap.value = false;
    }
  }

  Widget _buildImage(BuildContext context, int index) {
    var ret = _readerChapters.imageUrl(index);

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
          bool isSet_flags = (e.scale ?? 1) > 1.0;
          _flags = bitSet(_flags, readerFlagsScale, isSet_flags);
          _updateLockSwap();
        },
        child: NetImage(
          NetImageContextReader(widget.extensionName, widget.comicId, ret.$3,
              ret.$1, ret.$2, widget.extra),
          1.sw,
          1.sh,
        ));
  }

  Future<int> _supplementChapter(bool isNext) async {
    var comicModel = context.read<ComicProvider>().getHistoryComicModel(
        getComicUniqueId(widget.comicId, widget.extensionName));

    if (comicModel == null) return -1;

    if (isNext) {
      String last = _readerChapters.lastChapterId();
      String? nextChapterId = comicModel.nextChapterId(last);
      if (nextChapterId == null) return -1;
      ChapterDetail detail = await _getChapterDetails(nextChapterId);
      _readerChapters.addChapter(detail, nextChapterId);
      _readerChapters.frontPop();
      return _readerChapters.firstMiddlePageIndex();
    } else {
      String first = _readerChapters.firstChapterId();
      String? preChapterId = comicModel.preChapterId(first);
      if (preChapterId == null) return -1;
      ChapterDetail detail = await _getChapterDetails(preChapterId);
      _readerChapters.addChapterHead(detail, preChapterId);
      _readerChapters.backPop();
      return _readerChapters.firstMiddlePageIndex();
    }
  }

  Widget _buildPageView() {
    return Listener(
      onPointerSignal: (event) {},
      onPointerDown: (event) {
        _fingerNum++;
        _updateFingers();
      },
      onPointerUp: (event) {
        _fingerNum = max(0, _fingerNum - 1);
        _updateFingers();
      },
      onPointerMove: (event) {},
      onPointerCancel: (event) {
        _fingerNum = max(0, _fingerNum - 1);
        _updateFingers();
      },
      behavior: HitTestBehavior.translucent,
      child: ValueListenableBuilder(
        valueListenable: _lockSwap,
        builder: (context, value, child) {
          return PreloadPageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _readerChapters.imageCount,
              physics: value ? const NeverScrollableScrollPhysics() : null,
              preloadPagesCount: 4,
              controller: _preloadController,
              onPageChanged: (index) {
                print('onPageChanged: $index');
                if (index == 0) {
                  _initOption = InitOption.pre;
                  setState(() {});
                } else if (index == _readerChapters.imageCount - 1) {
                  _initOption = InitOption.next;
                  setState(() {});
                } else {
                  _pageText.value = _getPageText();
                }
              },
              itemBuilder: _buildImage);
        },
      ),
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
                    return SizedBox(
                      width: 1.sw,
                      height: 1.sh,
                      child: Center(child: Text('loading...')),
                    );
                  } else if (snapshot.hasError) {
                    return Text('error');
                  } else if (!(snapshot.data ?? false)) {
                    return Text('no data');
                  } else {
                    return _buildPageView();
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
                          _prevPage(context);
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
                          _nextPage(context);
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
              child: ValueListenableBuilder(
                valueListenable: _pageText,
                builder: (context, value, child) {
                  return Text(
                    value,
                    style: TextStyle(color: CupertinoColors.black),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
