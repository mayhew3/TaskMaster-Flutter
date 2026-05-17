import 'log_storage_base.dart';
import 'log_storage_service.dart';

/// Native factory — real file-backed log storage (`dart:io`).
LogStorageBase createLogStorage() => LogStorageService();
