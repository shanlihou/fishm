import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

Widget comicTabBaseline(BuildContext context) {
  return SizedBox(
    height: 106.h,
    child: Row(
      children: [
        SizedBox(width: 100.w),
        Expanded(
          child: Container(
            // #BBBBBB 100%
            color: const Color(0xFFBBBBBB),
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
                    style: TextStyle(
                      fontSize: 40.spMin,
                    ),
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
                    fontSize: 40.spMin,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            // #BBBBBB 100%
            color: const Color(0xFFBBBBBB),
            height: 1.h,
          ),
        ),
        SizedBox(width: 100.w),
      ],
    ),
  );
}
