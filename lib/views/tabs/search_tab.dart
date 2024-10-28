import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../types/provider/extension_provider.dart';
import '../widget/search_result_widget.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  ExtensionProvider? extensionProvider;
  TextEditingController _searchController = TextEditingController();
  List<(String, String)> extensionNames = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    extensionNames.clear();
    for (var extension in extensionProvider!.extensions) {
      extensionNames.add((extension.name, _searchController.text));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    extensionProvider ??= context.read<ExtensionProvider>();

    return Center(
      child: Column(children: [
        Row(
          children: [
            SizedBox(
              width: 0.8.sw,
              child: CupertinoTextField(
                controller: _searchController,
                placeholder: 'name of comic',
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            CupertinoButton(
              onPressed: _search,
              padding: EdgeInsets.zero,
              minSize: 0.1.sw,
              child: const Icon(CupertinoIcons.search),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: extensionNames.length,
            itemBuilder: (BuildContext context, int index) {
              return SearchResultWidget(
                  extensionName: extensionNames[index].$1,
                  keyword: extensionNames[index].$2);
            },
          ),
        ),
      ]),
    );
  }
}
