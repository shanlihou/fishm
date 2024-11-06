import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../models/db/extensions.dart' as model_extensions;
import 'package:flutter_gen/gen_l10n/localizations.dart';
import '../../const/general_const.dart';
import '../../types/manager/actions.dart';
import '../../types/provider/extension_provider.dart';
import '../../utils/utils_general.dart';
import '../dialog/install_confirm_dialog.dart';
import '../dialog/loading_dialog.dart';
import '../pages/extension_config_page.dart';

class ExtensionItemWidget extends StatelessWidget {
  final model_extensions.Extension extension;
  final ExtensionStatus status;
  final void Function(model_extensions.Extension)? onLongPress;
  const ExtensionItemWidget({
    super.key,
    required this.extension,
    required this.status,
    this.onLongPress,
  });

  void _toExtensionConfigPage(BuildContext context, String extensionName) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ExtensionConfigPage(
          extensionName: extensionName,
        ),
      ),
    );
  }

  void _onTapInstall(
    BuildContext context,
    model_extensions.Extension extension,
    ExtensionStatus status,
  ) async {
    if (status == ExtensionStatus.installed) {
      return;
    }

    var p = context.read<ExtensionProvider>();

    if (await showConfirmDialog(context, 'Install ${extension.name}?') ??
        false) {
      var entry = showLoadingDialog(context);
      var ext = await installExtension(extension);
      if (ext != null) {
        p.updateExtension(ext);
        actionsManager.resetMainLua();
      }
      entry.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 100.w, vertical: 35.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, -0.5),
          colors: [
            const Color.fromARGB(255, 87, 208, 189),
            const Color.fromARGB(255, 67, 203, 213),
          ],
        ),
      ),
      child: GestureDetector(
        onLongPress: () => onLongPress?.call(extension),
        child: Row(
          children: [
            Container(
                width: 250.w,
                margin: EdgeInsets.fromLTRB(153.w, 54.h, 0, 66.h),
                child: Text(
                  extension.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            Expanded(
                flex: 1,
                child: Text(
                  extension.version,
                  style: TextStyle(color: CupertinoColors.white),
                )),
            Expanded(
                flex: 1,
                child: CupertinoButton(
                  onPressed: () =>
                      _toExtensionConfigPage(context, extension.name),
                  child: Text(AppLocalizations.of(context)!.config,
                      style: TextStyle(color: CupertinoColors.white)),
                )),
            Expanded(
                flex: 1,
                child: status == ExtensionStatus.needUpdate
                    ? CupertinoButton(
                        onPressed: null,
                        child: Text(AppLocalizations.of(context)!.update,
                            style: TextStyle(color: CupertinoColors.white)),
                      )
                    : status == ExtensionStatus.installed
                        ? Text(AppLocalizations.of(context)!.installed,
                            style: TextStyle(color: CupertinoColors.white))
                        : CupertinoButton(
                            child: Text(AppLocalizations.of(context)!.install,
                                style: TextStyle(color: CupertinoColors.white)),
                            onPressed: () =>
                                _onTapInstall(context, extension, status),
                          )),
          ],
        ),
      ),
    );
  }
}
