import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ftp_server/ftp_server.dart';
import 'package:ftp_server/server_type.dart';

class ImportComicTab extends StatefulWidget {
  const ImportComicTab({super.key});

  @override
  State<ImportComicTab> createState() => _ImportComicTabState();
}

class _ImportComicTabState extends State<ImportComicTab> {
  FtpServer? _ftpServer;

  Future<void> _toggleFtpServer() async {
    print('before start server ${_ftpServer == null}');
    if (_ftpServer == null) {
      _ftpServer = FtpServer(
        2121,
        username: 'toonfu',
        password: 'toonfu',
        sharedDirectories: [
          '${Directory.current.path}/cbz',
        ],
        startingDirectory: 'ftp',
        serverType: ServerType.readAndWrite,
      );

      await _ftpServer!.start();
    } else {
      await _ftpServer!.stop();
      _ftpServer = null;
    }

    print('after start server ${_ftpServer == null}');
    setState(() {});
  }

  @override
  void dispose() {
    _ftpServer?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          CupertinoButton(
            child: Text(
                _ftpServer == null ? 'Start FTP Server' : 'Stop FTP Server'),
            onPressed: () => _toggleFtpServer(),
          ),
        ],
      ),
    );
  }
}
