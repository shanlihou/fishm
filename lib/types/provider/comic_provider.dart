import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:toonfu/models/db/comic_model.dart';

import '../../const/db_const.dart';
import '../../utils/utils_general.dart';

class ComicProvider with ChangeNotifier {
  bool _isLoad = false;
  late Box<ComicModel> _comicBox;
  final List<(ComicModel, int)> _historyComics = [];

  List<ComicModel> get historyComics =>
      _historyComics.map((e) => e.$1).toList();

  ComicProvider();

  Future<void> loadComics() async {
    if (_isLoad) {
      return;
    }

    _isLoad = true;
    _comicBox = await Hive.openBox<ComicModel>(comicHistoryHiveKey);
    _comicBox.toMap().forEach((key, value) {
      _historyComics.add((value, key));
    });

    _historyComics.sort((a, b) => b.$2.compareTo(a.$2));

    notifyListeners();
  }

  ComicModel? getComicModel(String uniqueId) {
    for (var i = _historyComics.length - 1; i >= 0; i--) {
      if (_historyComics[i].$1.uniqueId == uniqueId) {
        return _historyComics[i].$1;
      }
    }
    return null;
  }

  Future<void> addComic(ComicModel comic) async {
    for (var i = _historyComics.length - 1; i >= 0; i--) {
      if (_historyComics[i].$1.uniqueId == comic.uniqueId) {
        _comicBox.delete(_historyComics[i].$2);
        _historyComics.removeAt(i);
        break;
      }
    }

    int now = getTimestamp();
    _comicBox.put(now, comic);
    _historyComics.add((comic, now));
    notifyListeners();
  }
}
