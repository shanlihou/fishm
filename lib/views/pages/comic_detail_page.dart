import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/provider/comic_provider.dart';
import '../../api/flutter_call_lua/method.dart';
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
  bool? isFavorite;
  BuildContext? _buildContext;
  ComicDetail? _detail;

  @override
  void initState() {
    super.initState();
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
      ComicDetail detail = ComicDetail.fromComicModel(comicModel);
      setState(() {
        _detail = detail;
      });

      await Future.delayed(const Duration(milliseconds: 100));
      await provider
          .addComic(ComicModel.fromComicDetail(detail, widget.extensionName));
      return;
    }

    Object ret = await getDetail(
        widget.extensionName, widget.comicItem.comicId, widget.comicItem.extra);

    if (ret is String) {
      showCupertinoDialog(
        context: _buildContext!,
        builder: (context) => CupertinoAlertDialog(
          title: Text('error'),
          content: Text(ret),
          actions: [
            CupertinoDialogAction(
              child: Text('confirm'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    var detail = ComicDetail.fromJson(ret as Map<String, dynamic>);
    setState(() {
      _detail = detail;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    await provider
        .addComic(ComicModel.fromComicDetail(detail, widget.extensionName));
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite!;
    });

    if (_buildContext == null) {
      return;
    }

    String uniqueId =
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName);
    if (isFavorite != null && isFavorite!) {
      _buildContext!.read<ComicProvider>().addFavoriteComic(uniqueId);
    } else {
      _buildContext!.read<ComicProvider>().removeFavoriteComic(uniqueId);
    }
  }

  Widget _buildChapterList(BuildContext buildContext, ComicDetail detail) {
    return Column(
      children: [
        for (var chapter in detail.chapters)
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
                          detail.id,
                          chapter.title,
                          detail.extra),
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
    if (_detail == null) {
      return;
    }

    ComicProvider comicProvider = buildContext.read<ComicProvider>();
    String uniqueId =
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName);
    late ReadHistoryModel readHistory;
    String chapterTitle = '';
    if (comicProvider.readHistory.containsKey(uniqueId)) {
      readHistory = comicProvider.readHistory[uniqueId]!;
      chapterTitle = _detail!.getChapterTitle(readHistory.chapterId);
    } else {
      readHistory = ReadHistoryModel(_detail!.chapters.last.id, 0);
      chapterTitle = _detail!.chapters.first.title;
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
    Object ret = await getDetail(
        widget.extensionName, widget.comicItem.comicId, widget.comicItem.extra);

    if (ret is String) {
      showCupertinoDialog(
        context: _buildContext!,
        builder: (context) => CupertinoAlertDialog(
          title: Text('error'),
          content: Text(ret),
          actions: [
            CupertinoDialogAction(
              child: Text('confirm'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    var detail = ComicDetail.fromJson(ret as Map<String, dynamic>);
    setState(() {
      _detail = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    _initWithContext();
    _buildContext = context;
    if (isFavorite == null) {
      isFavorite = context.read<ComicProvider>().favoriteComics.containsKey(
            getComicUniqueId(widget.comicItem.comicId, widget.extensionName),
          );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.comicItem.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: toggleFavorite,
          child: Icon(
            isFavorite! ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: CupertinoColors.systemRed,
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
                        child: Text('read ${_getReadHistory(context)}'),
                      )
                    ],
                  ),
                ),
                _detail == null
                    ? const Center(child: CupertinoActivityIndicator())
                    : _buildChapterList(context, _detail!)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
