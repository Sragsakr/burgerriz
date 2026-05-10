import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _measurements = {};

  /// Start timing a process
  void startTimer(String processName) {
    _timers[processName] = Stopwatch()..start();
    dPrint("⏱️ Started timing: $processName");
  }

  /// End timing and log the duration
  Duration endTimer(String processName) {
    final timer = _timers[processName];
    if (timer == null) {
      dPrint("⚠️ No timer found for: $processName");
      return Duration.zero;
    }

    timer.stop();
    final duration = timer.elapsed;

    // Store measurement for averaging
    _measurements.putIfAbsent(processName, () => []).add(duration);

    // Log performance
    dPrint("⏱️ $processName completed in: ${duration.inMilliseconds}ms");

    // Clean up timer
    _timers.remove(processName);

    return duration;
  }

  /// Get average duration for a process
  Duration getAverageDuration(String processName) {
    final measurements = _measurements[processName];
    if (measurements == null || measurements.isEmpty) {
      return Duration.zero;
    }

    final totalMicroseconds = measurements
        .map((duration) => duration.inMicroseconds)
        .reduce((a, b) => a + b);

    return Duration(microseconds: totalMicroseconds ~/ measurements.length);
  }

  /// Get performance summary
  Map<String, Duration> getPerformanceSummary() {
    final summary = <String, Duration>{};
    for (final processName in _measurements.keys) {
      summary[processName] = getAverageDuration(processName);
    }
    return summary;
  }

  /// Clear all measurements
  void clearMeasurements() {
    _measurements.clear();
    _timers.clear();
  }

  /// Check if a process is taking too long
  bool isProcessSlow(String processName, {Duration? threshold}) {
    final avgDuration = getAverageDuration(processName);
    final thresholdDuration = threshold ?? const Duration(seconds: 5);
    return avgDuration > thresholdDuration;
  }

  /// Get optimization suggestions
  List<String> getOptimizationSuggestions() {
    final suggestions = <String>[];
    final summary = getPerformanceSummary();

    for (final entry in summary.entries) {
      final processName = entry.key;
      final avgDuration = entry.value;

      if (avgDuration > const Duration(seconds: 3)) {
        suggestions.add(
            "$processName is slow (${avgDuration.inMilliseconds}ms avg) - consider optimization");
      }
    }

    return suggestions;
  }
}

// Global instance
final performanceMonitor = PerformanceMonitor();
