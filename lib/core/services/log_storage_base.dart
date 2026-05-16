import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Pick the platform implementation at compile time. The default
// (io) file transitively imports `dart:io` via LogStorageService and
// must NEVER reach the web graph; on web `dart.library.js_interop`
// swaps in the dart:io-free no-op. `export` so callers (main.dart)
// get `createLogStorage()` from this single web-safe entry point.
import 'log_storage_factory_io.dart'
    if (dart.library.js_interop) 'log_storage_factory_web.dart';
export 'log_storage_factory_io.dart'
    if (dart.library.js_interop) 'log_storage_factory_web.dart';

part 'log_storage_base.g.dart';

/// Platform-agnostic log sink surface. The native implementation
/// ([LogStorageService]) writes a rolling file via `dart:io` +
/// `path_provider`; the web build uses a no-op (no filesystem on web).
abstract class LogStorageBase {
  Future<void> initialize();
  Future<void> writeRecord(LogRecord record);
  Future<void> writeRaw(String line);
  Future<String> readLogs();
  Future<void> clearLogs();
  String? getLogFilePath();
}

@Riverpod(keepAlive: true)
LogStorageBase logStorageService(Ref ref) => createLogStorage();
