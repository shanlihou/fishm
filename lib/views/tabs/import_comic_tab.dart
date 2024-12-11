import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toonfu/const/color_const.dart';

import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:toonfu/const/general_const.dart';
import '../../const/assets_const.dart';
import '../../utils/utils_general.dart';
import '../../utils/utils_widget.dart';

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
      return '${Directory.current.path}\\$cbzDir';
    }
    return '${Directory.current.path}/$cbzDir';
  }

  String _buildStep2Tab() {
    String bookshelf = AppLocalizations.of(context)!.bookshelf;
    String local = AppLocalizations.of(context)!.local;
    return ' $bookshelf - $local ';
  }

  Widget _buildCopyPathButton() {
    return SizedBox(
      height: 80.h,
      width: 250.w,
      child: material.Material(
        color: material.Colors.transparent,
        child: material.ElevatedButton(
          style: material.ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundBuilder: (context, states, childBackButtonDispatcher) =>
                Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 131, 190, 253),
                  Color.fromARGB(255, 153, 149, 249),
                ]),
              ),
              child: childBackButtonDispatcher,
            ),
          ),
          child: Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              AppLocalizations.of(context)!.copyPath,
              style: TextStyle(
                  fontSize: pm(14, 30.spMin), color: CupertinoColors.white)),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _buildImportDir()));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        color: backgroundColor06,
        child: Column(
          children: [
            buildImportBase(
                context,
                importBig,
                AppLocalizations.of(context)!.import,
                AppLocalizations.of(context)!.importDesc),
            Container(
              padding: EdgeInsets.all(30.h),
              width: double.infinity,
              height: 500.h,
              color: CupertinoColors.white,
              margin: EdgeInsets.all(30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10.h, top: 10.h),
                    child: Text(
                        style: TextStyle(
                          fontSize: pm(16, 50.spMin),
                          color: CupertinoColors.black.withOpacity(0.3),
                        ),
                        AppLocalizations.of(context)!.stepX(1)),
                  ),
                  Text(AppLocalizations.of(context)!.step1),
                  Container(
                    margin: EdgeInsets.only(top: 20.h, bottom: 20.h),
                    child: Text(
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: pm(14, 46.spMin),
                          color: importTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        _buildImportDir()),
                  ),
                  _buildCopyPathButton(),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 220.h,
              color: CupertinoColors.white,
              margin: EdgeInsets.all(30.h),
              padding: EdgeInsets.all(30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10.h, top: 10.h),
                    child: Text(
                        style: TextStyle(
                          fontSize: pm(16, 50.spMin),
                          color: CupertinoColors.black.withOpacity(0.3),
                        ),
                        AppLocalizations.of(context)!.stepX(2)),
                  ),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.step2Prefix),
                      Text(_buildStep2Tab(),
                          style: const TextStyle(
                              color: importTextColor,
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
