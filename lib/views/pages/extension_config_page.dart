import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class ExtensionConfigPage extends StatefulWidget {
  final String extensionName;
  const ExtensionConfigPage({super.key, required this.extensionName});

  @override
  State<ExtensionConfigPage> createState() => _ExtensionConfigPageState();
}

class _ExtensionConfigPageState extends State<ExtensionConfigPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.config),
        ],
      ),
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.config),
      ),
    );
  }
}
