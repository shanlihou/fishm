import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../const/color_const.dart';
import 'utils_general.dart';

Widget comicTabBaseline(BuildContext context, String title,
    {Color? backgroundColor, VoidCallback? onTap}) {
  Widget line = Expanded(
    child: Container(
      // #BBBBBB 100%
      color: lineColor,
      height: 1.h,
    ),
  );
  double border = 60.w;

  return Container(
    height: 106.h,
    color: backgroundColor,
    child: Row(
      children: [
        SizedBox(width: border),
        line,
        Container(
          margin: EdgeInsets.only(left: 20.w, right: 20.w),
          child: Column(
            children: [
              Expanded(
                child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      AppLocalizations.of(context)!.baseline,
                      style: TextStyle(fontSize: pm(12, 28.spMin)),
                    )),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onTap?.call();
                  },
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Text(
                      title,
                      style: TextStyle(
                        // #B886F8 88%
                        color: const Color(0xFFB886F8).withOpacity(0.88),
                        fontSize: pm(12, 28.spMin),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        line,
        SizedBox(width: border),
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

Widget buildImportBase(
    BuildContext context, String imagePath, String title, String desc) {
  return Container(
    width: double.infinity,
    alignment: Alignment.center,
    height: 500.h,
    color: CupertinoColors.white,
    margin: EdgeInsets.only(bottom: 30.h, top: 40.h, left: 30.w, right: 30.w),
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 70.h, bottom: 30.h),
          child: Image.asset(
            imagePath,
            width: 200.w,
            height: 200.h,
          ),
        ),
        Text(title,
            style: TextStyle(
                fontSize: pm(16, 50.spMin),
                color: importTextColor,
                fontWeight: FontWeight.bold)),
        Container(
          margin: EdgeInsets.only(top: 10.h),
          child: Text(desc,
              style: TextStyle(
                  fontSize: pm(14, 48.spMin), color: CupertinoColors.black)),
        ),
      ],
    ),
  );
}

Widget buildCommonBase(BuildContext context, String imagePath, String title) {
  return Column(
    children: [
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 70.h, bottom: 20.h),
        child: Image.asset(
          imagePath,
          width: 200.w,
          height: 200.h,
        ),
      ),
      Container(
        margin: EdgeInsets.only(bottom: 30.h),
        child: SizedBox(
          height: 70.h,
          child: Text(title,
              style: TextStyle(
                  fontSize: pm(16, 50.spMin),
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.normal)),
        ),
      ),
    ],
  );
}

Widget buildElevatedButton(
    BuildContext context, String text, VoidCallback onPressed) {
  return material.ElevatedButton(
    style: material.ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.r),
        ),
        backgroundBuilder: (context, states, child) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  commonBlue,
                  Color.fromARGB(255, 153, 149, 249),
                ]),
              ),
              child: child,
            )),
    onPressed: onPressed,
    child: Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: pm(20, 40.spMin), color: CupertinoColors.white)),
  );
}
