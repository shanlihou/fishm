import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../const/general_const.dart';
import '../../../models/db/extensions.dart' as model_extensions;
import '../../../types/provider/comic_provider.dart';
import '../../../types/provider/extension_provider.dart';
import '../../../types/provider/task_provider.dart';
import '../../../utils/utils_widget.dart';
import '../../dialog/install_confirm_dialog.dart';

import '../../widget/extension_item_widget.dart';

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

  Future<void> _onItemLongPress(model_extensions.Extension extension) async {
    if (!_checkCouldUninstall(extension.name)) {
      showCupertinoToast(
        context: context,
        message:
            'could not uninstall: because of downloading or reading history',
      );
      return;
    }

    var p = context.read<ExtensionProvider>();
    if (await showConfirmDialog(context, 'Uninstall ${extension.name}?') ??
        false) {
      p.removeExtension(extension.name);
    }
  }

  Widget _buildExtensionItem(
      model_extensions.Extension extension, ExtensionProvider p) {
    ExtensionStatus status = ExtensionStatus.installed;
    int index = p.extensionsStore.indexWhere((e) => e.name == extension.name);
    if (index != -1) {
      if (p.extensionsStore[index].version == extension.version) {
        status = ExtensionStatus.installed;
      } else {
        status = ExtensionStatus.needUpdate;
      }
    }

    return ExtensionItemWidget(
      extension: extension,
      status: status,
      onLongPress: _onItemLongPress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExtensionProvider>(
      builder: (context, extensionProvider, child) {
        var extensions = extensionProvider.extensions;
        List<Widget> children = extensions
            .map(
              (e) => Container(
                color: CupertinoColors.white,
                child: _buildExtensionItem(e, extensionProvider),
              ),
            )
            .toList();

        children.add(
            comicTabBaseline(context, backgroundColor: CupertinoColors.white));

        return Container(
          margin: EdgeInsets.fromLTRB(43.w, 0.h, 43.w, 44.h),
          child: SingleChildScrollView(
            child: Column(
              children: children,
            ),
          ),
        );
      },
    );
  }
}
