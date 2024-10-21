import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';

class ExtensionConfigPage extends StatefulWidget {
  final String extensionName;
  const ExtensionConfigPage({super.key, required this.extensionName});

  @override
  State<ExtensionConfigPage> createState() => _ExtensionConfigPageState();
}

class _ExtensionConfigPageState extends State<ExtensionConfigPage> {
  final ValueNotifier<List<String>> _configs = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    Log.instance.d('initAsync');
    var ret = await getConfigKeys(widget.extensionName);
    Log.instance.d(ret.toString());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.config),
      ),
      child: ValueListenableBuilder(
          valueListenable: _configs,
          builder: (context, value, child) {
            return ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index) {
                return Text(value[index]);
              },
            );
          }),
    );
  }
}
