import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

/// TM-361: `await container.read(asyncProvider.future)` hangs to the test
/// timeout under Riverpod 4 + flutter_test for any provider whose build
/// chain reaches a `StreamProvider`. This helper is the workaround: it
/// listens for the first non-loading `AsyncValue` and completes a Future
/// with its value (or error). `container.listen` uses a different code
/// path than `.future` and works correctly.
///
/// Replace
///     final v = await container.read(xxxProvider.future);
/// with
///     final v = await readAsyncValue(container, xxxProvider);
Future<T> readAsyncValue<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
) {
  final completer = Completer<T>();
  late final ProviderSubscription<AsyncValue<T>> sub;
  void handle(AsyncValue<T>? prev, AsyncValue<T> next) {
    if (completer.isCompleted) return;
    // Wait until the value is fresh: not the initial AsyncLoading AND not
    // a refresh-in-flight AsyncLoading(value: stale). Either form sets
    // isLoading=true; only complete once the build has produced a result.
    if (next.isLoading) return;
    if (next.hasError) {
      completer.completeError(next.error!, next.stackTrace);
    } else {
      completer.complete(next.requireValue);
    }
  }

  sub = container.listen<AsyncValue<T>>(provider, handle, fireImmediately: true);
  return completer.future.whenComplete(sub.close);
}
