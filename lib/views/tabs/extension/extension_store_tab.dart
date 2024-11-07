import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../const/general_const.dart';
import '../../../models/db/extensions.dart' as model_extensions;
import '../../../types/common/alias.dart';
import '../../../types/provider/extension_provider.dart';
import '../../../types/provider/setting_provider.dart';
import '../../../utils/utils_general.dart';
import '../../../utils/utils_widget.dart';
import '../../widget/extension_item_widget.dart';

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

    return ExtensionItemWidget(
      extension: extension,
      status: status,
      supportConfig: false,
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
            List<Widget> children = extensions
                .map(
                  (e) => Container(
                    color: CupertinoColors.white,
                    child: _buildExtensionItem(e, extensionProvider),
                  ),
                )
                .toList();

            children.add(comicTabBaseline(context,
                backgroundColor: CupertinoColors.white));

            return Container(
              margin: EdgeInsets.fromLTRB(43.w, 0.h, 43.w, 44.h),
              child: SingleChildScrollView(
                child: Column(
                  children: children,
                ),
              ),
            );

            // return ListView.builder(
            //   itemCount: extensions.length,
            //   itemBuilder: (context, index) {
            //     return _buildExtensionItem(
            //         extensions[index], extensionProvider);
            //   },
            // );
          },
        ));
  }
}
