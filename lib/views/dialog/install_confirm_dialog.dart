import 'package:flutter/cupertino.dart';

Future<bool?> showConfirmDialog(BuildContext context, String text) async {
  return await showCupertinoDialog<bool>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(text),
        actions: [
          CupertinoButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          CupertinoButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm')),
        ],
      );
    },
  );
}
