import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../types/context/net_iamge_context.dart';

class NetImageProvider extends ImageProvider<NetImageProvider> {
  final NetImageContext ctx;
  const NetImageProvider(this.ctx);

  @override
  Future<NetImageProvider> obtainKey(ImageConfiguration configuration) async {
    return SynchronousFuture<NetImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      NetImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key.ctx, decode),
      scale: 1.0,
    );
  }

  static Future<Codec> _loadAsync(
      NetImageContext key, ImageDecoderCallback decode) async {
    final File imageFile = File(key.imagePath);

    if (!await imageFile.exists()) {
      // 如果文件不存在，先下载到本地
      bool success = await key.fetchImage();
      if (!success) {
        throw Exception('下载图片失败: ${key.imageUrl}');
      }
    }

    // 从本地文件读取图片数据
    final Uint8List bytes = await imageFile.readAsBytes();
    return decode(await ImmutableBuffer.fromUint8List(bytes));
  }
}

class NetImage extends StatefulWidget {
  final double width;
  final double height;
  final NetImageContext ctx;
  const NetImage(this.ctx, this.width, this.height, {super.key});

  @override
  State<NetImage> createState() => _NetImageState();
}

class _NetImageState extends State<NetImage> {
  bool _isDownloaded = false;
  bool _isDownloadFailed = false;

  @override
  void initState() {
    super.initState();

    if (File(widget.ctx.imagePath).existsSync()) {
      _isDownloaded = true;
    } else {
      _downloadImage();
    }
  }

  @override
  void didUpdateWidget(covariant NetImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ctx.imagePath != widget.ctx.imagePath) {
      _isDownloaded = false;
      if (File(widget.ctx.imagePath).existsSync()) {
        _isDownloaded = true;
      } else {
        _downloadImage();
      }
    }
  }

  Future<void> _downloadImage() async {
    bool success = await widget.ctx.fetchImage();
    if (!success) {
      setState(() {
        _isDownloadFailed = true;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isDownloaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloadFailed) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: Text('Image download failed'),
        ),
      );
    }

    if (_isDownloaded) {
      return Image.file(
        File(widget.ctx.imagePath),
        fit: BoxFit.contain,
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
