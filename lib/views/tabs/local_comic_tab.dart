import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../common/log.dart';
import '../../const/general_const.dart';

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

  void _loadLocalComics() {
    var files = Directory(cbzDir).listSync();
    Log.instance.d('local comics: ${files.length}');
    for (var file in files) {
      Log.instance.d('local comic: $file');
      _comics.add(file.path);
    }
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
          return Text(_comics[index]);
        },
      ),
    );
  }
}
