import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:taskmaestro/core/services/log_storage_base.dart';
import 'package:taskmaestro/core/services/log_storage_web_noop.dart';

void main() {
  group('LogStorageWebNoop', () {
    late LogStorageBase storage;

    setUp(() => storage = LogStorageWebNoop());

    test('is a LogStorageBase', () {
      expect(storage, isA<LogStorageBase>());
    });

    test('getLogFilePath returns null (no filesystem on web)', () {
      expect(storage.getLogFilePath(), isNull);
    });

    test('readLogs returns empty string', () async {
      expect(await storage.readLogs(), '');
    });

    test('write/clear methods complete without throwing', () async {
      await expectLater(storage.initialize(), completes);
      await expectLater(
        storage.writeRecord(
            LogRecord(Level.INFO, 'msg', 'logger')),
        completes,
      );
      await expectLater(storage.writeRaw('raw line'), completes);
      await expectLater(storage.clearLogs(), completes);
    });
  });
}
