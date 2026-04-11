import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'log_storage_service.g.dart';

/// Persistent log sink that writes log records to a rolling file.
/// Used for retrieving logs from production iOS devices where console
/// access is not available.
class LogStorageService {
  static const String _logFileName = 'taskmaster.log';
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  File? _logFile;
  bool _initialized = false;

  /// Initializes the log file path. Must be called before writing.
  Future<void> initialize() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File('${dir.path}/$_logFileName');
    if (!await _logFile!.exists()) {
      await _logFile!.create(recursive: true);
    }
    _initialized = true;
  }

  /// Writes a single log record to the file. Rotates if file exceeds max size.
  Future<void> writeRecord(LogRecord record) async {
    if (!_initialized) await initialize();
    final file = _logFile!;

    final line = _formatRecord(record);
    try {
      await file.writeAsString('$line\n', mode: FileMode.append, flush: false);

      // Check size and rotate if needed
      final size = await file.length();
      if (size > _maxFileSizeBytes) {
        await _rotate(file);
      }
    } catch (e) {
      // Don't throw from the log sink — would create an infinite loop
      // ignore: avoid_print
      print('[LogStorageService] Failed to write log: $e');
    }
  }

  String _formatRecord(LogRecord record) {
    final ts = record.time.toIso8601String();
    final level = record.level.name.padRight(7);
    final logger = record.loggerName.isEmpty ? 'root' : record.loggerName;
    var line = '$ts [$level] $logger: ${record.message}';
    if (record.error != null) {
      line += ' | error=${record.error}';
    }
    if (record.stackTrace != null) {
      line += '\n${record.stackTrace}';
    }
    return line;
  }

  /// Truncates the oldest 50% of the file when it exceeds the size limit.
  Future<void> _rotate(File file) async {
    try {
      final contents = await file.readAsString();
      final keepFrom = contents.length ~/ 2;
      // Round up to next newline to keep entries intact
      final newlineIdx = contents.indexOf('\n', keepFrom);
      final truncated = newlineIdx >= 0 ? contents.substring(newlineIdx + 1) : '';
      await file.writeAsString(truncated, flush: true);
    } catch (e) {
      // ignore: avoid_print
      print('[LogStorageService] Failed to rotate log: $e');
    }
  }

  /// Returns the current contents of the log file.
  Future<String> readLogs() async {
    if (!_initialized) await initialize();
    try {
      return await _logFile!.readAsString();
    } catch (_) {
      return '';
    }
  }

  /// Clears the log file.
  Future<void> clearLogs() async {
    if (!_initialized) await initialize();
    try {
      await _logFile!.writeAsString('', flush: true);
    } catch (_) {
      // no-op
    }
  }

  /// Returns the path to the log file (for sharing via share_plus).
  String? getLogFilePath() => _logFile?.path;
}

@Riverpod(keepAlive: true)
LogStorageService logStorageService(Ref ref) => LogStorageService();
