// lib/logger.dart

import 'package:talker_flutter/talker_flutter.dart';

class Log {
  // Private constructor to prevent multiple instances
  Log._privateConstructor();

  // Singleton instance of the logger
  static final Log _instance = Log._privateConstructor();

  Talker? _talker;

  // Create a logger instance
  Talker get talker {
    if (_talker == null) {
      _talker = TalkerFlutter.init();
    }
    return _talker!;
  }

  // Getter to access the singleton logger instance
  static Log get instance => _instance;

  // Add methods to log messages with different levels

  void v(String message) => talker.verbose(message);

  void d(String message) => talker.debug(message);

  void i(String message) => talker.info(message);

  void w(String message) => talker.warning(message);

  void e(String message) => talker.error(message);
}
