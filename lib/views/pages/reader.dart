// this page use for read comic image

import 'package:flutter/material.dart';
import "../../api/flutter_call_lua/method.dart";
import "../../models/chapter_detail.dart";


class ComicReaderPage extends StatefulWidget {
  final int chapterId;
  final int comicId;
  final String chapterTitle;

  const ComicReaderPage(this.chapterId, this.comicId, this.chapterTitle, {super.key});

  @override
  _ComicReaderPageState createState() => _ComicReaderPageState();
}

class _ComicReaderPageState extends State<ComicReaderPage> {
  int currentIndex = 0;
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    var detail = await getChapterDetail(widget.chapterId, widget.comicId);
    ChapterDetail chapterDetail = ChapterDetail.fromJson(detail as Map<String, dynamic>);
    updateImages(chapterDetail.images);
    print(detail);
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
      body: GestureDetector(
        onTap: () {
          nextPage();
        },
        child: toImage(),
      ),
    );
  }
}
