// this page use for read comic image
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/common/reader_chapters.dart';
import 'package:toonfu/types/provider/comic_provider.dart';
import 'package:toonfu/utils/utils_general.dart';
import '../../const/general_const.dart';
import "../../models/api/chapter_detail.dart";
import 'package:preload_page_view/preload_page_view.dart';

import '../../models/db/comic_model.dart';
import '../../models/db/read_history_model.dart';
import '../../types/context/comic_reader_context.dart';
import '../../types/context/net_iamge_context.dart';
import '../widget/net_image.dart';

enum InitOption {
  none,
  init,
  pre,
  next,
  preChapter,
  nextChapter,
}

class MenuPageValue {
  final String chapterId;
  final bool show;
  final int page;

  MenuPageValue(this.chapterId, this.show, this.page);
}

class ComicReaderPage extends StatefulWidget {
  final ComicReaderContext readerContext;
  final int? initPage;
  final Map<String, dynamic> extra;

  const ComicReaderPage(this.readerContext, this.extra,
      {super.key, this.initPage});

  @override
  _ComicReaderPageState createState() => _ComicReaderPageState();
}

class _ComicReaderPageState extends State<ComicReaderPage> {
  PreloadPageController? _preloadController;
  ReadHistoryModel? _lastRecordHistory;
  int _fingerNum = 0;
  int _flags = 0;
  InitOption _initOption = InitOption.none;
  Timer? _timer;

  final ValueNotifier<String> _pageText = ValueNotifier('0/0');
  final ValueNotifier<MenuPageValue> _menuPage =
      ValueNotifier(MenuPageValue("", false, 0));
  final ValueNotifier<bool> _lockSwap = ValueNotifier(false);
  final ValueNotifier<double> _sliderValue = ValueNotifier(1);
  _ComicReaderPageState();

  @override
  void initState() {
    super.initState();
    _initOption = InitOption.init;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateReadHistory();
    });
  }

  void _updateReadHistory() {
    if (!_needUpdateReadHistory()) {
      return;
    }

    _recordReadHistory();
    _pageText.value = _getPageText();
  }

  void _setPageController(PreloadPageController controller) {
    if (_preloadController != null) {
      _preloadController?.dispose();
    }
    _preloadController = controller;
  }

  Future<bool> _initAsync() async {
    if (_initOption == InitOption.init) {
      int? initPage = await widget.readerContext.init(context);
      if (initPage == null) {
        return false;
      }

      _setPageController(PreloadPageController(initialPage: initPage));
    } else if (_initOption == InitOption.pre) {
      int newPage = await _supplementChapter(false);
      if (newPage == -1) {
        newPage = 0;
      }

      _setPageController(PreloadPageController(initialPage: newPage));
    } else if (_initOption == InitOption.next) {
      int newPage = await _supplementChapter(true);
      if (newPage == -1) {
        newPage = _readerChapters.imageCount - 1;
      }

      _setPageController(PreloadPageController(initialPage: newPage));
    } else if (_initOption == InitOption.preChapter) {
      await _supplementChapter(false);

      _setPageController(PreloadPageController(initialPage: 1));

      _menuPage.value =
          MenuPageValue(_readerChapters.firstChapterId(), true, 1);
    } else if (_initOption == InitOption.nextChapter) {
      await _supplementChapter(true);
      int page = _readerChapters
          .getChapterIamgeRange(_readerChapters.lastChapterId())!
          .$1;

      _setPageController(PreloadPageController(initialPage: page));
      _menuPage.value = MenuPageValue(_readerChapters.lastChapterId(), true, 1);
    }

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
    await widget.readerContext.recordReadHistory(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _preloadController?.dispose();
    super.dispose();
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
    } catch (e) {}
  }

  void _prevPage(BuildContext buildContext) {
    if (_lockSwap.value) return;

    try {
      int currentIndex = _page;
      if (currentIndex > 0) {
        _preloadController?.jumpToPage(currentIndex - 1);
      }
    } catch (e) {}
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

  (String?, String?) _buildMiddleText(BuildContext context, int index) {
    var preRet = _readerChapters.imageUrl(index - 1);
    var nextRet = _readerChapters.imageUrl(index + 1);
    var comicModel = context.read<ComicProvider>().getHistoryComicModel(
        getComicUniqueId(widget.comicId, widget.extensionName));

    if (comicModel == null) return (null, null);

    if (preRet == null && nextRet == null) {
      return (null, null);
    }

    if (preRet == null) {
      String preChapterId = comicModel.preChapterId(nextRet!.$3) ?? '';
      String? preChapterTitle = comicModel.getChapterTitle(preChapterId);
      String? nextChapterTitle = comicModel.getChapterTitle(nextRet.$3);
      return (preChapterTitle, nextChapterTitle);
    }

    if (nextRet == null) {
      String nextChapterId = comicModel.nextChapterId(preRet.$3) ?? '';
      String? preChapterTitle = comicModel.getChapterTitle(preRet.$3);
      String? nextChapterTitle = comicModel.getChapterTitle(nextChapterId);
      return (preChapterTitle, nextChapterTitle);
    }

    String? preChapterTitle = comicModel.getChapterTitle(preRet.$3);
    String? nextChapterTitle = comicModel.getChapterTitle(nextRet.$3);
    return (preChapterTitle, nextChapterTitle);
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
      var (pre, next) = _buildMiddleText(context, index);
      return SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: Center(
          child: Column(
            children: [
              Text(pre ?? ''),
              Text(next ?? ''),
            ],
          ),
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
          bool issetFlags = (e.scale ?? 1) > 1.0;
          _flags = bitSet(_flags, readerFlagsScale, issetFlags);
          _updateLockSwap();
        },
        child: NetImage(
          NetImageContextReader(widget.extensionName, widget.comicId, ret.$3,
              ret.$1, ret.$2, widget.extra),
          width: 1.sw,
          height: 1.sh,
        ));
  }

  void _preChapter(String curChapterId) {
    var preChapterId = context
        .read<ComicProvider>()
        .getHistoryComicModel(
            getComicUniqueId(widget.comicId, widget.extensionName))
        ?.preChapterId(curChapterId);

    if (preChapterId == null) return;

    int? page = _readerChapters.chapterFirstPageIndex(preChapterId);
    if (page == null) {
      _initOption = InitOption.preChapter;
      setState(() {});
      return;
    }

    _preloadController?.jumpToPage(page);
    _menuPage.value = MenuPageValue(preChapterId, true, 1);
  }

  void _nextChapter(String curChapterId) {
    var nextChapterId = context
        .read<ComicProvider>()
        .getHistoryComicModel(
            getComicUniqueId(widget.comicId, widget.extensionName))
        ?.nextChapterId(curChapterId);

    if (nextChapterId == null) return;

    int? page = _readerChapters.chapterFirstPageIndex(nextChapterId);
    if (page == null) {
      _initOption = InitOption.nextChapter;
      setState(() {});
      return;
    }

    _preloadController?.jumpToPage(page);
    _menuPage.value = MenuPageValue(nextChapterId, true, 1);
  }

  Future<int> _supplementChapter(bool isNext) async {
    var p = context.read<ComicProvider>();
    var comicModel = p.getHistoryComicModel(
        getComicUniqueId(widget.comicId, widget.extensionName));

    if (comicModel == null) return -1;

    if (isNext) {
      String last = _readerChapters.lastChapterId();
      String? nextChapterId = comicModel.nextChapterId(last);
      if (nextChapterId == null) return -1;
      ChapterDetail detail = (await getChapterDetails(
          comicModel, widget.extensionName, widget.comicId, nextChapterId))!;
      await p.saveComic(comicModel);
      _readerChapters.addChapter(detail, nextChapterId);
      _readerChapters.frontPop();
      return _readerChapters.firstMiddlePageIndex();
    } else {
      String first = _readerChapters.firstChapterId();
      String? preChapterId = comicModel.preChapterId(first);
      if (preChapterId == null) return -1;
      ChapterDetail detail = (await getChapterDetails(
          comicModel, widget.extensionName, widget.comicId, preChapterId))!;
      await p.saveComic(comicModel);
      _readerChapters.addChapterHead(detail, preChapterId);
      _readerChapters.backPop();
      return _readerChapters.firstMiddlePageIndex();
    }
  }

  void _jumpToPage(int curPage, String chapterId) {
    int? page = _readerChapters.calcPage(chapterId, curPage);
    if (page == null) return;
    _preloadController?.jumpToPage(page);
  }

  Widget _buildMenu() {
    _sliderValue.value = _menuPage.value.page.toDouble();
    int imageCount =
        _readerChapters.getChapterImageCount(_menuPage.value.chapterId);

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: CupertinoColors.systemRed,
          ),
        ),
        Expanded(
          flex: 6,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _menuPage.value = MenuPageValue("", false, 0);
            },
            child: Container(
              color: CupertinoColors.transparent,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0.1.sw),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    _preChapter(_menuPage.value.chapterId);
                  },
                  icon: const Icon(CupertinoIcons.back),
                ),
                Expanded(
                  child: Material(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: SliderComponentShape.noThumb,
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: _sliderValue,
                        builder: (context, value, child) {
                          return Slider(
                            min: 1,
                            max: imageCount.toDouble(),
                            divisions: imageCount - 1,
                            value: value,
                            label: value.toInt().toString(),
                            onChanged: (value) {
                              _sliderValue.value = value;
                              _jumpToPage(
                                  value.toInt(), _menuPage.value.chapterId);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _nextChapter(_menuPage.value.chapterId);
                  },
                  icon: const Icon(CupertinoIcons.forward),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
              itemCount: widget.readerContext.imageCount,
              physics: value ? const NeverScrollableScrollPhysics() : null,
              preloadPagesCount: 4,
              controller: _preloadController,
              onPageChanged: (index) {
                if (index == 0) {
                  _initOption = InitOption.pre;
                  setState(() {});
                } else if (index == widget.readerContext.imageCount - 1) {
                  _initOption = InitOption.next;
                  setState(() {});
                } else {
                  _updateReadHistory();
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
                      child: const Center(child: Text('loading...')),
                    );
                  } else if (snapshot.hasError) {
                    return const Text('error');
                  } else if (!(snapshot.data ?? false)) {
                    return const Text('no data');
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
                  Expanded(
                      flex: 6,
                      child: Center(
                        child: SizedBox(
                          width: 0.1.sw,
                          height: 0.1.sh,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _menuPage.value = MenuPageValue(
                                  _lastRecordHistory!.chapterId,
                                  true,
                                  _lastRecordHistory!.index);
                            },
                            child: Container(
                              color: CupertinoColors.transparent,
                            ),
                          ),
                        ),
                      )),
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
              right: 0.1.sw,
              child: ValueListenableBuilder(
                valueListenable: _pageText,
                builder: (context, value, child) {
                  return Text(
                    value,
                    style: const TextStyle(color: CupertinoColors.black),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: ValueListenableBuilder(
                valueListenable: _menuPage,
                builder: (context, value, child) {
                  if (!value.show) {
                    return Container();
                  }

                  return _buildMenu();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
