import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/db/comic_model.dart';
import '../../types/provider/comic_provider.dart';
import '../class/comic_item.dart';
import '../widget/comic_item_widget.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class FavoriteTab extends StatelessWidget {
  const FavoriteTab({super.key});

  Widget _buildBaseLine(BuildContext context) {
    return SizedBox(
      height: 106.h,
      child: Row(
        children: [
          SizedBox(width: 140.w),
          Container(
            // #BBBBBB 100%
            color: const Color(0xFFBBBBBB),
            width: 239.w,
            height: 1.h,
          ),
          SizedBox(
            width: 177.w,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                      alignment: Alignment.bottomCenter,
                      child: Text(AppLocalizations.of(context)!.baseline)),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Text(AppLocalizations.of(context)!.findMore),
                  ),
                ),
              ],
            ),
          ),
          Container(
            // #BBBBBB 100%
            color: const Color(0xFFBBBBBB),
            width: 239.w,
            height: 1.h,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ComicModel> comics =
        context.watch<ComicProvider>().favoriteComics.values.toList();

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          boxShadow: [
            // box-shadow: 0px 5px 20px 5px rgba(155,157,194,0.55);
            BoxShadow(
              color: const Color(0xFF9B9DC2).withOpacity(0.55),
              blurRadius: 20.w,
            ),
          ],
        ),
        child: Column(
          children: [
            for (int i = 0; i < comics.length; i += 2)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(34, 22, 0, 0).w,
                    child: ComicItemWidget(
                      ComicItem.fromComicModel(comics[i]),
                      comics[i].extensionName,
                      width: 405.w,
                      height: 541.h,
                    ),
                  ),
                  if (i + 1 < comics.length)
                    Container(
                      padding: const EdgeInsets.fromLTRB(9, 22, 34, 0).w,
                      child: ComicItemWidget(
                        ComicItem.fromComicModel(comics[i + 1]),
                        comics[i + 1].extensionName,
                        width: 405.w,
                        height: 541.h,
                      ),
                    )
                ],
              ),
            _buildBaseLine(context),
          ],
        ),
      ),
    );

    // return ListView.builder(
    //   itemCount: (comics.length / 2).ceil(),
    //   itemBuilder: (context, index) {
    //     return Row(
    //       children: [
    //         Container(
    //           color: CupertinoColors.white,
    //           padding: const EdgeInsets.fromLTRB(34, 22, 0, 0).w,
    //           child: ComicItemWidget(
    //             ComicItem.fromComicModel(comics[index * 2]),
    //             comics[index * 2].extensionName,
    //             width: 405.w,
    //             height: 541.h,
    //           ),
    //         ),
    //         if (index * 2 + 1 < comics.length)
    //           Container(
    //             color: CupertinoColors.white,
    //             padding: const EdgeInsets.fromLTRB(9, 22, 34, 0).w,
    //             child: ComicItemWidget(
    //               ComicItem.fromComicModel(comics[index * 2 + 1]),
    //               comics[index * 2 + 1].extensionName,
    //               width: 405.w,
    //               height: 541.h,
    //             ),
    //           )
    //       ],
    //     );
    //   },
    // );
  }
}
