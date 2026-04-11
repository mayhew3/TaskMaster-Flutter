import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Thin wrapper over `connectivity_plus` so tests can inject a fake.
class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<bool> get onlineStream =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  Future<bool> currentOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  static bool _isOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }
}

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) => ConnectivityService();

/// Stream of `online: bool`. Emits the current state immediately, then
/// updates whenever connectivity changes.
@Riverpod(keepAlive: true)
Stream<bool> connectivity(Ref ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield await service.currentOnline();
  yield* service.onlineStream;
}
