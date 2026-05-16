import 'package:logging/logging.dart';

import 'log_storage_base.dart';

/// Web no-op log sink. There is no `dart:io` filesystem on web, and
/// the file-export feature degrades gracefully (Export Logs early-
/// returns on a null path). Deliberately imports no `dart:io` /
/// `path_provider` so this stays in the web compilation graph.
class LogStorageWebNoop implements LogStorageBase {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> writeRecord(LogRecord record) async {}

  @override
  Future<void> writeRaw(String line) async {}

  @override
  Future<String> readLogs() async => '';

  @override
  Future<void> clearLogs() async {}

  @override
  String? getLogFilePath() => null;
}
