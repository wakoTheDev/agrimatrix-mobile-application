import 'package:flutter/foundation.dart';

/// Production-ready logging service that respects build modes
/// In debug mode: Logs to console
/// In release mode: Logs can be sent to crash reporting or analytics
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  /// Log informational messages
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('INFO: $prefix$message');
    }
    // In production, you could send to analytics or crash reporting
    // Example: FirebaseCrashlytics.instance.log('INFO: $prefix$message');
  }

  /// Log warning messages
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('WARNING: $prefix$message');
    }
    // In production, you could send to analytics
  }

  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    final prefix = tag != null ? '[$tag] ' : '';
    
    if (kDebugMode) {
      debugPrint('ERROR: $prefix$message');
      if (error != null) debugPrint('Error details: $error');
      if (stackTrace != null) debugPrint('Stack trace: $stackTrace');
    }
    
    // In production, send to crash reporting
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
  }

  /// Log debug messages (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('DEBUG: $prefix$message');
    }
  }

  /// Log network requests
  static void network(String method, String url, [int? statusCode, String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      final status = statusCode != null ? ' ($statusCode)' : '';
      debugPrint('NETWORK: $prefix$method $url$status');
    }
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('PERF: $prefix$operation took ${duration.inMilliseconds}ms');
    }
    // In production, send to performance monitoring
  }
}
