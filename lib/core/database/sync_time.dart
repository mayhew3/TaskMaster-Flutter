/// Helpers for comparing `lastModified` / `lastSyncedRemoteVersion`
/// timestamps under the precision constraints of the TM-342/TM-361/TM-367
/// sync invariants.
///
/// Drift's `dateTime()` columns store values as Unix epoch *seconds*, so
/// any `DateTime` round-tripped through the local DB is truncated to
/// whole-second precision. Firestore `Timestamp`s land with full
/// millisecond precision. Comparing the two directly with `isAfter` can
/// trip on sub-second jitter (the freshly-stamped server value will
/// appear "newer" than the truncated local copy that represents the same
/// write). Always use [isStrictlyAfterAtSecondPrecision] when comparing
/// across the local-vs-server boundary.
library;

/// Returns `true` iff [a] is strictly after [b] when both are floored to
/// whole seconds. Mirrors the comparison shape used by Drift's storage.
bool isStrictlyAfterAtSecondPrecision(DateTime a, DateTime b) {
  final aSec = a.millisecondsSinceEpoch ~/ 1000;
  final bSec = b.millisecondsSinceEpoch ~/ 1000;
  return aSec > bSec;
}
