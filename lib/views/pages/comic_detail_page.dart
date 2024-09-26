import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/provider/comic_provider.dart';
import '../../api/flutter_call_lua/method.dart';
import '../../const/general_const.dart';
import '../../models/api/comic_detail.dart';
import '../../models/db/comic_model.dart';
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
  ComicDetail? _detail;
  bool _isInitWithContext = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initWithContext(BuildContext buildContext) async {
    if (_isInitWithContext) {
      return;
    }

    _isInitWithContext = true;

    Object ret = await getDetail(
        widget.extensionName, widget.comicItem.comicId, widget.comicItem.extra);

    if (ret is String) {
      // 显示提示
      showCupertinoDialog(
        context: buildContext,
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
      return;
    }

    updateDetail(ComicDetail.fromJson(ret as Map<String, dynamic>));
    buildContext.read<ComicProvider>().addComic(comicModel);
  }

  void updateDetail(ComicDetail detail) {
    if (mounted) {
      setState(() {
        _detail = detail;
      });
    }
  }

  ComicModel get comicModel =>
      ComicModel.fromComicDetail(_detail!, widget.extensionName);

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    _initWithContext(context);

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

    if (_detail != null) {
      for (int index = 0; index < _detail!.chapters.length; index++) {
        children.add(SizedBox(
          height: 50,
          child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ComicReaderPage(
                        widget.extensionName,
                        _detail!.chapters[index].id,
                        _detail!.id,
                        _detail!.chapters[index].title,
                        _detail!.extra),
                  ),
                );
              },
              child: Text(_detail!.chapters[index].title)),
        ));
      }
    }
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
