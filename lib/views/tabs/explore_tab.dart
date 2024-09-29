import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../api/flutter_call_lua/method.dart';
import '../../models/api/gallery_result.dart';
import '../../models/db/extensions.dart' as model_extensions;
import '../../types/provider/extension_provider.dart';
import '../class/gallery_row.dart';
import '../class/comic_item.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab>
    with SingleTickerProviderStateMixin {
  final int maxColumn = 3;
  List<GalleryRow> galleryRows = [];
  int selectedExtensionIndex = 0;
  String selectedExtensionName = '';
  bool isInitWithContext = false;
  bool loadFailed = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initWithContext(BuildContext buildContext) async {
    if (isInitWithContext) {
      return;
    }

    isInitWithContext = true;

    List<model_extensions.Extension> extensions =
        buildContext.read<ExtensionProvider>().extensions;

    if (selectedExtensionIndex >= extensions.length) {
      return;
    }
    selectedExtensionName = extensions[selectedExtensionIndex].name;

    getGallery(extensions[selectedExtensionIndex]);
  }

  void getGallery(model_extensions.Extension extension) async {
    var ret = await gallery(extension.name);
    GalleryResult galleryResult =
        GalleryResult.fromJson(ret as Map<String, dynamic>);
    // Log.instance.d('get gallery: $ret');

    if (!galleryResult.success) {
      setState(() {
        loadFailed = true;
      });
      return;
    }

    updateGallery(galleryResult.data);
  }

  void updateGallery(List<ComicItem> data) {
    setState(() {
      galleryRows.clear();
      while (data.isNotEmpty) {
        List<ComicItem> items = [];
        for (int i = 0; i < maxColumn; i++) {
          if (data.isEmpty) {
            break;
          }

          var val = data.removeAt(0);
          items.add(val);
        }

        galleryRows.add(GalleryRow(items, maxColumn));
      }
    });
  }

  Widget buildExtensionTab(BuildContext buildContext) {
    List<model_extensions.Extension> extensions =
        buildContext.read<ExtensionProvider>().extensions;
    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: extensions.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedExtensionIndex = index;
                selectedExtensionName = extensions[index].name;
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

  Widget _buildLoadFailed(BuildContext buildContext) {
    return Center(
      child: Column(
        children: [
          Text('加载失败'),
          CupertinoButton(
            onPressed: () {
              setState(() {
                loadFailed = false;
              });
              getGallery(buildContext
                  .read<ExtensionProvider>()
                  .extensions[selectedExtensionIndex]);
            },
            child: Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: galleryRows.length,
      itemBuilder: (BuildContext context, int index) {
        return galleryRows[index].toWidget(context, selectedExtensionName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    initWithContext(context);

    return Column(
      children: [
        buildExtensionTab(context),
        Expanded(
          flex: 9,
          child: loadFailed ? _buildLoadFailed(context) : _buildListView(),
        ),
      ],
    );
  }
}
