import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/provider/comic_provider.dart';
import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';
import '../../models/api/comic_detail.dart';
import '../../models/db/comic_model.dart';
import '../../models/db/read_history_model.dart';
import '../../utils/utils_general.dart';
import '../../views/class/comic_item.dart';
import '../widget/net_image.dart';
import './reader.dart';
import '../../types/context/net_iamge_context.dart';

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

  @override
  void initState() {
    super.initState();
    _isFavorite.value =
        context.read<ComicProvider>().favoriteComics.containsKey(
              getComicUniqueId(widget.comicItem.comicId, widget.extensionName),
            );
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
      await provider.addComic(comicModel);
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
    await provider
        .addComic(ComicModel.fromComicDetail(detail, widget.extensionName));
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

  Widget _buildChapterItem(BuildContext buildContext, ChapterModel chapter) {
    return Text(chapter.title);
  }

  Widget _buildChapterList(BuildContext buildContext, ComicModel comicModel) {
    return Column(
      children: [
        for (var chapter in comicModel.chapters)
          SizedBox(
            height: 0.1.sh,
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    buildContext,
                    CupertinoPageRoute(
                      builder: (context) => ComicReaderPage(
                          widget.extensionName,
                          chapter.id,
                          comicModel.id,
                          chapter.title,
                          comicModel.extra),
                    ),
                  );
                },
                child: Text(chapter.title)),
          )
      ],
    );
  }

  String _getReadHistory(BuildContext buildContext) {
    ComicProvider comicProvider = buildContext.watch<ComicProvider>();
    String? readHistory = comicProvider.getReadHistory(
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName));
    if (readHistory == null) {
      return '';
    }
    return readHistory;
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
      provider.addComic(comicModel);
    } else {
      provider
          .addComic(ComicModel.fromComicDetail(detail, widget.extensionName));
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetImage(
                  NetImageContextCover(
                    widget.extensionName,
                    widget.comicItem.comicId,
                    widget.comicItem.imageUrl,
                  ),
                  1.sw,
                  1.sw,
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
    );
  }
}
