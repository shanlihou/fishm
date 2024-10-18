import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:provider/provider.dart';

import '../../../types/provider/local_provider.dart';
import '../../../types/provider/setting_provider.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.general),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoButton(
              child: Text(AppLocalizations.of(context)!.language),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    title: Text(AppLocalizations.of(context)!.language),
                    actions: <CupertinoActionSheetAction>[
                      CupertinoActionSheetAction(
                        child: const Text('中文'),
                        onPressed: () {
                          Navigator.pop(context);
                          context
                              .read<LocalProvider>()
                              .setLocale(const Locale('zh'));
                          context.read<SettingProvider>().settings?.language =
                              "zh";
                          context.read<SettingProvider>().saveSettings();
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: const Text('English'),
                        onPressed: () {
                          Navigator.pop(context);
                          context
                              .read<LocalProvider>()
                              .setLocale(const Locale('en'));
                          context.read<SettingProvider>().settings?.language =
                              "en";
                          context.read<SettingProvider>().saveSettings();
                        },
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: Text(AppLocalizations.of(context)!.cancel),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
