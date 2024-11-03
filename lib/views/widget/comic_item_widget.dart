import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../types/context/net_iamge_context.dart';
import '../class/comic_item.dart';
import '../pages/comic_detail_page.dart';
import 'net_image.dart';

class ComicItemWidget extends StatelessWidget {
  final ComicItem comicItem;
  final String extensionName;
  final double width;
  final double height;
  const ComicItemWidget(this.comicItem, this.extensionName,
      {super.key, required this.width, required this.height});

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
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: NetImage(
                NetImageContextCover(
                  extensionName,
                  comicItem.comicId,
                  comicItem.imageUrl,
                ),
                width: width,
                height: height,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      // #000000 19%
                      const Color.fromARGB(255, 0, 0, 0).withOpacity(0.19),
                      // #000000 87%
                      const Color.fromARGB(255, 0, 0, 0).withOpacity(0.87),
                    ],
                  ),
                ),
                width: width,
                height: 72.h,
                child: Center(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 40.spMin,
                      color: CupertinoColors.white,
                    ),
                    maxLines: 1,
                    comicItem.title,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
