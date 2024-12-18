import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fishm/const/general_const.dart';

import '../../models/db/comic_model.dart';
import '../../types/provider/comic_provider.dart';
import '../../types/provider/tab_provider.dart';
import '../../utils/utils_widget.dart';
import '../class/comic_item.dart';
import '../widget/comic_item_widget.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class FavoriteTab extends StatelessWidget {
  const FavoriteTab({super.key});

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
            comicTabBaseline(context, AppLocalizations.of(context)!.findMore,
                onTap: () {
              context.read<TabProvider>().setCurrentIndex(tabSearch);
            }),
          ],
        ),
      ),
    );
  }
}
