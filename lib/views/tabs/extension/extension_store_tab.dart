import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../types/provider/extension_provider.dart';

class ExtensionStoreTab extends StatefulWidget {
  const ExtensionStoreTab({super.key});

  @override
  State<ExtensionStoreTab> createState() => _ExtensionStoreTabState();
}

class _ExtensionStoreTabState extends State<ExtensionStoreTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var extensions = context.watch<ExtensionProvider>().extensions;
    return EasyRefresh(
        child: ListView.builder(
            itemCount: extensions.length,
            itemBuilder: (context, index) {
              return Text(extensions[index].name);
            }));
  }
}
