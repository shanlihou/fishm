import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fishm/utils/utils_general.dart';

import '../../common/log.dart';
import '../../const/assets_const.dart';
import '../../const/general_const.dart';
import '../../types/context/local_comic_reader_context.dart';
import '../pages/reader_page.dart';

class LocalComicTab extends StatefulWidget {
  const LocalComicTab({super.key});

  @override
  State<LocalComicTab> createState() => _LocalComicTabState();
}

class _LocalComicTabState extends State<LocalComicTab> {
  final List<String> _comics = [];
  final List<String> _displayComics = [];

  @override
  void initState() {
    super.initState();

    _loadLocalComics();
  }

  Future<void> _loadLocalComics() async {
    var files = await Directory(cbzDir).list().toList();
    Log.instance.d('local comics: ${files.length}');
    _comics.clear();
    _displayComics.clear();
    for (var file in files) {
      Log.instance.d('local comic: $file');
      _comics.add(file.path);

      // basename
      var basename = osPathSplit(file.path).last;
      if (basename.endsWith('.cbz')) {
        basename = basename.substring(0, basename.length - 4);
      } else if (basename.endsWith('.zip')) {
        basename = basename.substring(0, basename.length - 4);
      }

      _displayComics.add(basename);
    }

    setState(() {});
  }

  Widget _buildComicItem(BuildContext context, int index) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => ReaderPage(
                      readerContext: LocalComicReaderContext(_comics[index]))));
        },
        child: Container(
            width: double.infinity,
            height: 150.h,
            margin: EdgeInsets.only(left: 40.w, right: 40.w),
            color: CupertinoColors.white,
            child: Column(
              children: [
                if (index != 0)
                  Container(
                    height: 0.7.h,
                    color: CupertinoColors.separator,
                  ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_displayComics[index]),
                      Expanded(
                          child: Container(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          goToRead,
                          width: 60.w,
                          height: 60.h,
                        ),
                      ))
                    ],
                  ),
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: CupertinoColors.white,
      child: ListView.builder(
        itemCount: _comics.length,
        itemBuilder: (context, index) {
          return _buildComicItem(context, index);
        },
      ),
    );
  }
}
