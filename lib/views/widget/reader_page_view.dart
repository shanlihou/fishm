import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/models/api/chapter_detail.dart';

import '../../api/flutter_call_lua/method.dart';
import '../../const/general_const.dart';
import '../../types/common/reader_chapters.dart';
import '../../types/context/net_iamge_context.dart';
import '../../types/provider/comic_provider.dart';
import '../../utils/utils_general.dart';
import 'net_image.dart';

enum InitOption {
  none,
  init,
  pre,
  next,
}

class ReaderPageView extends StatefulWidget {
  final String extensionName;
  final String comicId;
  final String chapterId;

  final Map<String, dynamic> extra;

  const ReaderPageView(
      {super.key,
      required this.extensionName,
      required this.comicId,
      required this.chapterId,
      required this.extra});

  @override
  State<ReaderPageView> createState() => _ReaderPageViewState();
}

class _ReaderPageViewState extends State<ReaderPageView> {
  final Map<String, ChapterDetail> _chapterDetailMap = {};
  int _fingerNum = 0;
  bool _lockSwap = false;
  final ReaderChapters _readerChapters = ReaderChapters();
  int _flags = 0;
  PreloadPageController? _preloadController;
  InitOption _initOption = InitOption.none;

  @override
  void initState() {
    super.initState();
    _initOption = InitOption.init;
  }

  int get _page {
    return (_preloadController?.page ?? 0).round();
  }

  Future<void> _supplementChapter(bool isNext) async {
    var comicModel = context.read<ComicProvider>().getHistoryComicModel(
        getComicUniqueId(widget.comicId, widget.extensionName));

    if (comicModel == null) return;

    if (isNext) {
      String last = _readerChapters.lastChapterId();
      String? nextChapterId = comicModel.nextChapterId(last);
      if (nextChapterId == null) return;
      ChapterDetail detail = await _getChapterDetails(nextChapterId);
      _readerChapters.addChapter(detail, nextChapterId);
      print('add next title: ${comicModel.getChapterTitle(nextChapterId)}');
    } else {
      String first = _readerChapters.firstChapterId();
      String? preChapterId = comicModel.preChapterId(first);
      if (preChapterId == null) return;
      ChapterDetail detail = await _getChapterDetails(preChapterId);
      _readerChapters.addChapterHead(detail, preChapterId);
      print('add pre title: ${comicModel.getChapterTitle(preChapterId)}');
    }

    setState(() {});
  }

  Future<bool> _initAsync() async {
    int curCount = _readerChapters.imageCount;
    if (_initOption == InitOption.init) {
      ChapterDetail detail = await _getChapterDetails(widget.chapterId);
      _readerChapters.addChapter(detail, widget.chapterId);
      _preloadController = PreloadPageController(initialPage: 10);
    } else if (_initOption == InitOption.pre) {
      int curPage = _page;
      await _supplementChapter(false);
      _preloadController = PreloadPageController(
          initialPage: curPage + _readerChapters.imageCount - curCount);
    } else if (_initOption == InitOption.next) {
      await _supplementChapter(true);
    }

    print('count change from $curCount to ${_readerChapters.imageCount}');
    _initOption = InitOption.none;
    return true;
  }

  void _updateLockSwap() {
    if (bitGet(_flags, readerFlagsScale) || bitGet(_flags, readerFlagsFinger)) {
      _lockSwap = true;
    } else {
      _lockSwap = false;
    }
  }

  void _updateFingers() {
    bool oldLockSwap = _lockSwap;
    if (_fingerNum > 1) {
      _flags = bitSet(_flags, readerFlagsFinger, true);
    } else {
      _flags = bitSet(_flags, readerFlagsFinger, false);
    }

    _updateLockSwap();
    if (oldLockSwap != _lockSwap) {
      setState(() {});
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
          // print('onScaleEnd: $details, $e');
          bool oldLockSwap = _lockSwap;
          bool isSetFlags = (e.scale ?? 1) > 1.0;
          _flags = bitSet(_flags, readerFlagsScale, isSetFlags);
          _updateLockSwap();
          if (oldLockSwap != _lockSwap) {
            setState(() {});
          }
        },
        child: NetImage(
          NetImageContextReader(widget.extensionName, widget.comicId,
              widget.chapterId, ret.$1, ret.$2, widget.extra),
          1.sw,
          1.sh,
        ));
  }

  Widget _buildPageView() {
    return Listener(
      onPointerSignal: (event) {},
      onPointerDown: (event) {
        _fingerNum++;
        _updateFingers();
      },
      onPointerUp: (event) {
        _fingerNum--;
        if (_fingerNum < 0) {
          _fingerNum = 0;
        }
        _updateFingers();
      },
      onPointerMove: (event) {
        // print('onPointerMove: $event');
      },
      onPointerCancel: (event) {
        _fingerNum--;
        if (_fingerNum < 0) {
          _fingerNum = 0;
        }
        _updateFingers();
      },
      behavior: HitTestBehavior.translucent,
      child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _readerChapters.imageCount,
          physics: _lockSwap ? const NeverScrollableScrollPhysics() : null,
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
            }
          },
          itemBuilder: _buildImage),
    );
  }

  Future<ChapterDetail> _getChapterDetails(String chapterId) async {
    if (_chapterDetailMap.containsKey(chapterId)) {
      return _chapterDetailMap[chapterId]!;
    }

    var detail = await getChapterDetail(
        widget.extensionName, chapterId, widget.comicId, widget.extra);

    var chapterDetail = ChapterDetail.fromJson(detail as Map<String, dynamic>);
    _chapterDetailMap[chapterId] = chapterDetail;
    return chapterDetail;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                    onTap: () {},
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
                    onTap: () {},
                    child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: CupertinoColors.transparent),
                  ))
            ],
          ),
        ),
      ],
    );
  }
}
