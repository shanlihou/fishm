import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../const/general_const.dart';
import '../../../models/db/extensions.dart' as model_extensions;
import '../../../types/manager/actions.dart';
import '../../../types/provider/extension_provider.dart';
import '../../../utils/utils_general.dart';
import '../../dialog/install_confirm_dialog.dart';
import '../../dialog/loading_dialog.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

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

    return Row(
      children: [
        Expanded(flex: 2, child: Text(extension.name)),
        Expanded(flex: 4, child: Text(extension.version)),
        Expanded(
            flex: 2,
            child: TextButton(
                onPressed: () {},
                child: Text(AppLocalizations.of(context)!.config))),
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
              child: status == ExtensionStatus.needUpdate
                  ? Icon(Icons.update)
                  : Icon(Icons.check),
            )),
      ],
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
