// lib/logger.dart

import 'package:logger/logger.dart';

class Log {
  // Private constructor to prevent multiple instances
  Log._privateConstructor();

  // Singleton instance of the logger
  static final Log _instance = Log._privateConstructor();

  // Create a logger instance
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      printEmojis: false,
      colors: true,
      noBoxingByDefault: true,
    ), // Customize the log format as needed
  );

  // Getter to access the singleton logger instance
  static Log get instance => _instance;

  // Add methods to log messages with different levels

  void v(String message) => _logger.v(message);

  void d(String message) => _logger.d(message);

  void i(String message) => _logger.i(message);

  void w(String message) => _logger.w(message);

  void e(String message) => _logger.e(message);
}

