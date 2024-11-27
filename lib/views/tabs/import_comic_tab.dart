import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toonfu/const/color_const.dart';

import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:toonfu/const/general_const.dart';
import '../../const/assets_const.dart';
import '../../utils/utils_general.dart';

class ImportComicTab extends StatefulWidget {
  const ImportComicTab({super.key});

  @override
  State<ImportComicTab> createState() => _ImportComicTabState();
}

class _ImportComicTabState extends State<ImportComicTab> {
  @override
  void dispose() {
    super.dispose();
  }

  String _buildImportDir() {
    if (Platform.isWindows) {
      return Directory.current.path + '\\' + cbzDir;
    }
    return Directory.current.path + '/' + cbzDir;
  }

  String _buildStep2Tab() {
    String bookshelf = AppLocalizations.of(context)!.bookshelf;
    String local = AppLocalizations.of(context)!.local;
    return ' ${bookshelf} - ${local} ';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        color: backgroundColor06,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              height: 500.h,
              color: CupertinoColors.white,
              margin: EdgeInsets.all(30.h),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 50.h, bottom: 30.h),
                    child: Image.asset(
                      importBig,
                      width: 200.w,
                      height: 200.h,
                    ),
                  ),
                  Text(AppLocalizations.of(context)!.import,
                      style: TextStyle(
                          fontSize: pm(16, 50.spMin),
                          color: CupertinoColors.black,
                          fontWeight: FontWeight.bold)),
                  Container(
                    margin: EdgeInsets.only(top: 10.h),
                    child: Text(AppLocalizations.of(context)!.importDesc,
                        style: TextStyle(
                            fontSize: pm(14, 50.spMin),
                            color: CupertinoColors.black)),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(30.h),
              width: double.infinity,
              height: 400.h,
              color: CupertinoColors.white,
              margin: EdgeInsets.all(30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.stepX(1)),
                  Text(AppLocalizations.of(context)!.step1),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            _buildImportDir()),
                      ),
                      SizedBox(
                        height: 100.h,
                        child: CupertinoButton(
                          color: CupertinoColors.systemBlue,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text(AppLocalizations.of(context)!.copyPath,
                              style: TextStyle(
                                  fontSize: pm(14, 30.spMin),
                                  color: CupertinoColors.white)),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _buildImportDir()));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 300.h,
              color: CupertinoColors.white,
              margin: EdgeInsets.all(30.h),
              padding: EdgeInsets.all(30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.stepX(2)),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.step2Prefix),
                      Text(_buildStep2Tab(),
                          style: TextStyle(
                              color: CupertinoColors.systemBlue,
                              fontWeight: FontWeight.bold)),
                      Text(AppLocalizations.of(context)!.step2Suffix),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
