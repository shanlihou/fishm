import 'package:flutter/cupertino.dart';

import '../../models/db/extensions.dart' as model_extensions;

Future<bool?> showInstallConfirmDialog(
    BuildContext context, model_extensions.Extension extension) async {
  return await showCupertinoDialog<bool>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text('Install ${extension.name}?'),
        actions: [
          CupertinoButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          CupertinoButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Install')),
        ],
      );
    },
  );
}
