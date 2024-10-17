import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../types/provider/extension_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    var extensions = context.watch<ExtensionProvider>().extensions;
    return ListView.builder(
        itemCount: extensions.length,
        itemBuilder: (context, index) {
          return Text(extensions[index].name);
        });
  }
}
