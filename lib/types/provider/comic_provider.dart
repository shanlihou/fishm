import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:toonfu/models/db/comic_model.dart';

import '../../const/db_const.dart';
import '../../models/db/read_history_model.dart';
import '../../utils/utils_general.dart';

class ComicProvider with ChangeNotifier {
  bool _isLoad = false;
  late Box<ComicModel> _comicBox;
  final List<(ComicModel, int)> _historyComics = [];

  late Box<ComicModel> _favoriteComicBox;
  final Map<String, ComicModel> favoriteComics = {};

  late Box<ReadHistoryModel> _readHistoryBox;
  final Map<String, ReadHistoryModel> readHistory = {};

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

    _favoriteComicBox = await Hive.openBox<ComicModel>(favoriteComicHiveKey);
    _favoriteComicBox.toMap().forEach((key, value) {
      favoriteComics[key] = value;
    });

    _readHistoryBox = await Hive.openBox<ReadHistoryModel>(readHistoryHiveKey);
    _readHistoryBox.toMap().forEach((key, value) {
      readHistory[key] = value;
    });

    await clearHomelessReadHistory();
  }

  Future<void> clearHomelessReadHistory() async {
    List<String> homelessReadHistory = [];
    for (var i in readHistory.keys) {
      if (favoriteComics.containsKey(i)) {
        continue;
      }

      if (getHistoryComicModel(i) != null) {
        continue;
      }

      homelessReadHistory.add(i);
    }

    for (var i in homelessReadHistory) {
      await _readHistoryBox.delete(i);
      readHistory.remove(i);
    }
  }

  ComicModel? getHistoryComicModel(String uniqueId) {
    for (var i = _historyComics.length - 1; i >= 0; i--) {
      if (_historyComics[i].$1.uniqueId == uniqueId) {
        return _historyComics[i].$1;
      }
    }
    return null;
  }

  ComicModel? getComicModel(String uniqueId) {
    ComicModel? comic = getHistoryComicModel(uniqueId);
    if (comic != null) {
      return comic;
    }

    return favoriteComics[uniqueId];
  }

  Future<void> saveComic(ComicModel comic) async {
    await addComic(comic, false);
    await _favoriteComicBox.put(comic.uniqueId, comic);
  }

  Future<void> removeHistoryComic(List<String> uniqueIds) async {
    for (var i = _historyComics.length - 1; i >= 0; i--) {
      if (uniqueIds.contains(_historyComics[i].$1.uniqueId)) {
        _comicBox.delete(_historyComics[i].$2);
        _historyComics.removeAt(i);
      }
    }

    notifyListeners();
  }

  bool isExtensionInUse(String extensionName) {
    for (var i in _historyComics) {
      if (i.$1.extensionName == extensionName) {
        return true;
      }
    }

    for (var i in favoriteComics.values) {
      if (i.extensionName == extensionName) {
        return true;
      }
    }

    return false;
  }

  Future<void> addComic(ComicModel comic, bool isNotify) async {
    for (var i = _historyComics.length - 1; i >= 0; i--) {
      if (_historyComics[i].$1.uniqueId == comic.uniqueId) {
        _comicBox.delete(_historyComics[i].$2);
        _historyComics.removeAt(i);
        break;
      }
    }

    int now = getTimestamp();
    await _comicBox.put(now, comic);
    _historyComics.insert(0, (comic, now));
    if (isNotify) {
      notifyListeners();
    }
  }

  Future<void> addFavoriteComic(String uniqueId) async {
    ComicModel? comic = getHistoryComicModel(uniqueId);
    if (comic == null) {
      return;
    }

    await _favoriteComicBox.put(comic.uniqueId, comic);
    favoriteComics[comic.uniqueId] = comic;

    notifyListeners();
  }

  Future<void> removeFavoriteComic(String uniqueId) async {
    await _favoriteComicBox.delete(uniqueId);
    favoriteComics.remove(uniqueId);

    notifyListeners();
  }

  Future<void> recordReadHistory(
      String uniqueId, String chapterId, int index) async {
    ReadHistoryModel readHistory = ReadHistoryModel(chapterId, index);
    await _readHistoryBox.put(uniqueId, readHistory);
    this.readHistory[uniqueId] = readHistory;
    notifyListeners();
  }

  String? getReadHistory(String uniqueId) {
    ReadHistoryModel? readHistory = this.readHistory[uniqueId];
    if (readHistory == null) {
      return null;
    }

    var comicModel = getComicModel(uniqueId);
    if (comicModel == null) {
      return null;
    }

    var chapterTitle = comicModel.getChapterTitle(readHistory.chapterId);

    return 'chapter: $chapterTitle page: ${readHistory.index}';
  }
}
