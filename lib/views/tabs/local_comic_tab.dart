import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../common/log.dart';
import '../../const/general_const.dart';
import '../../types/context/local_comic_reader_context.dart';
import '../pages/reader_page.dart';

class LocalComicTab extends StatefulWidget {
  const LocalComicTab({super.key});

  @override
  State<LocalComicTab> createState() => _LocalComicTabState();
}

class _LocalComicTabState extends State<LocalComicTab> {
  List<String> _comics = [];

  @override
  void initState() {
    super.initState();

    _loadLocalComics();
  }

  Future<void> _loadLocalComics() async {
    var files = await Directory(cbzDir).list().toList();
    Log.instance.d('local comics: ${files.length}');
    for (var file in files) {
      Log.instance.d('local comic: $file');
      _comics.add(file.path);
    }

    setState(() {});
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
          return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ReaderPage(
                            readerContext:
                                LocalComicReaderContext(_comics[index]))));
              },
              child: Text(_comics[index]));
        },
      ),
    );
  }
}
