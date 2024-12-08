import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/const/color_const.dart';
import 'package:toonfu/types/provider/comic_provider.dart';
import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';
import '../../const/assets_const.dart';
import '../../const/general_const.dart';
import '../../models/api/comic_detail.dart';
import '../../models/db/comic_model.dart';
import '../../models/db/read_history_model.dart';
import '../../types/context/extension_comic_reader_context.dart';
import '../../types/manager/global_manager.dart';
import '../../types/provider/task_provider.dart';
import '../../utils/utils_general.dart';
import '../../views/class/comic_item.dart';
import '../dialog/loading_dialog.dart';
import '../widget/comic_chapter_status_widget.dart';
import '../widget/net_image.dart';
import '../../types/context/net_iamge_context.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import 'reader_page.dart';

class ComicDetailPage extends StatefulWidget {
  final ComicItem comicItem;
  final String extensionName;

  const ComicDetailPage(
    this.comicItem,
    this.extensionName, {
    super.key,
  });

  @override
  _ComicDetailPageState createState() => _ComicDetailPageState();
}

class _ComicDetailPageState extends State<ComicDetailPage> {
  bool _isAsyncInit = false;

  final ValueNotifier<bool> _isFavorite = ValueNotifier(false);

  bool _isFetchChapterDownCnt = false;
  bool _dispose = false;

  @override
  void initState() {
    super.initState();
    _isFavorite.value =
        context.read<ComicProvider>().favoriteComics.containsKey(
              getComicUniqueId(widget.comicItem.comicId, widget.extensionName),
            );
  }

  @override
  void dispose() {
    _dispose = true;
    super.dispose();
  }

  Future<void> _fetchChapterDownCnts() async {
    if (_isFetchChapterDownCnt) {
      return;
    }

    _isFetchChapterDownCnt = true;

    var p = context.read<ComicProvider>();
    ComicModel? comicModel = p.getComicModel(
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName));

    if (comicModel == null) {
      _isFetchChapterDownCnt = false;
      return;
    }

    if (comicModel.chapters.isEmpty) {
      _isFetchChapterDownCnt = false;
      return;
    }

    for (var chapter in comicModel.chapters) {
      if (_dispose) {
        break;
      }
      if (chapter.images.isEmpty) {
        Log.instance.d('fetch chapter once');
        await getChapterDetails(comicModel, widget.extensionName,
            widget.comicItem.comicId, chapter.id);

        await p.saveComic(comicModel, isNotify: true);
      }
    }

    _isFetchChapterDownCnt = false;
  }

  Future<void> _initWithContext() async {
    if (_isAsyncInit) {
      return;
    }
    _isAsyncInit = true;
    var provider = context.read<ComicProvider>();
    ComicModel? comicModel = provider.getComicModel(
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName));

    if (comicModel != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      await provider.addComic(comicModel, true);

      Future.delayed(const Duration(milliseconds: 100), () {
        _fetchChapterDownCnts();
      });
      return;
    }

    Object ret = await getDetail(
        widget.extensionName, widget.comicItem.comicId, widget.comicItem.extra);

    ComicDetail detail;
    try {
      detail = ComicDetail.fromJson(ret as Map<String, dynamic>);
    } catch (e) {
      Log.instance.e('get comic detail failed: $e');
      return;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    await provider.addComic(
        ComicModel.fromComicDetail(detail, widget.extensionName), true);

    Future.delayed(const Duration(milliseconds: 100), () {
      _fetchChapterDownCnts();
    });
  }

  void _toggleFavorite() {
    String uniqueId =
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName);
    bool isFavorite = context.read<ComicProvider>().isFavoriteComic(uniqueId);

    if (isFavorite) {
      context.read<ComicProvider>().removeFavoriteComic(uniqueId);
    } else {
      context.read<ComicProvider>().addFavoriteComic(uniqueId);
    }
  }

  Future<void> _exportChapterToCbz(
      BuildContext buildContext, ChapterModel chapter) async {
    var comicProvider = buildContext.read<ComicProvider>();
    var taskProvider = buildContext.read<TaskProvider>();
    ComicChapterStatus status = getChapterStatus(comicProvider, taskProvider,
        widget.comicItem.comicId, widget.extensionName, chapter.id);

    if (status != ComicChapterStatus.downloaded) {
      Log.instance.d('chapter is not downloaded');
      return;
    }

    String folder = imageChapterFolder(
        widget.extensionName, widget.comicItem.comicId, chapter.id);
    var encoder = ZipFileEncoder();

    String outName =
        '${widget.extensionName}-${widget.comicItem.title}-${chapter.title}.cbz';

    await encoder.zipDirectoryAsync(Directory(folder),
        filename: '$cbzOutputDir/$outName');
    Log.instance.d('export chapter to cbz: $outName');
  }

  Widget _buildChapterItem(
      BuildContext buildContext, ChapterModel chapter, int idx) {
    return GestureDetector(
      onLongPress: () {
        _exportChapterToCbz(buildContext, chapter);
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.fromLTRB(0, 20.h, 0, 0),
        height: 100.h,
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(chapter.title),
              ),
            ),
            SizedBox(
              width: 200.w,
              child: Align(
                alignment: Alignment.centerRight,
                child: ComicChapterStatusWidget(
                  extensionName: widget.extensionName,
                  comicId: widget.comicItem.comicId,
                  chapterId: chapter.id,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterList(BuildContext buildContext, ComicModel comicModel) {
    return Column(
      children: [
        for (var chapter in comicModel.chapters.asMap().entries)
          GestureDetector(
            onTap: () {
              Navigator.push(
                buildContext,
                CupertinoPageRoute(
                  builder: (context) => ReaderPage(
                    readerContext: ExtensionComicReaderContext(
                      widget.extensionName,
                      comicModel.id,
                      chapter.value.id,
                      null,
                      comicModel.extra,
                    ),
                  ),
                ),
              );
            },
            child: _buildChapterItem(buildContext, chapter.value, chapter.key),
          )
      ],
    );
  }

  void _readComic(BuildContext buildContext) {
    ComicProvider comicProvider = buildContext.read<ComicProvider>();
    String uniqueId =
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName);

    ComicModel? comicModel = comicProvider.getComicModel(uniqueId);
    if (comicModel == null) {
      return;
    }

    late ReadHistoryModel readHistory;
    if (comicProvider.readHistory.containsKey(uniqueId)) {
      readHistory = comicProvider.readHistory[uniqueId]!;
    } else {
      readHistory = ReadHistoryModel(comicModel.chapters.last.id, 0);
    }

    Navigator.push(
      buildContext,
      CupertinoPageRoute(
        builder: (context) => ReaderPage(
          readerContext: ExtensionComicReaderContext(
            widget.extensionName,
            comicModel.id,
            readHistory.chapterId,
            readHistory.index,
            comicModel.extra,
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    var provider = context.read<ComicProvider>();
    Object ret = await getDetail(
        widget.extensionName, widget.comicItem.comicId, widget.comicItem.extra);

    if (ret is String && mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('error'),
          content: Text(ret),
          actions: [
            CupertinoDialogAction(
              child: const Text('confirm'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    var detail = ComicDetail.fromJson(ret as Map<String, dynamic>);
    ComicModel? comicModel = provider.getComicModel(
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName));

    if (comicModel != null) {
      comicModel.updateFromComicDetail(detail);
      provider.addComic(comicModel, true);
    } else {
      provider.addComic(
          ComicModel.fromComicDetail(detail, widget.extensionName), true);
    }
  }

  void _downloadAllChapters() {
    var entry = showLoadingDialog(context);

    var comicProvider = context.read<ComicProvider>();
    var taskProvider = context.read<TaskProvider>();
    ComicModel? comicModel = comicProvider.getComicModel(
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName));
    if (comicModel == null) {
      return;
    }

    for (var chapter in comicModel.chapters) {
      addDownloadTask(comicProvider, taskProvider, widget.comicItem.comicId,
          widget.extensionName, chapter.id, null);
    }

    entry.remove();
  }

  @override
  Widget build(BuildContext context) {
    if (globalManager.isLandscape) {
      return const Center(child: CupertinoActivityIndicator());
    }

    _initWithContext();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.comicItem.title),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: EasyRefresh(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(60.w),
                    color: backgroundColor06,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 800.h,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 600.w,
                                height: 800.h,
                                child: Stack(
                                  // image and favorite button
                                  children: [
                                    Positioned.fill(
                                      child: NetImage(
                                        NetImageContextCover(
                                          widget.extensionName,
                                          widget.comicItem.comicId,
                                          widget.comicItem.imageUrl,
                                        ),
                                        width: 600.w,
                                        height: 800.h,
                                      ),
                                    ),
                                    Positioned(
                                      right: 10.w,
                                      top: 10.h,
                                      child: GestureDetector(
                                        onTap: _toggleFavorite,
                                        child: Consumer<ComicProvider>(
                                          builder:
                                              (context, comicProvider, child) =>
                                                  Image.asset(
                                            comicProvider.isFavoriteComic(
                                                    getComicUniqueId(
                                                        widget
                                                            .comicItem.comicId,
                                                        widget.extensionName))
                                                ? addToShelfOn
                                                : addToShelf,
                                            width: 150.w,
                                            height: 150.h,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: Container()),
                              material.SizedBox(
                                width: 400.w,
                                child: Column(
                                  children: [
                                    Text(widget.comicItem.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        '${AppLocalizations.of(context)?.extensions}: ${widget.extensionName}'),
                                    Expanded(child: Container()),
                                    SizedBox(
                                      width: 400.w,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                              width: 60.w,
                                              height: 60.h,
                                              history),
                                          SizedBox(width: 20.w),
                                          SizedBox(
                                            width: 200.w,
                                            child: Consumer<ComicProvider>(
                                              builder: (context, comicProvider,
                                                      child) =>
                                                  Text(
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      comicProvider.getReadHistory(
                                                              getComicUniqueId(
                                                                  widget
                                                                      .comicItem
                                                                      .comicId,
                                                                  widget
                                                                      .extensionName)) ??
                                                          ''),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    SizedBox(
                                      width: 400.w,
                                      child: material.ElevatedButton(
                                        style:
                                            material.ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.r),
                                                ),
                                                backgroundBuilder: (context,
                                                        states, child) =>
                                                    Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                                colors: [
                                                              commonBlue,
                                                              Color.fromARGB(
                                                                  255,
                                                                  153,
                                                                  149,
                                                                  249),
                                                            ]),
                                                      ),
                                                      child: child,
                                                    )),
                                        onPressed: () {
                                          _readComic(context);
                                        },
                                        child: Text('read',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: pm(20, 40.spMin),
                                                color: CupertinoColors.white)),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Consumer<ComicProvider>(
                          builder: (context, comicProvider, child) {
                            ComicModel? comicModel =
                                comicProvider.getComicModel(getComicUniqueId(
                                    widget.comicItem.comicId,
                                    widget.extensionName));
                            return comicModel == null
                                ? const Center(
                                    child: CupertinoActivityIndicator())
                                : _buildChapterList(context, comicModel);
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 120.h,
              color: CupertinoColors.white,
              child: GestureDetector(
                onTap: _downloadAllChapters,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      download2,
                      width: 80.w,
                      height: 80.h,
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20.w),
                        child: const Text('Download all'))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
