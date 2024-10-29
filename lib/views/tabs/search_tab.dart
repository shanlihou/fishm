import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../common/log.dart';
import '../../types/provider/extension_provider.dart';
import '../widget/search_result_widget.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  TextEditingController _searchController = TextEditingController();
  List<(String, String)> extensionNames = [];
  List<SearchResultController> searchResultControllers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in searchResultControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _search() async {
    for (var controller in searchResultControllers) {
      controller.setKeyword(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    var p = context.watch<ExtensionProvider>();
    while (searchResultControllers.length < p.extensions.length) {
      searchResultControllers.add(SearchResultController());
    }

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var i = 0; i < p.extensions.length; i++)
                  SearchResultWidget(
                    extensionName: p.extensions[i].name,
                    controller: searchResultControllers[i],
                  ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
