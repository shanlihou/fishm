import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../const/general_const.dart';
import '../../../models/db/extensions.dart' as model_extensions;
import '../../../types/common/alias.dart';
import '../../../types/manager/actions.dart';
import '../../../types/provider/extension_provider.dart';
import '../../../types/provider/setting_provider.dart';
import '../../../utils/utils_general.dart';
import '../../dialog/install_confirm_dialog.dart';
import '../../dialog/loading_dialog.dart';

class ExtensionStoreTab extends StatefulWidget {
  const ExtensionStoreTab({super.key});

  @override
  State<ExtensionStoreTab> createState() => _ExtensionStoreTabState();
}

class _ExtensionStoreTabState extends State<ExtensionStoreTab> {
  final EasyRefreshController _easyRefreshController =
      EasyRefreshController(controlFinishRefresh: true);

  @override
  void initState() {
    super.initState();
  }

  Widget _buildExtensionItem(
      model_extensions.Extension extension, ExtensionProvider p) {
    ExtensionStatus status = ExtensionStatus.notInstalled;
    int index = p.extensions.indexWhere((e) => e.name == extension.name);
    if (index != -1) {
      if (p.extensions[index].version == extension.version) {
        status = ExtensionStatus.installed;
      } else {
        status = ExtensionStatus.needUpdate;
      }
    }

    return Row(
      children: [
        Expanded(flex: 2, child: Text(extension.name)),
        Expanded(flex: 6, child: Text(extension.version)),
        Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () async {
                if (status == ExtensionStatus.installed) {
                  return;
                }

                if (await showInstallConfirmDialog(context, extension) ??
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
              child: status == ExtensionStatus.notInstalled
                  ? const Icon(Icons.download)
                  : status == ExtensionStatus.needUpdate
                      ? const Icon(Icons.update)
                      : const Icon(Icons.check),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
        refreshOnStart: true,
        controller: _easyRefreshController,
        onRefresh: () async {
          ExtensionProvider p = context.read<ExtensionProvider>();
          Exts extensions = await loadRemoteExtensions(
              context.read<SettingProvider>().sources);

          p.updateExtensionStore(extensions);
          _easyRefreshController.finishRefresh(IndicatorResult.success);
        },
        child: Consumer<ExtensionProvider>(
          builder: (context, extensionProvider, child) {
            Exts extensions = extensionProvider.extensionsStore;
            return ListView.builder(
              itemCount: extensions.length,
              itemBuilder: (context, index) {
                return _buildExtensionItem(
                    extensions[index], extensionProvider);
              },
            );
          },
        ));
  }
}
