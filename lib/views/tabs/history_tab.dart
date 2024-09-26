import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/models/db/comic_model.dart';
import 'package:toonfu/types/provider/comic_provider.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    List<ComicModel> comics = context.watch<ComicProvider>().historyComics;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('历史记录'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: comics.length,
                itemBuilder: (context, index) {
                  return Text(comics[index].title);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
