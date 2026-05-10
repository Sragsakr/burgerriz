import 'dart:async';
import 'package:flutter/services.dart';

/// Flutter wrapper for the native USB Kotlin plugin.
/// Listens for method-channel callbacks and exposes them as Dart Streams
/// so the app can react in a purely reactive style.
class UsbPlugin {
  /// Single platform channel (must match Kotlin).
  static const MethodChannel _channel = MethodChannel('usb_plugin');

  // ────────────────────────────────────────────────────────────
  //                   Stream controllers
  // ────────────────────────────────────────────────────────────
  //
  // NOTE: all controllers are broadcast so multiple widgets can listen
  //       without exhausting the single-subscription default stream.

  static final _siSensorUpdateController =
      StreamController<SensorUpdate>.broadcast();
  static final _suSensorUpdateController =
      StreamController<SensorUpdate>.broadcast();
  static final _deviceAttachedController =
      StreamController<DeviceType>.broadcast();
  static final _deviceDetachedController =
      StreamController<DeviceType>.broadcast();
  static final _suPortsUpdateController =
      StreamController<PortsUpdate>.broadcast();
  static final _siPortsUpdateController =
      StreamController<PortsUpdate>.broadcast();
  static final _sensorErrorController =
      StreamController<SensorError>.broadcast();
  static final _permissionGrantedController =
      StreamController<String>.broadcast();
  static final _suPermissionDeniedController =
      StreamController<String>.broadcast();
  static final _siPermissionDeniedController =
      StreamController<String>.broadcast();
  static final _debugDataController = StreamController<String>.broadcast();

  // ────────────────────────────────────────────────────────────
  //                   Public streams
  // ────────────────────────────────────────────────────────────
  //
  // Expose the underlying broadcast streams to the app.

  static Stream<SensorUpdate> get siSensorUpdates =>
      _siSensorUpdateController.stream;

  static Stream<SensorUpdate> get suSensorUpdates =>
      _suSensorUpdateController.stream;

  static Stream<DeviceType> get deviceAttached =>
      _deviceAttachedController.stream;

  static Stream<DeviceType> get deviceDetached =>
      _deviceDetachedController.stream;

  static Stream<PortsUpdate> get siPortsUpdated =>
      _siPortsUpdateController.stream;

  static Stream<PortsUpdate> get suPortsUpdated =>
      _suPortsUpdateController.stream;

  static Stream<SensorError> get sensorErrors => _sensorErrorController.stream;

  static Stream<String> get permissionGranted =>
      _permissionGrantedController.stream;

  static Stream<String> get suPermissionDenied =>
      _suPermissionDeniedController.stream;

  static Stream<String> get siPermissionDenied =>
      _siPermissionDeniedController.stream;

  static Stream<String> get debugData => _debugDataController.stream;

  /// Must be called once (e.g. in main()) before listening to any stream.
  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  // ────────────────────────────────────────────────────────────
  //              Internal method-channel dispatcher
  // ────────────────────────────────────────────────────────────

  static Future<void> _handleMethodCall(MethodCall call) async {
    final method = call.method;
    final args = call.arguments;
    _debugDataController.add('method: $method\narguments: $args\n');

    switch (method) {
      // ── SENSOR UPDATES ──────────────────────────────────────
      case 'onSuSensorUpdate':
        _suSensorUpdateController.add(SensorUpdate.fromMap({
          ...Map<String, dynamic>.from(args),
          'deviceType': 'SU',
        }));
        break;

      case 'onSiSensorUpdate':
        _siSensorUpdateController.add(SensorUpdate.fromMap({
          ...Map<String, dynamic>.from(args),
          'deviceType': 'SI',
        }));
        break;

      // ── SENSOR ERRORS ───────────────────────────────────────
      case 'onSuSensorError':
        _sensorErrorController.add(SensorError.fromMap({
          ...Map<String, dynamic>.from(args),
          'deviceType': 'SU',
        }));
        break;

      case 'onSiSensorError':
        _sensorErrorController.add(SensorError.fromMap({
          ...Map<String, dynamic>.from(args),
          'deviceType': 'SI',
        }));
        break;

      // ── DEVICE HOT-PLUG EVENTS ──────────────────────────────
      case 'onDeviceAttached':
        if (args != null) {
          // Kotlin may send null
          _deviceAttachedController.add(DeviceTypeExtension.fromName(args));
        }
        break;

      case 'onDeviceDetached':
        if (args != null) {
          _deviceDetachedController.add(DeviceTypeExtension.fromName(args));
        }
        break;

      // ── PORT LIST UPDATES ───────────────────────────────────
      case 'onSuPortsUpdated':
        _suPortsUpdateController.add(PortsUpdate.fromMap({
          'ports': List<String>.from(args),
          'deviceType': 'SU',
        }));
        break;

      case 'onSiPortsUpdated':
        _siPortsUpdateController.add(PortsUpdate.fromMap({
          'ports': List<String>.from(args),
          'deviceType': 'SI',
        }));
        break;

      // ── PERMISSION FLOW ─────────────────────────────────────
      case 'onPermissionGranted':
        _permissionGrantedController.add(args as String);
        break;

      case 'onSuPermissionDenied':
        _suPermissionDeniedController.add(args as String);
        break;

      case 'onSiPermissionDenied':
        _siPermissionDeniedController.add(args as String);
        break;

      // ── FALLBACK ────────────────────────────────────────────
      default:
        _debugDataController.add('Unhandled method: $method');
    }
  }

  // ────────────────────────────────────────────────────────────
  //                    Public API wrappers
  // ────────────────────────────────────────────────────────────

  /// Fetch a fresh list of COM/USB ports from native side.
  static Future<List<String>> getPorts(DeviceType type) async {
    final List result = await _channel
        .invokeMethod(type == DeviceType.SU ? 'getSuPorts' : 'getSiPorts');
    return result.cast<String>();
  }

  /// Start continuous sensor polling.
  /// * For SU you may provide an optional IR threshold level.
  static Future<void> startSensor(
    DeviceType type,
    String portName, {
    int irLevel = 1,
  }) async {
    if (type == DeviceType.SU) {
      await _channel.invokeMethod('startSuSensor', {
        'portName': portName,
        'irLevel': irLevel,
      });
    } else {
      await _channel.invokeMethod('startSiSensor', {
        'portName': portName,
      });
    }
  }

  /// Stop polling for the selected device type.
  static Future<void> stopSensor(DeviceType type) async {
    await _channel
        .invokeMethod(type == DeviceType.SU ? 'stopSuSensor' : 'stopSiSensor');
  }

  /// Ask Android for permission to access a specific USB device.
  static Future<bool> requestPermission(String portName) async {
    return await _channel
        .invokeMethod('requestPermission', {'portName': portName});
  }

  // ── SI-specific helper methods (LED, breathing, status …) ──

  static Future<int> closePort(String portName) async =>
      await _channel.invokeMethod('siClosePort', {'portName': portName});

  static Future<int> setLedColor({
    required String portName,
    required int r,
    required int g,
    required int b,
    int seconds = 0,
    int minutes = 0,
    int type = 0,
  }) async =>
      await _channel.invokeMethod('siSetLedColor', {
        'portName': portName,
        'r': r,
        'g': g,
        'b': b,
        'seconds': seconds,
        'minutes': minutes,
        'type': type,
      });

  static Future<int> setFlash(String portName) async =>
      await _channel.invokeMethod('siSetFlash', {'portName': portName});

  static Future<int> setSmooth(String portName) async =>
      await _channel.invokeMethod('siSetSmooth', {'portName': portName});

  static Future<int> setStop(String portName) async =>
      await _channel.invokeMethod('siSetStop', {'portName': portName});

  static Future<List<int>> getDeviceStatus(String portName) async =>
      (await _channel.invokeMethod('siGetDevStatus', {'portName': portName}))
          .cast<int>();

  static Future<String?> getFirmwareVersion(String portName) => _channel
      .invokeMethod<String>('siGetFirmwareVersion', {'portName': portName});

  static Future<int> setBreathe(String portName, int pattern) async =>
      await _channel.invokeMethod<int>(
          'siSetBreathe', {'portName': portName, 'pattern': pattern}) ??
      -1;

  // ────────────────────────────────────────────────────────────
  //                   Cleanup helpers
  // ────────────────────────────────────────────────────────────
  //
  // Call this when the app shuts down or when hot-reloading the plugin.

  static void dispose() {
    _suSensorUpdateController.close();
    _siSensorUpdateController.close();
    _deviceAttachedController.close();
    _deviceDetachedController.close();
    _suPortsUpdateController.close();
    _siPortsUpdateController.close();
    _sensorErrorController.close();
    _permissionGrantedController.close();
    _suPermissionDeniedController.close();
    _siPermissionDeniedController.close();
    _debugDataController.close();
  }
}

// ──────────────────────────────────────────────────────────────
//                   Model classes & enums
// ──────────────────────────────────────────────────────────────

enum DeviceType { SU, SI }

extension DeviceTypeExtension on DeviceType {
  static DeviceType fromName(String name) =>
      name.toUpperCase() == 'SU' ? DeviceType.SU : DeviceType.SI;
}

/// Object delivered on every sensor tick (value + interpreted status).
class SensorUpdate {
  final int value;
  final SensorStatus status;
  final DeviceType deviceType;

  SensorUpdate({
    required this.value,
    required this.status,
    required this.deviceType,
  });

  factory SensorUpdate.fromMap(Map<String, dynamic> map) => SensorUpdate(
        value: map['value'] as int,
        status: SensorStatusExtension.fromName(map['status']),
        deviceType: DeviceTypeExtension.fromName(map['deviceType']),
      );

  @override
  String toString() =>
      'SensorUpdate(value: $value, status: $status, deviceType: $deviceType)';
}

/// List of available ports for one device family.
class PortsUpdate {
  final List<String> ports;
  final DeviceType deviceType;

  PortsUpdate({required this.ports, required this.deviceType});

  factory PortsUpdate.fromMap(Map<String, dynamic> map) => PortsUpdate(
        ports: List<String>.from(map['ports']),
        deviceType: DeviceTypeExtension.fromName(map['deviceType']),
      );
}

/// Wrapper for any sensor-level error coming from native side.
class SensorError {
  final String message;
  final DeviceType deviceType;

  SensorError({required this.message, required this.deviceType});

  factory SensorError.fromMap(Map<String, dynamic> map) => SensorError(
        message: map['message'],
        deviceType: DeviceTypeExtension.fromName(map['deviceType']),
      );

  @override
  String toString() =>
      'SensorError(message: $message, deviceType: $deviceType)';
}

// ──────────────────────────────────────────────────────────────
//                     Helper extensions
// ──────────────────────────────────────────────────────────────

enum SensorStatus { CLOSE, FAR, UNKNOWN }

extension SensorStatusExtension on SensorStatus {
  static SensorStatus fromName(String name) {
    final upper = name.toUpperCase();
    return SensorStatus.values.firstWhere(
      (e) => e.name == upper,
      orElse: () => SensorStatus.UNKNOWN,
    );
  }
}

class SensorData {
  final int value;
  final SensorStatus status;

  SensorData({
    required this.value,
    required this.status,
  });

  @override
  String toString() => 'SensorData(value: $value, status: $status)';
}