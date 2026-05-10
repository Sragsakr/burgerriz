import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/sdks/sdk_logic/usb_plugin.dart';

enum LEDColor {
  red(255, 0, 0),
  green(0, 255, 0),
  orange(255, 165, 0);

  const LEDColor(this.r, this.g, this.b);
  final int r;
  final int g;
  final int b;
}

enum LEDStatus {
  noInternet,
  showFalse,
  showTrue,
  transitioning,
}

class LEDStatusManager {
  static LEDStatusManager? _instance;
  static LEDStatusManager get instance => _instance ??= LEDStatusManager._();

  LEDStatusManager._();

  Timer? _ledTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String? _siPort;
  LEDStatus _currentStatus = LEDStatus.showTrue;
  bool _isNavigating = false;
  bool _showStatus = true;

  // Stream controller for LED status changes
  StreamController<LEDStatus>? _statusController;

  Stream<LEDStatus> get statusStream {
    _statusController ??= StreamController<LEDStatus>.broadcast();
    return _statusController!.stream;
  }

  LEDStatus get currentStatus => _currentStatus;

  /// Initialize the LED status manager
  Future<void> initialize(String? siPort) async {
    _siPort = siPort;

    if (_siPort == null) {
      dPrint('LED Status Manager: No SI port available');
      return;
    }

    // Start connectivity monitoring
    _startConnectivityMonitoring();

    // Start LED status timer
    _startLEDTimer();

    dPrint('LED Status Manager: Initialized with port $_siPort');
  }

  /// Start monitoring internet connectivity
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateLEDStatus();
      },
    );
  }

  /// Start the LED status timer that runs every 5 seconds
  void _startLEDTimer() {
    _ledTimer?.cancel();
    _ledTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateLEDStatus();
    });
  }

  /// Update the show status from sensor data
  void updateShowStatus(bool show) {
    if (_showStatus != show) {
      _showStatus = show;
      dPrint('LED Status Manager: Show status changed to $show');
      _updateLEDStatus();
    }
  }

  void onChangeNetwork() {
    _updateLEDStatus();
  }

  /// Check internet connectivity
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      // Additional check by trying to reach a reliable server
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      dPrint('LED Status Manager: Internet check failed: $e');
      return false;
    }
  }

  /// Update LED status based on current conditions
  Future<void> _updateLEDStatus() async {
    if (_siPort == null) return;

    LEDStatus newStatus;
    LEDColor ledColor;

    // Check internet connectivity first
    final hasInternet = await _hasInternetConnection();

    if (!hasInternet) {
      newStatus = LEDStatus.noInternet;
      ledColor = LEDColor.red;
    } else if (_showStatus) {
      newStatus = LEDStatus.showTrue;
      ledColor = LEDColor.orange;
    } else if (!_showStatus) {
      newStatus = LEDStatus.showFalse;
      ledColor = LEDColor.green;
    } else {
      newStatus = LEDStatus.noInternet;
      ledColor = LEDColor.red;
    }
    // }

    // Only update if status changed
    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController ??= StreamController<LEDStatus>.broadcast();
      if (!_statusController!.isClosed) {
        _statusController!.add(_currentStatus);
      }
      await _setLEDColor(ledColor);
      dPrint(
          'LED Status Manager: Status changed to $_currentStatus, LED set to ${ledColor.name}');
    }
  }

  /// Set LED color on the SI device
  Future<void> _setLEDColor(LEDColor color) async {
    if (_siPort == null) return;

    try {
      // await UsbPlugin.startSensor(DeviceType.SI, _siPort!);
      await UsbPlugin.setLedColor(
        portName: _siPort!,
        r: color.r,
        g: color.g,
        b: color.b,
      );
      dPrint(
          'LED Status Manager: LED set to R:${color.r} G:${color.g} B:${color.b}');
    } catch (e) {
      dPrint('LED Status Manager: Failed to set LED color: $e');
    }
  }

  /// Manually set LED color (for testing or manual control)
  Future<void> setManualLEDColor(LEDColor color) async {
    if (_siPort == null) return;

    try {
      // await UsbPlugin.startSensor(DeviceType.SI, _siPort!);
      await UsbPlugin.setLedColor(
        portName: _siPort!,
        r: color.r,
        g: color.g,
        b: color.b,
      );
      dPrint(
          'LED Status Manager: Manual LED set to R:${color.r} G:${color.g} B:${color.b}');
    } catch (e) {
      dPrint('LED Status Manager: Failed to set manual LED color: $e');
    }
  }

  /// Update SI port (when port changes)
  void updateSIPort(String? siPort) {
    if (_siPort != siPort) {
      _siPort = siPort;
      dPrint('LED Status Manager: SI port updated to $_siPort');
      if (_siPort != null) {
        _updateLEDStatus();
      }
    }
  }

  /// Get current LED status description
  String getStatusDescription() {
    switch (_currentStatus) {
      case LEDStatus.noInternet:
        return 'No Internet Connection (Red)';
      case LEDStatus.showFalse:
        return 'Show False  (Green)';
      case LEDStatus.showTrue:
        return 'Show True  (Orange)';
      case LEDStatus.transitioning:
        return 'Transitioning (Orange)';
    }
  }

  /// Dispose resources
  void dispose() {
    _ledTimer?.cancel();
    _connectivitySubscription?.cancel();
    if (_statusController != null && !_statusController!.isClosed) {
      _statusController!.close();
    }
    _statusController = null;
    dPrint('LED Status Manager: Disposed');
  }
}
