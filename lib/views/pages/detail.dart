import 'package:flutter/material.dart';
import '../../api/flutter_call_lua/method.dart';

class ComicDetailPage extends StatefulWidget {
  final String title;
  final String author;
  final String coverImage;
  final String description;
  final Map<String, dynamic> extra;

  const ComicDetailPage(this.extra, {
    super.key,
    required this.title,
    required this.author,
    required this.coverImage,
    required this.description,
  });

  @override
  _ComicDetailPageState createState() => _ComicDetailPageState();
}

class _ComicDetailPageState extends State<ComicDetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    getDetail(widget.extra);
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.coverImage, height: 200, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title),
                  SizedBox(height: 8),
                  Text('作者: ${widget.author}'),
                  SizedBox(height: 16),
                  Text('简介:'),
                  SizedBox(height: 8),
                  Text(widget.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
