import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:toonfu/const/general.dart';
import 'package:toonfu/api/flutter_call_lua/method.dart';

import '../../common/log.dart';

class NetImage extends StatefulWidget {
  final String extensionName;
  final String imgKey;
  final String imageUrl;
  final Map<String, dynamic> extra;
  const NetImage(this.extensionName, this.imgKey, this.imageUrl, this.extra,
      {super.key});

  @override
  State<NetImage> createState() => _NetImageState();
}

class _NetImageState extends State<NetImage> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();

    if (File(_formatImagePath()).existsSync()) {
      _isDownloading = true;
    } else {
      _downloadImage();
    }
  }

  Future<void> _downloadImage() async {
    var ret = await downloadImage(widget.extensionName, widget.extra,
        widget.imageUrl, _formatImagePath()) as Map<String, dynamic>;

    int code = ret['code'] as int;

    if (code != 200) {
      Log.instance.e('download image failed: $ret');
      return;
    }

    if (mounted) {
      setState(() {
        _isDownloading = true;
      });
    }
  }

  String _getImageType() {
    String imgType = widget.imgKey.split('.').last;
    if (imgType == 'jpg' || imgType == 'png' || imgType == 'webp') {
      return imgType;
    }
    return 'jpg';
  }

  String _formatImagePath() {
    return '$tempImageDir/${widget.imgKey}.${_getImageType()}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return Image.file(
        File(_formatImagePath()),
        fit: BoxFit.cover,
      );
    }

    // return Image not found
    return const SizedBox(
      width: 100,
      height: 100,
      child: Center(
        child: Text('Image not found'),
      ),
    );
  }
}
