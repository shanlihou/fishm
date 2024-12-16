import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gif/gif.dart';
import 'package:toonfu/const/assets_const.dart';

import '../../const/general_const.dart';
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
      bool success = await key.fetchImage();
      if (!success) {
        throw Exception('Failed to download image: ${key.imageUrl}');
      }
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    return decode(await ImmutableBuffer.fromUint8List(bytes));
  }
}

class NetImage extends StatefulWidget {
  final BoxFit? boxFit;
  final double? width;
  final double? height;
  final NetImageContext ctx;
  const NetImage(this.ctx, {super.key, this.width, this.height, this.boxFit});

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

    if (mounted) {
      setState(() {
        if (success) {
          _isDownloaded = true;
        } else {
          _isDownloadFailed = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isDebug) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: Text('Debug'),
        ),
      );
    }

    if (_isDownloadFailed) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Text(AppLocalizations.of(context)!.imageDownloadFailed,
              style: const TextStyle(color: CupertinoColors.systemGrey)),
        ),
      );
    }

    if (_isDownloaded) {
      // if (false) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: CupertinoColors.white,
        child: Image.file(
          File(widget.ctx.imagePath),
          fit: widget.boxFit ?? BoxFit.contain,
          width: widget.width,
          height: widget.height,
        ),
      );
    }

    // return Image not found
    double ratio = 0.4;
    return SizedBox(
      width: (widget.width == null ? 1.sw : widget.width!) * ratio,
      height: widget.height,
      child: Center(
        child: Gif(
          width: (widget.width == null ? 1.sw : widget.width!) * ratio,
          height: widget.height,
          image: const AssetImage(loadingGif),
          // fps: 30,
          autostart: Autostart.loop,
          duration: const Duration(milliseconds: 1400),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
