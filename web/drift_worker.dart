// Drift web worker entrypoint (TM-353). Standard drift setup: this is
// compiled to web/drift_worker.js, which app_database._openConnection()
// references via DriftWebOptions. Kept in source so the worker is
// regenerated from the project's resolved drift version (no version
// drift vs a downloaded prebuilt binary).
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
