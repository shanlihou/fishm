import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/db/comic_model.dart';
import '../../types/provider/comic_provider.dart';
import '../class/comic_item.dart';
import '../widget/comic_item_widget.dart';

class FavoriteTab extends StatelessWidget {
  const FavoriteTab({super.key});

  @override
  Widget build(BuildContext context) {
    List<ComicModel> comics =
        context.watch<ComicProvider>().favoriteComics.values.toList();

    return ListView.builder(
      itemCount: comics.length,
      itemBuilder: (context, index) {
        return ComicItemWidget(
          ComicItem.fromComicModel(comics[index]),
          comics[index].extensionName,
          height: 0.2.sw,
          width: 0.2.sw,
        );
      },
    );
  }
}
