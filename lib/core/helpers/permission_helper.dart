import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkDeviceRequirements() async {
  // 1️⃣ Check Phone State Permission
  var phoneStateStatus = await Permission.phone.status;
  if (!phoneStateStatus.isGranted) {
    phoneStateStatus = await Permission.phone.request();
    if (!phoneStateStatus.isGranted) return false;
  }

  // 2️⃣ Check Location Enabled
  bool locationEnabled = await Geolocator.isLocationServiceEnabled();
  if (!locationEnabled) return false;

  // 3️⃣ Check NFC Enabled
  NFCAvailability nfcStatus = await FlutterNfcKit.nfcAvailability;
  if (nfcStatus != NFCAvailability.available) return false;

  // All checks passed
  return true;
}
/// Permission request result model
class PermissionResult {
  final bool allGranted;
  final List<Permission> grantedPermissions;
  final List<Permission> deniedPermissions;
  final List<Permission> permanentlyDeniedPermissions;
  final String? errorMessage;

  PermissionResult({
    required this.allGranted,
    required this.grantedPermissions,
    required this.deniedPermissions,
    required this.permanentlyDeniedPermissions,
    this.errorMessage,
  });
}

/// Request all permissions declared in AndroidManifest.xml
/// Returns detailed information about which permissions were granted/denied
Future<PermissionResult> requestAllAppPermissions() async {
  try {
    // Define permissions based on AndroidManifest.xml declarations
    final List<Permission> requiredPermissions = [
      // Bluetooth permissions (from AndroidManifest.xml)
      Permission.bluetooth, // android.permission.BLUETOOTH
      Permission.bluetoothScan, // android.permission.BLUETOOTH_SCAN
      Permission.bluetoothConnect, // android.permission.BLUETOOTH_CONNECT
      Permission.bluetoothAdvertise, // android.permission.BLUETOOTH_ADMIN
      
      // Location permissions (from AndroidManifest.xml)
      Permission.location, // android.permission.ACCESS_FINE_LOCATION & ACCESS_COARSE_LOCATION
      
      // Storage permissions (from AndroidManifest.xml)
      Permission.storage, // android.permission.WRITE_EXTERNAL_STORAGE & READ_EXTERNAL_STORAGE
      
      // Body sensors (from AndroidManifest.xml)
      Permission.sensors, // android.permission.BODY_SENSORS
    ];

    // Use all permissions (permission_handler handles platform compatibility)
    final List<Permission> availablePermissions = requiredPermissions;

    if (kDebugMode) {
      print('Requesting ${availablePermissions.length} permissions...');
    }

    // Request all permissions at once
    final Map<Permission, PermissionStatus> statuses = 
        await availablePermissions.request();

    // Categorize results
    final List<Permission> grantedPermissions = [];
    final List<Permission> deniedPermissions = [];
    final List<Permission> permanentlyDeniedPermissions = [];

    statuses.forEach((permission, status) {
      switch (status) {
        case PermissionStatus.granted:
          grantedPermissions.add(permission);
          break;
        case PermissionStatus.denied:
          deniedPermissions.add(permission);
          break;
        case PermissionStatus.permanentlyDenied:
          permanentlyDeniedPermissions.add(permission);
          break;
        case PermissionStatus.restricted:
          deniedPermissions.add(permission);
          break;
        case PermissionStatus.limited:
          grantedPermissions.add(permission);
          break;
        case PermissionStatus.provisional:
          grantedPermissions.add(permission);
          break;
      }
    });

    final bool allGranted = deniedPermissions.isEmpty && 
                           permanentlyDeniedPermissions.isEmpty;

    if (kDebugMode) {
      print('Permission Results:');
      print('Granted: ${grantedPermissions.length}');
      print('Denied: ${deniedPermissions.length}');
      print('Permanently Denied: ${permanentlyDeniedPermissions.length}');
    }

    return PermissionResult(
      allGranted: allGranted,
      grantedPermissions: grantedPermissions,
      deniedPermissions: deniedPermissions,
      permanentlyDeniedPermissions: permanentlyDeniedPermissions,
    );

  } catch (e) {
    if (kDebugMode) {
      print('Error requesting permissions: $e');
    }
    
    return PermissionResult(
      allGranted: false,
      grantedPermissions: [],
      deniedPermissions: [],
      permanentlyDeniedPermissions: [],
      errorMessage: e.toString(),
    );
  }
}

/// Request only essential permissions for basic app functionality
/// Based on the most critical permissions from AndroidManifest.xml
Future<PermissionResult> requestEssentialPermissions() async {
  try {
    // Essential permissions for basic app functionality (from AndroidManifest.xml)
    final List<Permission> essentialPermissions = [
      Permission.bluetooth, // android.permission.BLUETOOTH
      Permission.bluetoothScan, // android.permission.BLUETOOTH_SCAN
      Permission.bluetoothConnect, // android.permission.BLUETOOTH_CONNECT
      Permission.location, // android.permission.ACCESS_FINE_LOCATION & ACCESS_COARSE_LOCATION
      Permission.storage, // android.permission.WRITE_EXTERNAL_STORAGE & READ_EXTERNAL_STORAGE
    ];

    // Use all essential permissions (permission_handler handles platform compatibility)
    final List<Permission> availablePermissions = essentialPermissions;

    // Request permissions
    final Map<Permission, PermissionStatus> statuses = 
        await availablePermissions.request();

    // Categorize results
    final List<Permission> grantedPermissions = [];
    final List<Permission> deniedPermissions = [];
    final List<Permission> permanentlyDeniedPermissions = [];

    statuses.forEach((permission, status) {
      switch (status) {
        case PermissionStatus.granted:
        case PermissionStatus.limited:
        case PermissionStatus.provisional:
          grantedPermissions.add(permission);
          break;
        case PermissionStatus.denied:
        case PermissionStatus.restricted:
          deniedPermissions.add(permission);
          break;
        case PermissionStatus.permanentlyDenied:
          permanentlyDeniedPermissions.add(permission);
          break;
      }
    });

    final bool allGranted = deniedPermissions.isEmpty && 
                           permanentlyDeniedPermissions.isEmpty;

    return PermissionResult(
      allGranted: allGranted,
      grantedPermissions: grantedPermissions,
      deniedPermissions: deniedPermissions,
      permanentlyDeniedPermissions: permanentlyDeniedPermissions,
    );

  } catch (e) {
    return PermissionResult(
      allGranted: false,
      grantedPermissions: [],
      deniedPermissions: [],
      permanentlyDeniedPermissions: [],
      errorMessage: e.toString(),
    );
  }
}

/// Check if specific permission is granted
Future<bool> isPermissionGranted(Permission permission) async {
  final status = await permission.status;
  return status == PermissionStatus.granted || 
         status == PermissionStatus.limited ||
         status == PermissionStatus.provisional;
}

/// Open app settings for permission management
Future<void> openAppSettings() async {
  await openAppSettings();
}

/// Example usage function showing how to use the permission helper
Future<void> exampleUsage() async {
  // Request all permissions from AndroidManifest.xml
  final PermissionResult result = await requestAllAppPermissions();
  
  if (result.allGranted) {
    print('All permissions granted successfully!');
  } else {
    print('Some permissions were denied:');
    print('Denied: ${result.deniedPermissions.length}');
    print('Permanently denied: ${result.permanentlyDeniedPermissions.length}');
    
      // Handle denied permissions
    if (result.permanentlyDeniedPermissions.isNotEmpty) {
      print('Some permissions are permanently denied. Opening app settings...');
      await openAppSettings();
    }
    }
  }

/// Legacy function for backward compatibility
Future<bool> requestBluetoothAndLocationPermissions() async {
  final result = await requestEssentialPermissions();
  return result.allGranted;
}
