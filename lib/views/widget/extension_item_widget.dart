import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../models/db/extensions.dart' as model_extensions;
import 'package:flutter_gen/gen_l10n/localizations.dart';
import '../../const/assets_const.dart';
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
  final bool supportConfig;
  const ExtensionItemWidget({
    super.key,
    required this.extension,
    required this.status,
    this.onLongPress,
    this.supportConfig = true,
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
    var storeExt = p.getStoreExtension(extension.name);
    if (storeExt == null) {
      return;
    }

    if (await showConfirmDialog(context, 'Install ${extension.displayName}?') ??
        false) {
      var entry = showLoadingDialog(context);
      var ext = await installExtension(storeExt);
      if (ext != null) {
        p.updateExtension(ext);
        actionsManager.resetMainLua();
      }
      entry.remove();
    }
  }

  List<Color> _getColors() {
    if (status == ExtensionStatus.notInstalled) {
      return const [
        Color.fromARGB(255, 131, 190, 253),
        Color.fromARGB(255, 153, 149, 249),
      ];
    } else {
      return const [
        Color.fromARGB(255, 87, 208, 189),
        Color.fromARGB(255, 67, 203, 213),
      ];
    }
  }

  Widget _buildElevatedButton(String text, VoidCallback? onPressed) {
    return material.ElevatedButton(
      style: material.ElevatedButton.styleFrom(
        side: BorderSide(
          color: CupertinoColors.white,
          width: 1.w,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.r),
        ),
        backgroundBuilder: (context, states, child) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _getColors()),
          ),
          child: child,
        ),
      ),
      onPressed: onPressed,
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 44.spMin,
            color: CupertinoColors.white,
          )),
    );
  }

  Widget _buildButton(BuildContext context, VoidCallback? onPressed) {
    switch (status) {
      case ExtensionStatus.needUpdate:
        return _buildElevatedButton(
            AppLocalizations.of(context)!.update, onPressed);
      case ExtensionStatus.installed:
        return Text(AppLocalizations.of(context)!.installed,
            style: TextStyle(
              fontSize: 44.spMin,
              color: CupertinoColors.white,
            ));
      default:
        return _buildElevatedButton(
            AppLocalizations.of(context)!.install, onPressed);
    }
  }

  Widget _buildConfigButton(BuildContext context) {
    if (!supportConfig) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () => _toExtensionConfigPage(context, extension.name),
      child: Image.asset(
        extensionSettings,
        width: 90.w,
        height: 90.h,
        fit: BoxFit.fill,
        color: CupertinoColors.white,
      ),
    );
    // return _buildElevatedButton(
    //   AppLocalizations.of(context)!.config,
    //   () => _toExtensionConfigPage(context, extension.name),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        // borderRadius: BorderRadius.circular(20.r),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        gradient: LinearGradient(
          begin: const Alignment(-1, -1),
          end: const Alignment(1, -0.5),
          colors: _getColors(),
        ),
      ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 20.w),
            alignment: Alignment.bottomLeft,
            width: 40.w,
            height: 120.h,
            child: GestureDetector(
              onTap: () => onLongPress?.call(extension),
              child: Image.asset(
                extensionDelete,
                width: 40.w,
                height: 40.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
              width: 200.w,
              margin: EdgeInsets.fromLTRB(104.w, 54.h, 60.w, 66.h),
              child: Text(
                extension.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 56.spMin,
                  color: CupertinoColors.white,
                ),
              )),
          Container(
              padding: EdgeInsets.only(right: 40.w),
              child: Text(
                extension.version,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 48.spMin,
                  color: CupertinoColors.white,
                ),
              )),
          Expanded(
              flex: 1,
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: _buildConfigButton(context))),
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              width: 320.w,
              height: 120.h,
              child: _buildButton(
                  context, () => _onTapInstall(context, extension, status))),
        ],
      ),
    );
  }
}
