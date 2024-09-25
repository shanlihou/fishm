import 'package:flutter/material.dart';

class NetImage extends StatefulWidget {
  final String imgKey;
  final String imageUrl;
  final Map<String, dynamic> extra;
  const NetImage(this.imgKey, this.imageUrl, this.extra, {super.key});

  @override
  State<NetImage> createState() => _NetImageState();
}

class _NetImageState extends State<NetImage> {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.imageUrl,
      fit: BoxFit.cover,
    );
  }
}
