import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/provider/comic_provider.dart';
import '../../api/flutter_call_lua/method.dart';
import '../../const/general_const.dart';
import '../../models/api/comic_detail.dart';
import '../../models/db/comic_model.dart';
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
  bool isFavorite = false;
  BuildContext? _buildContext;

  @override
  void initState() {
    super.initState();
  }

  Future<ComicDetail?> _getComicDetail(BuildContext buildContext) async {
    var provider = buildContext.read<ComicProvider>();
    ComicModel? comicModel = provider.getComicModel(
        getComicUniqueId(widget.comicItem.comicId, widget.extensionName));

    if (comicModel != null) {
      ComicDetail detail = ComicDetail.fromComicModel(comicModel);
      _updateComicModel(provider, detail);
      return detail;
    }

    Object ret = await getDetail(
        widget.extensionName, widget.comicItem.comicId, widget.comicItem.extra);

    if (ret is String) {
      // 显示提示
      showCupertinoDialog(
        context: _buildContext!,
        builder: (context) => CupertinoAlertDialog(
          title: Text('提示'),
          content: Text(ret),
          actions: [
            CupertinoDialogAction(
              child: Text('确定'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return null;
    }

    var detail = ComicDetail.fromJson(ret as Map<String, dynamic>);
    _updateComicModel(provider, detail);
    return detail;
  }

  Future<void> _updateComicModel(
      ComicProvider provider, ComicDetail detail) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await provider
        .addComic(ComicModel.fromComicDetail(detail, widget.extensionName));
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
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

  @override
  Widget build(BuildContext context) {
    _buildContext = context;

    List<Widget> children = [];
    print('image url is ${widget.comicItem.imageUrl}');
    children.add(NetImage(
      NetImageType.cover,
      NetImageContextCover(
        widget.extensionName,
        widget.comicItem.comicId,
        widget.comicItem.imageUrl,
      ),
      1.sw,
      1.sw,
    ));
    children.add(Padding(
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
        ],
      ),
    ));

    children.add(FutureBuilder(
      future: _getComicDetail(context),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return _buildChapterList(context, snapshot.data!);
        }
        return const Center(child: CupertinoActivityIndicator());
      },
    ));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.comicItem.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: toggleFavorite,
          child: Icon(
            isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: CupertinoColors.systemRed,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
