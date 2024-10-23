import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../types/manager/global_manager.dart';
import '../../../types/provider/setting_provider.dart';

import 'package:flutter_gen/gen_l10n/localizations.dart';

class NetworkSettings extends StatefulWidget {
  const NetworkSettings({super.key});

  @override
  State<NetworkSettings> createState() => _NetworkSettingsState();
}

class _NetworkSettingsState extends State<NetworkSettings> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final FocusNode _hostFocusNode = FocusNode();
  final FocusNode _portFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _hostFocusNode.addListener(() {
      if (!_hostFocusNode.hasFocus) {
        _saveSettings();
      }
    });

    _portFocusNode.addListener(() {
      if (!_portFocusNode.hasFocus) {
        _saveSettings();
      }
    });
  }

  @override
  void dispose() {
    _hostFocusNode.dispose();
    _portFocusNode.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    var p = context.read<SettingProvider>();
    p.settings!.proxyHost = _hostController.text;
    p.settings!.proxyPort = int.parse(_portController.text);
    p.saveSettings();
    globalManager.resetProxy(p);
  }

  @override
  Widget build(BuildContext context) {
    var p = context.watch<SettingProvider>();
    _hostController.text = p.settings?.proxyHost ?? '';
    _portController.text = p.settings?.proxyPort.toString() ?? '';

    List<Widget> children = [
      CupertinoFormSection(
        header: Text(AppLocalizations.of(context)!.proxy),
        children: [
          CupertinoFormRow(
            prefix: Text(AppLocalizations.of(context)!.enable),
            child: CupertinoSwitch(
              value: p.settings?.enableProxy ?? false,
              onChanged: (value) {
                p.settings?.enableProxy = value;
                globalManager.resetProxy(p);
                p.saveSettings();
              },
            ),
          ),
        ],
      ),
    ];

    if (p.settings?.enableProxy ?? false) {
      children.addAll([
        CupertinoTextFormFieldRow(
          controller: _hostController,
          placeholder: AppLocalizations.of(context)!.host,
          focusNode: _hostFocusNode,
        ),
        CupertinoTextFormFieldRow(
          controller: _portController,
          placeholder: AppLocalizations.of(context)!.port,
          keyboardType: TextInputType.number,
          focusNode: _portFocusNode,
        ),
      ]);
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.network),
      ),
      child: SafeArea(
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
