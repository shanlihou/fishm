// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get favorite => 'Favorite';

  @override
  String get history => 'History';

  @override
  String get extensions => 'Extensions';

  @override
  String get explore => 'Explore';

  @override
  String get search => 'Search';

  @override
  String get my => 'My';

  @override
  String get general => 'General';

  @override
  String get sources => 'Sources';

  @override
  String get about => 'About';

  @override
  String get debug => 'Debug';

  @override
  String get network => 'Network';

  @override
  String get language => 'Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get installed => 'Installed';

  @override
  String get store => 'Store';

  @override
  String get config => 'Config';

  @override
  String get proxy => 'Proxy';

  @override
  String get enable => 'Enable';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get baseline => 'I have a bottom line';

  @override
  String get findMore => 'Find more comics';

  @override
  String get update => 'Update';

  @override
  String get install => 'Install';

  @override
  String get import => 'Import';

  @override
  String get importDesc => 'Import comics from local files';

  @override
  String stepX(int step) {
    return 'Step $step';
  }

  @override
  String get step1 => 'Please put the comic folder in below directory';

  @override
  String get copyPath => 'Copy path';

  @override
  String step2(String tab) {
    return 'Read in $tab tab';
  }

  @override
  String get step2Prefix => 'Read in';

  @override
  String get step2Suffix => 'tab';

  @override
  String get bookshelf => 'Bookshelf';

  @override
  String get local => 'Local';

  @override
  String get sourceComment => 'The following are added sources';

  @override
  String get networkManager => 'Network manager';

  @override
  String get clear => 'Clear';

  @override
  String get aboutKernal => 'Plugin kernel version';

  @override
  String get reset => 'Reset';

  @override
  String get landscape => 'Landscape';

  @override
  String get portrait => 'Portrait';

  @override
  String get exist => 'Exist';

  @override
  String get sourceUrl => 'Source url';

  @override
  String get copy => 'Copy';

  @override
  String get contactUs => 'Contact us';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get fishmVersion => 'fishm version';

  @override
  String get resetSuccess => 'Reset success';

  @override
  String get resetFailed => 'Reset failed';

  @override
  String get delete => 'Delete';

  @override
  String get selectAll => 'Select All';

  @override
  String get nameOfComic => 'Comic name';

  @override
  String get download => 'Download';

  @override
  String get findMoreExtension => 'Find more extensions';

  @override
  String get sourceWarning =>
      'Please support the original version, be careful to choose to add the source';

  @override
  String get imageDownloadFailed =>
      'Image download failed, please check the network and exit to retry';
}
