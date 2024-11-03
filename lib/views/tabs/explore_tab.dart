import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../api/flutter_call_lua/method.dart';
import '../../models/api/gallery_result.dart';
import '../../models/db/extensions.dart' as model_extensions;
import '../../types/provider/extension_provider.dart';
import '../class/comic_item.dart';
import '../widget/comic_item_widget.dart';

class ComicContext {
  int page = 0;
  ComicContext();

  void reset() {
    page = 0;
  }
}

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab>
    with SingleTickerProviderStateMixin {
  final int maxColumn = 3;
  int selectedExtensionIndex = 0;
  final ComicContext comicContext = ComicContext();
  final EasyRefreshController easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  ValueNotifier<List<ComicItem>> comics = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
  }

  int get rowCount => (comics.value.length / maxColumn).ceil();

  Future<void> _onLoad() async {
    var provider = context.read<ExtensionProvider>();
    if (provider.extensions.isEmpty) {
      easyRefreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    String extensionName = provider.extensions[selectedExtensionIndex].name;
    var ret = await gallery(extensionName, comicContext.page);
    GalleryResult galleryResult =
        GalleryResult.fromJson(ret as Map<String, dynamic>);
    if (!galleryResult.success) {
      easyRefreshController.finishLoad(IndicatorResult.fail);
      return;
    }

    comicContext.page++;
    comics.value = comics.value + galleryResult.data;
    easyRefreshController.finishLoad(IndicatorResult.success);
  }

  Widget buildExtensionTab(BuildContext buildContext) {
    List<model_extensions.Extension> extensions =
        buildContext.watch<ExtensionProvider>().extensions;
    return Expanded(
      flex: 1,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: extensions.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              if (index == selectedExtensionIndex) {
                return;
              }

              setState(() {
                selectedExtensionIndex = index;
                comics.value = [];
                comicContext.reset();
              });
            },
            child: Container(
              child: Text(extensions[index].name,
                  style: TextStyle(
                      color: index == selectedExtensionIndex
                          ? const Color(0xFF2196F3) // 蓝色
                          : const Color(0xFF000000))), // 黑色
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    String? extensionName;
    var provider = context.read<ExtensionProvider>();
    if (provider.extensions.isNotEmpty) {
      extensionName = provider.extensions[selectedExtensionIndex].name;
    }

    return ValueListenableBuilder(
      valueListenable: comics,
      builder: (BuildContext context, List<ComicItem> value, Widget? child) {
        return EasyRefresh(
          controller: easyRefreshController,
          onLoad: _onLoad,
          child: ListView.builder(
            itemCount: rowCount,
            itemBuilder: (BuildContext context, int index) {
              List<Widget> children = [];
              for (int i = 0; i < maxColumn; i++) {
                var trulyIndex = index * maxColumn + i;
                if (trulyIndex >= value.length) {
                  break;
                }

                var item = value[trulyIndex];
                children.add(ComicItemWidget(
                  item,
                  extensionName!,
                  width: 405.w,
                  height: 541.h,
                ));
              }

              return Container(
                  padding: const EdgeInsets.all(5),
                  child: Row(children: children));
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildExtensionTab(context),
        Expanded(
          flex: 9,
          child: _buildListView(),
        ),
      ],
    );
  }
}
