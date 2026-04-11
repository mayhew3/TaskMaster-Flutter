import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/providers/connectivity_provider.dart';

/// Fake ConnectivityService that lets tests push connectivity states.
class FakeConnectivityService extends ConnectivityService {
  final _controller =
      StreamController<bool>.broadcast();
  bool _current;

  FakeConnectivityService({bool initial = true}) : _current = initial;

  @override
  Stream<bool> get onlineStream => _controller.stream;

  @override
  Future<bool> currentOnline() async => _current;

  void emit(bool online) {
    _current = online;
    _controller.add(online);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  group('ConnectivityService._isOnline', () {
    test('returns false for empty list', () {
      expect(ConnectivityService.isOnlineFromResults([]), isFalse);
    });

    test('returns false when all results are none', () {
      expect(
        ConnectivityService.isOnlineFromResults([ConnectivityResult.none]),
        isFalse,
      );
    });

    test('returns true when wifi is present', () {
      expect(
        ConnectivityService.isOnlineFromResults([ConnectivityResult.wifi]),
        isTrue,
      );
    });

    test('returns true when mobile is present alongside none', () {
      expect(
        ConnectivityService.isOnlineFromResults(
            [ConnectivityResult.mobile, ConnectivityResult.none]),
        isTrue,
      );
    });
  });

  group('connectivityProvider stream', () {
    test('emits current state immediately', () async {
      final fake = FakeConnectivityService(initial: false);
      final container = ProviderContainer(overrides: [
        connectivityServiceProvider.overrideWithValue(fake),
      ]);
      addTearDown(container.dispose);

      final values = <bool>[];
      final sub = container
          .listen<AsyncValue<bool>>(connectivityProvider, (_, next) {
        if (next.hasValue) values.add(next.value!);
      }, fireImmediately: true);
      addTearDown(sub.close);

      // Allow async generator to yield first value.
      await Future.microtask(() {});
      await Future.delayed(Duration.zero);
      expect(values, isNotEmpty);
      expect(values.first, isFalse);
    });

    test('emits true when connectivity comes back', () async {
      final fake = FakeConnectivityService(initial: false);
      final container = ProviderContainer(overrides: [
        connectivityServiceProvider.overrideWithValue(fake),
      ]);
      addTearDown(container.dispose);

      final values = <bool>[];
      final sub = container
          .listen<AsyncValue<bool>>(connectivityProvider, (_, next) {
        if (next.hasValue) values.add(next.value!);
      }, fireImmediately: true);
      addTearDown(sub.close);

      await Future.delayed(Duration.zero);
      fake.emit(true);
      await Future.delayed(Duration.zero);

      expect(values, contains(true));
    });
  });
}
