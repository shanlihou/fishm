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

  List<Color> _getColors() {
    if (status == ExtensionStatus.notInstalled) {
      return const [
        const Color.fromARGB(255, 131, 190, 253),
        const Color.fromARGB(255, 153, 149, 249),
      ];
    } else {
      return const [
        const Color.fromARGB(255, 87, 208, 189),
        const Color.fromARGB(255, 67, 203, 213),
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
          borderRadius: BorderRadius.circular(40.r),
        ),
        backgroundBuilder: (context, states, child) => Container(
          child: child,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _getColors()),
          ),
        ),
      ),
      child: Text(text, style: TextStyle(color: CupertinoColors.white)),
      onPressed: onPressed,
    );
  }

  Widget _buildButton(BuildContext context, VoidCallback? onPressed) {
    switch (status) {
      case ExtensionStatus.needUpdate:
        return _buildElevatedButton(
            AppLocalizations.of(context)!.update, onPressed);
      case ExtensionStatus.installed:
        return Text(AppLocalizations.of(context)!.installed,
            style: TextStyle(color: CupertinoColors.white));
      default:
        return _buildElevatedButton(
            AppLocalizations.of(context)!.install, onPressed);
    }
  }

  Widget _buildConfigButton(BuildContext context) {
    if (!supportConfig) {
      return const SizedBox.shrink();
    }
    return _buildElevatedButton(
      AppLocalizations.of(context)!.config,
      () => _toExtensionConfigPage(context, extension.name),
    );
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
          colors: _getColors(),
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
                flex: 1, child: Center(child: _buildConfigButton(context))),
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(right: 60.w),
                width: 320.w,
                child: _buildButton(
                    context, () => _onTapInstall(context, extension, status))),
          ],
        ),
      ),
    );
  }
}
