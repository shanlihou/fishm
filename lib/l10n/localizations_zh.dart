// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get favorite => '收藏';

  @override
  String get history => '历史';

  @override
  String get extensions => '扩展';

  @override
  String get explore => '浏览';

  @override
  String get search => '搜索';

  @override
  String get my => '我的';

  @override
  String get general => '通用';

  @override
  String get sources => '源';

  @override
  String get about => '关于';

  @override
  String get debug => '调试';

  @override
  String get network => '网络';

  @override
  String get language => '语言';

  @override
  String get cancel => '取消';

  @override
  String get installed => '已安装';

  @override
  String get store => '商店';

  @override
  String get config => '配置';

  @override
  String get proxy => '代理';

  @override
  String get enable => '启用';

  @override
  String get host => '主机';

  @override
  String get port => '端口';

  @override
  String get baseline => '我是有底线的';

  @override
  String get findMore => '发现更多漫画';

  @override
  String get update => '更新';

  @override
  String get install => '安装';

  @override
  String get import => '导入';

  @override
  String get importDesc => '从本地文件导入漫画';

  @override
  String stepX(int step) {
    return '步骤 $step';
  }

  @override
  String get step1 => '请将漫画文件夹放在以下目录';

  @override
  String get copyPath => '复制路径';

  @override
  String step2(String tab) {
    return '到 $tab 页签下阅读。';
  }

  @override
  String get step2Prefix => '到';

  @override
  String get step2Suffix => '页签下阅读';

  @override
  String get bookshelf => '书架';

  @override
  String get local => '本地';

  @override
  String get sourceComment => '以下为添加源';

  @override
  String get networkManager => '网络管理';

  @override
  String get clear => '清除';

  @override
  String get aboutKernal => '插件内核版本';

  @override
  String get reset => '重置';

  @override
  String get landscape => '横屏';

  @override
  String get portrait => '竖屏';

  @override
  String get exist => '已存在';

  @override
  String get sourceUrl => '源地址';

  @override
  String get copy => '复制';

  @override
  String get contactUs => '联系我们';

  @override
  String get copied => '已复制到剪贴板';

  @override
  String get fishmVersion => 'fishm版本';

  @override
  String get resetSuccess => '已重置';

  @override
  String get resetFailed => '重置失败';

  @override
  String get delete => '删除';

  @override
  String get selectAll => '全选';

  @override
  String get nameOfComic => '漫画名称';

  @override
  String get download => '下载';

  @override
  String get findMoreExtension => '发现更多扩展';

  @override
  String get sourceWarning => '请支持正版，谨慎选择添加源';

  @override
  String get imageDownloadFailed => '图片下载失败，请检查网络并退出重试';
}
