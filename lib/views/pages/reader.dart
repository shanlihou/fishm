// this page use for read comic image

import 'package:flutter/material.dart';
import "../../api/flutter_call_lua/method.dart";
import "../../models/api/chapter_detail.dart";
import 'package:preload_page_view/preload_page_view.dart';

class ComicReaderPage extends StatefulWidget {
  final String chapterId;
  final String comicId;
  final String chapterTitle;
  final String extensionName;
  final Map<String, dynamic> extra;

  const ComicReaderPage(this.extensionName, this.chapterId, this.comicId,
      this.chapterTitle, this.extra,
      {super.key});

  @override
  _ComicReaderPageState createState() => _ComicReaderPageState();
}

class _ComicReaderPageState extends State<ComicReaderPage> {
  int currentIndex = 0;
  final PreloadPageController controller = PreloadPageController();
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    var detail = await getChapterDetail(
        widget.extensionName, widget.chapterId, widget.comicId, widget.extra);
    ChapterDetail chapterDetail =
        ChapterDetail.fromJson(detail as Map<String, dynamic>);
    updateImages(chapterDetail.images);
  }

  void updateImages(List<String> newImages) {
    setState(() {
      images = newImages;
    });
  }

  void nextPage() {
    if (currentIndex < images.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void prevPage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  Widget toImage() {
    if (currentIndex < 0 || currentIndex >= images.length) {
      return const SizedBox();
    }

    return Image.network(
      images[currentIndex],
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: images.length,
          physics: null,
          preloadPagesCount: 4,
          controller: controller,
          onPageChanged: (index) {
            currentIndex = index;
          },
          itemBuilder: (context, index) {
            return Image.network(images[index], fit: BoxFit.cover);
          },
        ),
      ),
    );
  }
}
