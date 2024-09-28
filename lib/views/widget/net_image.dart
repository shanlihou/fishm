import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:toonfu/const/general_const.dart';

import '../../types/context/net_iamge_context.dart';

class NetImage extends StatefulWidget {
  final double width;
  final double height;
  final NetImageType type;
  final NetImageContext ctx;
  const NetImage(this.type, this.ctx, this.width, this.height, {super.key});

  @override
  State<NetImage> createState() => _NetImageState();
}

class _NetImageState extends State<NetImage> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();

    if (File(widget.ctx.imagePath).existsSync()) {
      _isDownloading = true;
    } else {
      _downloadImage();
    }
  }

  @override
  void didUpdateWidget(covariant NetImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ctx.imagePath != widget.ctx.imagePath) {
      _isDownloading = false;
      if (File(widget.ctx.imagePath).existsSync()) {
        _isDownloading = true;
      } else {
        _downloadImage();
      }
    }
  }

  Future<void> _downloadImage() async {
    bool success = await widget.ctx.fetchImage();
    if (!success) {
      return;
    }

    if (mounted) {
      setState(() {
        _isDownloading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return Image.file(
        File(widget.ctx.imagePath),
        fit: BoxFit.cover,
        width: widget.width,
        height: widget.height,
      );
    }

    // return Image not found
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const Center(
        child: Text('Image not found'),
      ),
    );
  }
}
