import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:taskmaster/core/services/log_storage_service.dart';

class _FakePathProviderPlatform extends PathProviderPlatform with MockPlatformInterfaceMixin {
  _FakePathProviderPlatform(this.dir);
  final String dir;

  @override
  Future<String?> getApplicationDocumentsPath() async => dir;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('log_storage_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  LogRecord makeRecord(String message, {Level level = Level.INFO, String logger = 'test'}) {
    return LogRecord(level, message, logger);
  }

  group('LogStorageService', () {
    test('initialize creates the log file', () async {
      final service = LogStorageService();
      await service.initialize();

      final path = service.getLogFilePath();
      expect(path, isNotNull);
      expect(File(path!).existsSync(), isTrue);
    });

    test('writeRecord appends formatted log line', () async {
      final service = LogStorageService();
      await service.initialize();
      await service.writeRecord(makeRecord('Hello world'));

      final contents = await service.readLogs();
      expect(contents, contains('Hello world'));
      expect(contents, contains('INFO'));
      expect(contents, contains('test'));
    });

    test('writeRecord includes error and stack trace when present', () async {
      final service = LogStorageService();
      await service.initialize();
      final record = LogRecord(
        Level.SEVERE,
        'Something broke',
        'myLogger',
        Exception('boom'),
        StackTrace.current,
      );
      await service.writeRecord(record);

      final contents = await service.readLogs();
      expect(contents, contains('Something broke'));
      expect(contents, contains('SEVERE'));
      expect(contents, contains('error=Exception: boom'));
    });

    test('multiple records accumulate in the file', () async {
      final service = LogStorageService();
      await service.initialize();
      await service.writeRecord(makeRecord('first'));
      await service.writeRecord(makeRecord('second'));
      await service.writeRecord(makeRecord('third'));

      final contents = await service.readLogs();
      expect(contents, contains('first'));
      expect(contents, contains('second'));
      expect(contents, contains('third'));
      // 3 lines (plus trailing newline)
      expect(contents.split('\n').where((l) => l.isNotEmpty).length, 3);
    });

    test('clearLogs empties the file', () async {
      final service = LogStorageService();
      await service.initialize();
      await service.writeRecord(makeRecord('will be cleared'));
      await service.clearLogs();

      final contents = await service.readLogs();
      expect(contents, isEmpty);
    });

    test('readLogs returns empty string when file has no content', () async {
      final service = LogStorageService();
      await service.initialize();

      final contents = await service.readLogs();
      expect(contents, isEmpty);
    });

    test('getLogFilePath returns null before initialize', () {
      final service = LogStorageService();
      expect(service.getLogFilePath(), isNull);
    });
  });
}
