import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:photo_view/photo_view.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:toonfu/const/assets_const.dart';

import '../../common/log.dart';
import '../../const/color_const.dart';
import '../../const/general_const.dart';
import '../../types/context/comic_reader_context.dart';
import '../../utils/utils_general.dart';
import '../class/hollow_slider_tumb_shape.dart';
import '../widget/select_widget.dart';

enum InitOption {
  none,
  init,
  pre,
  next,
  preChapter,
  nextChapter,
  jumpToChapter,
}

class MenuPageValue {
  final bool show;
  final int page;

  MenuPageValue(this.show, this.page);
}

class ReaderPage extends StatefulWidget {
  final ComicReaderContext readerContext;
  const ReaderPage({super.key, required this.readerContext});
  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  int _fingerNum = 0;
  int _flags = 0;
  InitOption _initOption = InitOption.init;
  PreloadPageController? _preloadController;
  final ValueNotifier<bool> _lockSwap = ValueNotifier(false);
  final ValueNotifier<String> _pageText = ValueNotifier('0/0');
  final ValueNotifier<MenuPageValue> _menuPage =
      ValueNotifier(MenuPageValue(false, 0));
  final ValueNotifier<double> _sliderValue = ValueNotifier(1);
  Timer? _timer;
  String? _jumpToChapterId;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_preloadController == null) {
        return;
      }

      if (_page == null) {
        return;
      }

      widget.readerContext.recordHistory(context, _page!);
    });
  }

  void _updateLockSwap() {
    if (bitGet(_flags, readerFlagsScale) || bitGet(_flags, readerFlagsFinger)) {
      _lockSwap.value = true;
    } else {
      _lockSwap.value = false;
    }
  }

  void _setPageController(PreloadPageController controller) {
    if (_preloadController != null) {
      _preloadController?.dispose();
    }
    _preloadController = controller;
  }

  void _updateFingers() {
    if (_fingerNum > 1) {
      _flags = bitSet(_flags, readerFlagsFinger, true);
    } else {
      _flags = bitSet(_flags, readerFlagsFinger, false);
    }

    _updateLockSwap();
  }

  Widget _buildImage(BuildContext context, int index) {
    var imageWidget = widget.readerContext.getImage(context, index);

    if (imageWidget == null) {
      var (pre, next) = widget.readerContext.buildMiddleText(context, index);
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
        child: imageWidget);
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
              scrollDirection: Axis.horizontal,
              itemCount: widget.readerContext.imageCount,
              physics: value ? const NeverScrollableScrollPhysics() : null,
              preloadPagesCount: 4,
              controller: _preloadController,
              onPageChanged: (index) {
                if (index == 0) {
                  print(
                      'on page changed: $index, ${widget.readerContext.imageCount}');
                  if (widget.readerContext.imageCount <= 1) {
                    _initOption = InitOption.init;
                  } else {
                    _initOption = InitOption.pre;
                  }
                  setState(() {});
                } else if (index == widget.readerContext.imageCount - 1) {
                  _initOption = InitOption.next;
                  setState(() {});
                } else {
                  _pageText.value =
                      widget.readerContext.getPageText(context, index);
                  widget.readerContext.recordHistory(context, index);
                }
              },
              itemBuilder: _buildImage);
        },
      ),
    );
  }

  @override
  void dispose() {
    _preloadController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _doOption() async {
    try {
      if (_initOption == InitOption.init) {
        int? newPage = await widget.readerContext.init(context);
        if (newPage == null) {
          return false;
        }

        _setPageController(PreloadPageController(initialPage: newPage));
        _pageText.value = widget.readerContext.getPageText(context, newPage);
        widget.readerContext.recordHistory(context, newPage);
      } else if (_initOption == InitOption.pre) {
        int newPage =
            await widget.readerContext.supplementChapter(context, false);

        if (newPage == -1) {
          newPage = 0;
        }

        _setPageController(PreloadPageController(initialPage: newPage));
        widget.readerContext.recordHistory(context, newPage);
      } else if (_initOption == InitOption.next) {
        int newPage =
            await widget.readerContext.supplementChapter(context, true);

        if (newPage == -1) {
          newPage = widget.readerContext.imageCount - 1;
        }

        _setPageController(PreloadPageController(initialPage: newPage));
        widget.readerContext.recordHistory(context, newPage);
      } else if (_initOption == InitOption.preChapter) {
        await widget.readerContext.supplementChapter(context, false);

        _setPageController(PreloadPageController(initialPage: 1));
        widget.readerContext.recordHistory(context, 1);
        _menuPage.value = MenuPageValue(true, 1);
        _pageText.value = widget.readerContext.getPageText(context, 1);
      } else if (_initOption == InitOption.nextChapter) {
        await widget.readerContext.supplementChapter(context, true);

        int newPage = widget.readerContext.lastChapterFirstPageIndex();
        _setPageController(PreloadPageController(initialPage: newPage));
        widget.readerContext.recordHistory(context, newPage);
        _pageText.value = widget.readerContext.getPageText(context, newPage);
        _menuPage.value = MenuPageValue(true, 1);
      } else if (_initOption == InitOption.jumpToChapter) {
        await widget.readerContext.jumpToChapter(context, _jumpToChapterId!);

        int newPage = 1;
        _setPageController(PreloadPageController(initialPage: newPage));
        widget.readerContext.recordHistory(context, newPage);
        _pageText.value = widget.readerContext.getPageText(context, newPage);
        _menuPage.value = MenuPageValue(true, 1);
      }

      _jumpToChapterId = null;
      _initOption = InitOption.none;
    } catch (e, s) {
      Log.instance.e('doOption error: $e, $s');
      return false;
    }
    return true;
  }

  int? get _page {
    if (_preloadController == null) {
      return null;
    }

    if (_preloadController!.positions.isEmpty) {
      return null;
    }

    return (_preloadController?.page ?? 0).round();
  }

  void _prevPage() {
    if (_lockSwap.value) {
      return;
    }

    if (_page == null) {
      return;
    }

    int currentIndex = _page!;
    if (currentIndex > 0) {
      _preloadController?.jumpToPage(currentIndex - 1);
    }
  }

  void _nextPage() {
    if (_lockSwap.value) {
      return;
    }

    if (_page == null) {
      return;
    }

    int currentIndex = _page!;
    if (currentIndex < widget.readerContext.imageCount - 1) {
      _preloadController?.jumpToPage(currentIndex + 1);
    }
  }

  void _preChapter() {
    int? newPage = widget.readerContext.preChapter(context);
    if (newPage == null) {
      _initOption = InitOption.preChapter;
      setState(() {});
      return;
    }

    _preloadController?.jumpToPage(newPage);
    _menuPage.value = MenuPageValue(true, 1);
  }

  void _nextChapter() {
    int? newPage = widget.readerContext.nextChapter(context);
    if (newPage == null) {
      _initOption = InitOption.nextChapter;
      setState(() {});
      return;
    }

    _preloadController?.jumpToPage(newPage);
    _menuPage.value = MenuPageValue(true, 1);
  }

  void _jumpToPage(int page) {
    int? absolutePage = widget.readerContext.getAbsolutePage(page);
    if (absolutePage == null) {
      return;
    }

    _preloadController?.jumpToPage(absolutePage);
  }

  Widget _buildMenu() {
    _sliderValue.value = _menuPage.value.page.toDouble();
    int imageCount = widget.readerContext.chapterImageCount();

    return Column(
      children: [
        // top start ----------------------------
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.bottomLeft,
            color: commonBlue.withOpacity(0.5),
            child: Row(children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  size: 60.r,
                  CupertinoIcons.back,
                  color: CupertinoColors.white,
                ),
              ),
              Container(
                height: 60.h,
                margin: EdgeInsets.only(left: 10.w, right: 10.w),
                child: Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  '${widget.readerContext.getTitle(context)}',
                  style: TextStyle(
                      fontSize: pm(20, 40.spMin), color: CupertinoColors.white),
                ),
              ),
              material.Material(
                child: SelectWidget(
                  valueChanged: (value) {
                    _initOption = InitOption.jumpToChapter;
                    _jumpToChapterId = value;
                    setState(() {});
                  },
                  items: widget.readerContext.getChapterItems(context),
                  defaultIndex:
                      widget.readerContext.currentChapterIndex(context),
                ),
              ),
            ]),
          ),
        ),
        // top end ----------------------------
        Expanded(
          flex: 6,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _menuPage.value = MenuPageValue(false, 0);
            },
            child: Container(
              color: CupertinoColors.transparent,
            ),
          ),
        ),
        // bottom start ----------------------------
        Container(
          margin:
              EdgeInsets.only(top: 20.h, bottom: 40.h, left: 40.w, right: 40.w),
          height: 250.h,
          decoration: BoxDecoration(
            color: CupertinoColors.white.withOpacity(0.5),
            border: GradientBoxBorder(
                gradient: LinearGradient(colors: [
              CupertinoColors.systemBlue.withOpacity(0.5),
              sliderColor.withOpacity(0.5),
            ])),
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.all(10.r),
          child: Row(
            children: [
              material.IconButton(
                onPressed: _preChapter,
                icon: Icon(
                  size: 60.r,
                  CupertinoIcons.backward_end_alt,
                  color: sliderColor,
                ),
              ),
              Expanded(
                child: material.Material(
                  color: CupertinoColors.white.withOpacity(0.5),
                  child: ValueListenableBuilder(
                    valueListenable: _sliderValue,
                    builder: (context, value, child) {
                      if (imageCount == 0) {
                        return Container();
                      }

                      return Column(
                        // slider start ----------------------------
                        children: [
                          Container(
                            height: 100.h,
                            margin: EdgeInsets.only(top: 50.h),
                            child: material.SliderTheme(
                              data: material.SliderThemeData(
                                trackHeight: 5.h,
                                activeTrackColor: sliderColor,
                                overlayColor: sliderColor.withOpacity(0.5),
                                overlayShape: material.RoundSliderOverlayShape(
                                  overlayRadius: 40.r,
                                ),
                                tickMarkShape:
                                    material.SliderTickMarkShape.noTickMark,
                                thumbShape: HollowSliderThumbShape(
                                  radius: 30.r,
                                  color: sliderColor,
                                  borderWidth: 5.r,
                                ),
                              ),
                              child: material.Slider(
                                min: 1,
                                max: imageCount.toDouble(),
                                divisions: imageCount - 1,
                                value: value,
                                onChanged: (value) {
                                  _sliderValue.value = value;
                                  _jumpToPage(value.toInt());
                                },
                              ),
                            ),
                          ),
                          Text(
                            style: const TextStyle(
                              color: sliderColor,
                            ),
                            '${value.toInt()}/$imageCount',
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              material.IconButton(
                onPressed: _nextChapter,
                icon: Icon(
                  size: 60.r,
                  CupertinoIcons.forward_end_alt,
                  color: sliderColor,
                ),
              ),
            ],
          ),
        ),
      ],
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
                future: _doOption(),
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
                          _prevPage();
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
                              _menuPage.value = MenuPageValue(true,
                                  widget.readerContext.historyChapterPage);
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
                          _nextPage();
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
