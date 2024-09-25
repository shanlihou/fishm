import 'package:flutter/material.dart';
import '../../api/flutter_call_lua/method.dart';
import '../../models/api/comic_detail.dart';
import '../../views/class/comic_item.dart';
import './reader.dart';

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
  ComicDetail? detail;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    Object ret = await getDetail(widget.extensionName, widget.comicItem.extra);
    updateDetail(ComicDetail.fromJson(ret as Map<String, dynamic>));
  }

  void updateDetail(ComicDetail detail) {
    setState(() {
      this.detail = detail;
    });
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    children.add(Image.network(widget.comicItem.imageUrl,
        height: 200, width: double.infinity, fit: BoxFit.cover));
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

    if (detail != null) {
      for (int index = 0; index < detail!.chapters.length; index++) {
        children.add(SizedBox(
          height: 50,
          child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComicReaderPage(
                        widget.extensionName,
                        detail!.chapters[index].id,
                        detail!.id,
                        detail!.chapters[index].title,
                        detail!.extra),
                  ),
                );
              },
              child: Text(detail!.chapters[index].title)),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comicItem.title),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
