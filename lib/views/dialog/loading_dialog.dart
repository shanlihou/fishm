import 'package:flutter/material.dart';

OverlayEntry showLoadingDialog(BuildContext context) {
  final OverlayState overlayState = Overlay.of(context);
  final OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  );
  overlayState.insert(overlayEntry);

  return overlayEntry;
}
