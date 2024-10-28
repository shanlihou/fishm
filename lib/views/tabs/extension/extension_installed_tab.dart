import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import '../../../const/general_const.dart';
import '../../../models/db/extensions.dart' as model_extensions;
import '../../../types/manager/actions.dart';
import '../../../types/provider/comic_provider.dart';
import '../../../types/provider/extension_provider.dart';
import '../../../types/provider/task_provider.dart';
import '../../../utils/utils_general.dart';
import '../../dialog/install_confirm_dialog.dart';
import '../../dialog/loading_dialog.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../../pages/extension_config_page.dart';

class ExtensionInstalledTab extends StatefulWidget {
  const ExtensionInstalledTab({super.key});

  @override
  State<ExtensionInstalledTab> createState() => _ExtensionInstalledTabState();
}

class _ExtensionInstalledTabState extends State<ExtensionInstalledTab> {
  @override
  void initState() {
    super.initState();
  }

  bool _checkCouldUninstall(String extensionName) {
    var comicProvider = context.read<ComicProvider>();
    if (comicProvider.isExtensionInUse(extensionName)) {
      return false;
    }

    var taskProvider = context.read<TaskProvider>();
    if (taskProvider.isExtensionInUse(extensionName)) {
      return false;
    }

    return true;
  }

  void _showTip(String message) {
    showCupertinoToast(
      context: context,
      message: message,
    );
  }

  Widget _buildExtensionItem(
      model_extensions.Extension extension, ExtensionProvider p) {
    ExtensionStatus status = ExtensionStatus.installed;
    int index = p.extensionsStore.indexWhere((e) => e.name == extension.name);
    if (index != -1) {
      if (p.extensions[index].version == extension.version) {
        status = ExtensionStatus.installed;
      } else {
        status = ExtensionStatus.needUpdate;
      }
    }

    return GestureDetector(
      onLongPress: () async {
        if (!_checkCouldUninstall(extension.name)) {
          _showTip(
              'could not uninstall: because of downloading or reading history');
          return;
        }

        var p = context.read<ExtensionProvider>();
        if (await showConfirmDialog(context, 'Uninstall ${extension.name}?') ??
            false) {
          p.removeExtension(extension.name);
        }
      },
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(extension.name)),
          Expanded(flex: 4, child: Text(extension.version)),
          Expanded(
              flex: 2,
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExtensionConfigPage(
                                extensionName: extension.name)));
                  },
                  child: Text(AppLocalizations.of(context)!.config))),
          Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () async {
                  if (status == ExtensionStatus.installed) {
                    return;
                  }

                  if (await showConfirmDialog(
                          context, 'Install ${extension.name}?') ??
                      false) {
                    var entry = showLoadingDialog(context);
                    var ext = await installExtension(extension);
                    if (ext != null) {
                      p.updateExtension(ext);
                      actionsManager.resetMainLua();
                    }
                    entry.remove();
                  }
                },
                child: status == ExtensionStatus.needUpdate
                    ? const Icon(Icons.update)
                    : const Icon(Icons.check),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExtensionProvider>(
      builder: (context, extensionProvider, child) {
        var extensions = extensionProvider.extensions;
        return ListView.builder(
          itemCount: extensions.length,
          itemBuilder: (context, index) {
            return _buildExtensionItem(extensions[index], extensionProvider);
          },
        );
      },
    );
  }
}

// 添加一个通用的 CupertinoToast 显示方法
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
      child: Material(
        color: Colors.transparent,
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
