import 'log_storage_base.dart';
import 'log_storage_web_noop.dart';

/// Web factory — no filesystem on web, so logging is a no-op.
LogStorageBase createLogStorage() => LogStorageWebNoop();
