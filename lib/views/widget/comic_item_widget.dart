import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../types/context/net_iamge_context.dart';
import '../class/comic_item.dart';
import '../pages/comic_detail_page.dart';
import 'net_image.dart';

class ComicItemWidget extends StatelessWidget {
  final ComicItem comicItem;
  final String extensionName;
  final double? width;
  final double? height;
  const ComicItemWidget(this.comicItem, this.extensionName,
      {super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ComicDetailPage(
              comicItem,
              extensionName,
            ),
          ),
        );
      },
      child: Column(
        children: [
          NetImage(
            NetImageContextCover(
              extensionName,
              comicItem.comicId,
              comicItem.imageUrl,
            ),
            width ?? 0.33.sw,
            height ?? 0.33.sw,
          ),
          Text(comicItem.title),
        ],
      ),
    );
  }
}
