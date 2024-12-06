import '../../types/provider/setting_provider.dart';

class GlobalManager {
  bool enableProxy = false;
  String proxyHost = '';
  int proxyPort = 0;
  bool isLandscape = false;

  void initGlobal(SettingProvider settingProvider) {
    resetProxy(settingProvider);
  }

  void resetProxy(SettingProvider settingProvider) {
    enableProxy = settingProvider.settings?.enableProxy ?? false;
    proxyHost = settingProvider.settings?.proxyHost ?? '';
    proxyPort = settingProvider.settings?.proxyPort ?? 0;
  }
}

final globalManager = GlobalManager();
