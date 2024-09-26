// this page use for read comic image

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "../../api/flutter_call_lua/method.dart";
import '../../const/general_const.dart';
import "../../models/api/chapter_detail.dart";
import 'package:preload_page_view/preload_page_view.dart';

import '../../types/context/net_iamge_context.dart';
import '../widget/net_image.dart';

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
  final PreloadPageController preloadController = PreloadPageController();
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: images.length,
          physics: null,
          preloadPagesCount: 4,
          controller: preloadController,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return NetImage(
              NetImageType.reader,
              NetImageContextReader(widget.extensionName, widget.comicId,
                  widget.chapterId, images[index], index, widget.extra),
              1.sw,
              1.sh,
            );
          },
        ),
      ),
    );
  }
}
