import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
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
import '../../utils/utils_general.dart';
import '../../views/class/comic_item.dart';
import '../widget/comic_chapter_status_widget.dart';
import '../widget/download_options_widget.dart';
import '../widget/net_image.dart';
import './reader.dart';
import '../../types/context/net_iamge_context.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

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
  final Map<String, (int, int)> _chapterDownCnts = {};

  final Map<String, ComicChapterStatusController> _chapterStatusControllers =
      {};

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
    for (var controller in _chapterStatusControllers.values) {
      controller.dispose();
    }
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

        await p.saveComic(comicModel);
      }

      String folder = imageChapterFolder(
          widget.extensionName, widget.comicItem.comicId, chapter.id);

      int cnt = 0;
      try {
        Directory dir = Directory(folder);
        if (await dir.exists()) {
          cnt = await dir.list().where((entity) {
            String path = entity.path.toLowerCase();
            return path.endsWith('.png') || path.endsWith('.jpg');
          }).length;
        }

        if (mounted) {
          _chapterStatusControllers[chapter.id]?.setStatus(
              cnt == chapter.images.length
                  ? ComicChapterStatus.normal
                  : ComicChapterStatus.downloading);
        }

        _chapterDownCnts[chapter.id] = (cnt, chapter.images.length);
      } catch (e) {
        Log.instance.d('$folder is empty :$e');
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
    _isFavorite.value = !_isFavorite.value;

    String uniqueId =
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName);
    if (_isFavorite.value) {
      context.read<ComicProvider>().addFavoriteComic(uniqueId);
    } else {
      context.read<ComicProvider>().removeFavoriteComic(uniqueId);
    }
  }

  Widget _buildChapterItem(
      BuildContext buildContext, ChapterModel chapter, int idx) {
    ComicChapterStatusController controller;
    if (!_chapterStatusControllers.containsKey(chapter.id)) {
      controller = ComicChapterStatusController();
      _chapterStatusControllers[chapter.id] = controller;
    } else {
      controller = _chapterStatusControllers[chapter.id]!;
    }

    return Row(
      children: [
        Expanded(child: Text(chapter.title)),
        Align(
          alignment: Alignment.centerRight,
          child: ComicChapterStatusWidget(
            extensionName: widget.extensionName,
            comicId: widget.comicItem.comicId,
            chapterId: chapter.id,
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildChapterList(BuildContext buildContext, ComicModel comicModel) {
    return Column(
      children: [
        for (var chapter in comicModel.chapters.asMap().entries)
          SizedBox(
              height: 0.1.sh,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    buildContext,
                    CupertinoPageRoute(
                      builder: (context) => ComicReaderPage(
                          widget.extensionName,
                          chapter.value.id,
                          comicModel.id,
                          chapter.value.title,
                          comicModel.extra),
                    ),
                  );
                },
                child:
                    _buildChapterItem(buildContext, chapter.value, chapter.key),
              ))
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
    String chapterTitle = '';
    if (comicProvider.readHistory.containsKey(uniqueId)) {
      readHistory = comicProvider.readHistory[uniqueId]!;
      chapterTitle = comicModel.getChapterTitle(readHistory.chapterId)!;
    } else {
      readHistory = ReadHistoryModel(comicModel.chapters.last.id, 0);
      chapterTitle = comicModel.chapters.first.title;
    }

    Navigator.push(
      buildContext,
      CupertinoPageRoute(
        builder: (context) => ComicReaderPage(
          widget.extensionName,
          readHistory.chapterId,
          widget.comicItem.comicId,
          chapterTitle,
          widget.comicItem.extra,
          initChapterId: readHistory.chapterId,
          initPage: readHistory.index,
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

  void _showDownloadOptions(BuildContext context, ComicModel comicModel) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Download Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: DownloadOptionsWidget(
                  comicModel: comicModel, chapterDownCnts: _chapterDownCnts),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initWithContext();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.comicItem.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _toggleFavorite,
          child: ValueListenableBuilder(
            valueListenable: _isFavorite,
            builder: (context, isFavorite, child) => Icon(
              isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: CupertinoColors.systemRed,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: EasyRefresh(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(50.w),
              color: backgroundColor06,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NetImage(
                        NetImageContextCover(
                          widget.extensionName,
                          widget.comicItem.comicId,
                          widget.comicItem.imageUrl,
                        ),
                        width: 600.w,
                        height: 800.h,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.comicItem.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(
                              '${AppLocalizations.of(context)?.extensions}: ${widget.extensionName}'),
                          Image.asset(width: 100.w, height: 100.h, addToShelf),
                          Row(
                            children: [
                              Image.asset(width: 100.w, height: 100.h, onShelf),
                              SizedBox(
                                width: 200.w,
                                child: Consumer<ComicProvider>(
                                  builder: (context, comicProvider, child) =>
                                      Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          comicProvider.getReadHistory(
                                                  getComicUniqueId(
                                                      widget.comicItem.comicId,
                                                      widget.extensionName)) ??
                                              ''),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.comicItem.title),
                        const SizedBox(height: 8),
                        Text('作者: ${widget.comicItem.extra['author'] ?? '未知'}'),
                        const SizedBox(height: 16),
                        const Text('简介:'),
                        const SizedBox(height: 8),
                        Text(widget.comicItem.extra['description'] ?? '暂无简介'),
                        CupertinoButton(
                          onPressed: () {
                            _readComic(context);
                          },
                          child: Consumer<ComicProvider>(
                            builder: (context, comicProvider, child) => Text(
                                'read ${comicProvider.getReadHistory(getComicUniqueId(widget.comicItem.comicId, widget.extensionName)) ?? ''}'),
                          ),
                        ),
                        CupertinoButton(
                          child: const Text('download'),
                          onPressed: () {
                            var comicProvider = context.read<ComicProvider>();
                            ComicModel? comicModel =
                                comicProvider.getComicModel(getComicUniqueId(
                                    widget.comicItem.comicId,
                                    widget.extensionName));

                            if (comicModel == null) {
                              return;
                            }

                            if (comicModel.chapters.isEmpty) {
                              return;
                            }

                            _showDownloadOptions(context, comicModel);
                          },
                        )
                      ],
                    ),
                  ),
                  Consumer<ComicProvider>(
                    builder: (context, comicProvider, child) {
                      ComicModel? comicModel = comicProvider.getComicModel(
                          getComicUniqueId(
                              widget.comicItem.comicId, widget.extensionName));
                      return comicModel == null
                          ? const Center(child: CupertinoActivityIndicator())
                          : _buildChapterList(context, comicModel);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
