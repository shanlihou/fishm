import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';
import '../widget/label_and_edit.dart';

class ExtensionConfigPage extends StatefulWidget {
  final String extensionName;
  const ExtensionConfigPage({super.key, required this.extensionName});

  @override
  State<ExtensionConfigPage> createState() => _ExtensionConfigPageState();
}

class _ExtensionConfigPageState extends State<ExtensionConfigPage> {
  final ValueNotifier<List<(String, String)>> _configs = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    Log.instance.d('initAsync');
    var ret = await getConfigKeys(widget.extensionName);
    Map<String, dynamic> configMap = ret as Map<String, dynamic>;

    List<(String, String)> configs = [];
    var keys = configMap['keys'];
    var values = configMap['values'];
    if (keys is List && values is List) {
      for (var i = 0; i < keys.length; i++) {
        configs.add((keys[i], values[i]));
      }
    }

    _configs.value = configs;
    Log.instance.d(ret.toString());
  }

  Widget _buildConfigItem(String key, String value, bool isFirst) {
    return LabelAndEdit(
      label: key,
      initialValue: value,
      onChanged: (value) {
        if (value != '') {
          setConfigs(widget.extensionName, {key: value});
        }
      },
      isFirst: isFirst,
    );
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
                return _buildConfigItem(
                    value[index].$1, value[index].$2, index == 0);
              },
            );
          }),
    );
  }
}
