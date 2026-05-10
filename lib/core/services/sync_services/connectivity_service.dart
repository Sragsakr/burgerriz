import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kiosk_point_of_sale/core/sdks/sdk_logic/led_status_manager.dart';

/// A singleton service that manages connectivity status using a broadcast stream
/// This ensures the stream remains active across navigation and multiple listeners
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult>? _lastResult;
  bool _isInitialized = false;
  int _listenerCount = 0;

  /// Initialize the connectivity service
  void initialize() {
    print('🔧 ConnectivityService: initialize() called');

    if (_subscription != null) {
      print('⚠️ ConnectivityService: Already initialized, skipping...');
      return;
    }

    print('🚀 ConnectivityService: Starting connectivity monitoring...');

    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        print('📡 ConnectivityService: Connectivity changed to: $results');
        _lastResult = results;
        _controller.add(results);
        LEDStatusManager.instance.onChangeNetwork();
        print(
            '📤 ConnectivityService: Broadcasted to ${_listenerCount} listeners');
      },
      onError: (error) {
        print('❌ ConnectivityService: Stream error: $error');
      },
      onDone: () {
        print('✅ ConnectivityService: Stream completed');
      },
    );

    _isInitialized = true;
    print('✅ ConnectivityService: Initialization complete');
  }

  /// Get the current connectivity status
  Future<List<ConnectivityResult>> getCurrentStatus() async {
    print('🔍 ConnectivityService: Getting current status...');
    try {
      final status = await _connectivity.checkConnectivity();
      print('📊 ConnectivityService: Current status: $status');
      return status;
    } catch (e) {
      print('❌ ConnectivityService: Error getting current status: $e');
      rethrow;
    }
  }

  /// Get the last known connectivity result
  List<ConnectivityResult>? get lastResult {
    print('📋 ConnectivityService: Last result requested: $_lastResult');
    return _lastResult;
  }

  /// Stream that broadcasts connectivity changes
  /// This is a broadcast stream, so multiple listeners can subscribe safely
  Stream<List<ConnectivityResult>> get connectivityStream {
    print(
        '📡 ConnectivityService: Stream accessed, listener count: ${_listenerCount + 1}');
    _listenerCount++;

    return _controller.stream.map((results) {
      print('📨 ConnectivityService: Stream data sent to listener: $results');
      return results;
    }).handleError((error) {
      print('❌ ConnectivityService: Stream listener error: $error');
    });
  }

  /// Check if device is currently connected to internet
  bool get isConnected {
    if (_lastResult == null || _lastResult!.isEmpty) {
      print('🔌 ConnectivityService: No connection data available');
      return false;
    }

    final connected = !_lastResult!.contains(ConnectivityResult.none);
    print(
        '🔌 ConnectivityService: Is connected: $connected (from: $_lastResult)');
    return connected;
  }

  /// Get debug information about the service state
  Map<String, dynamic> get debugInfo {
    return {
      'isInitialized': _isInitialized,
      'hasSubscription': _subscription != null,
      'listenerCount': _listenerCount,
      'lastResult': _lastResult,
      'isConnected': isConnected,
      'hasController': _controller.hasListener,
    };
  }

  /// Print debug information
  void printDebugInfo() {
    print('🔍 ConnectivityService Debug Info:');
    print('   - Initialized: $_isInitialized');
    print('   - Has Subscription: ${_subscription != null}');
    print('   - Listener Count: $_listenerCount');
    print('   - Last Result: $_lastResult');
    print('   - Is Connected: $isConnected');
    print('   - Controller Has Listeners: ${_controller.hasListener}');
  }

  /// Dispose the service and clean up resources
  void dispose() {
    print('🧹 ConnectivityService: dispose() called');
    print('📊 ConnectivityService: Final listener count: $_listenerCount');

    _subscription?.cancel();
    _subscription = null;
    _controller.close();
    _isInitialized = false;
    _listenerCount = 0;

    print('✅ ConnectivityService: Disposed successfully');
  }
}
