import 'package:flutter/cupertino.dart';
import 'package:toonfu/utils/utils_general.dart';

import '../../../api/flutter_call_lua/method.dart';
import '../../../types/manager/actions.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String baseVersion = 'unknown';
  bool isResetting = false;

  @override
  void initState() {
    super.initState();
    _getBaseVersion();
  }

  void _getBaseVersion() async {
    Map<String, dynamic> ret = await getBaseVersion() as Map<String, dynamic>;
    setState(() {
      baseVersion = ret['version'];
    });
  }

  Future<void> onResetPressed() async {
    setState(() {
      isResetting = true;
    });

    resetMainLua();

    setState(() {
      isResetting = false;
    });

    actionsManager.resetMainLua();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('About'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.xmark),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Text('Base version: $baseVersion'),
                CupertinoButton(
                  onPressed: isResetting ? null : onResetPressed,
                  disabledColor: CupertinoColors.quaternarySystemFill,
                  child: Text('reset'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
