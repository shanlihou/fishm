import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../const/color_const.dart';
import 'utils_general.dart';

Widget comicTabBaseline(BuildContext context, {Color? backgroundColor}) {
  return Container(
    height: 106.h,
    color: backgroundColor,
    child: Row(
      children: [
        SizedBox(width: 100.w),
        Expanded(
          child: Container(
            // #BBBBBB 100%
            color: lineColor,
            height: 1.h,
          ),
        ),
        Column(
          children: [
            Expanded(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    AppLocalizations.of(context)!.baseline,
                    style: TextStyle(fontSize: pm(12, 24.spMin)),
                  )),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                child: Text(
                  AppLocalizations.of(context)!.findMore,
                  style: TextStyle(
                    // #B886F8 88%
                    color: const Color(0xFFB886F8).withOpacity(0.88),
                    fontSize: pm(12, 24.spMin),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            // #BBBBBB 100%
            color: lineColor,
            height: 1.h,
          ),
        ),
        SizedBox(width: 100.w),
      ],
    ),
  );
}

void showCupertinoToast({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 2),
}) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 50,
      left: 32,
      right: 32,
      child: material.Material(
        color: material.Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
