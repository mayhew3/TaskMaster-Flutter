/// Simple performance logger for measuring operation timing
class PerformanceLogger {
  final String operationName;
  final DateTime _startTime;
  DateTime _lastCheckpoint;

  DateTime get _now => DateTime.now();

  PerformanceLogger._internal(this.operationName, this._startTime)
      : _lastCheckpoint = _startTime;

  /// Start a new performance measurement
  static PerformanceLogger start(String operationName) {
    final logger = PerformanceLogger._internal(operationName, DateTime.now());
    print('⏱️ [$operationName] Started at ${logger._formatTime(logger._startTime)}');
    return logger;
  }

  /// Log a checkpoint with elapsed time since start and since last checkpoint
  void checkpoint(String stepName) {
    final now = _now;
    final totalMs = now.difference(_startTime).inMilliseconds;
    final stepMs = now.difference(_lastCheckpoint).inMilliseconds;
    _lastCheckpoint = now;
    print('⏱️ [$operationName] $stepName: ${stepMs}ms (total: ${totalMs}ms)');
  }

  /// Log completion with total elapsed time
  void finish([String? message]) {
    final now = _now;
    final totalMs = now.difference(_startTime).inMilliseconds;
    final stepMs = now.difference(_lastCheckpoint).inMilliseconds;
    final msg = message ?? 'Completed';
    print('⏱️ [$operationName] $msg: ${stepMs}ms (TOTAL: ${totalMs}ms)');
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }
}
