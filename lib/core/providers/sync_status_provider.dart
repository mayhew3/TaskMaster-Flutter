import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status_provider.g.dart';

enum SyncStatus { idle, syncing, error }

@Riverpod(keepAlive: true)
class SyncStatusController extends _$SyncStatusController {
  @override
  SyncStatus build() => SyncStatus.idle;

  void set(SyncStatus status) => state = status;
}
