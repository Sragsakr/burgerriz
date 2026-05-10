import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class KioskManagementService {
  static final KioskManagementService _instance =
      KioskManagementService._internal();
  factory KioskManagementService() => _instance;
  KioskManagementService._internal();

  bool _isKioskModeActive = false;

  // Get current kiosk mode status
  bool get isKioskModeActive => _isKioskModeActive;

  // Initialize kiosk mode
  Future<void> initializeKioskMode() async {
    try {
      dPrint('Kiosk management service initialized');
    } catch (e) {
      dPrint('Error initializing kiosk mode: $e');
    }
  }

  // Start kiosk mode
  Future<bool> startKiosk() async {
    try {
      dPrint('Starting kiosk mode...');

      // Start kiosk mode using the package
      final didStart = await startKioskMode();

      if (didStart) {
        _isKioskModeActive = true;
        dPrint('Kiosk mode started successfully');
        return true;
      } else {
        dPrint('Failed to start kiosk mode');
        return false;
      }
    } catch (e) {
      dPrint('Error starting kiosk mode: $e');
      return false;
    }
  }

  // Stop kiosk mode
  Future<bool> stopKiosk() async {
    try {
      dPrint('Stopping kiosk mode...');

      // Stop kiosk mode using the package
      final didStop = await stopKioskMode();

      if (didStop != false) {
        _isKioskModeActive = false;
        dPrint('Kiosk mode stopped successfully');
        return true;
      } else {
        dPrint('Failed to stop kiosk mode');
        return false;
      }
    } catch (e) {
      dPrint('Error stopping kiosk mode: $e');
      return false;
    }
  }

  // Check if kiosk mode is managed
  Future<bool> isKioskManaged() async {
    try {
      return await isManagedKiosk();
    } catch (e) {
      dPrint('Error checking if kiosk is managed: $e');
      return false;
    }
  }

  // Get current kiosk mode
  Future<KioskMode?> getCurrentKioskMode() async {
    try {
      return await getKioskMode();
    } catch (e) {
      dPrint('Error getting current kiosk mode: $e');
      return null;
    }
  }

  // Validate exit password (placeholder - you can implement custom logic)
  Future<bool> validateExitPassword(String password) async {
    // For now, return true for any non-empty password
    // You can implement custom validation logic here
    return password.isNotEmpty;
  }

  // Get current kiosk status
  Map<String, dynamic> getKioskStatus() {
    return {
      'isEnabled': _isKioskModeActive,
    };
  }

  // Handle kiosk start response
  void handleKioskStart(bool didStart, BuildContext context) {
    if (!didStart && Platform.isIOS) {
      _showSnackBar(context,
          'Single App mode is supported only for devices that are supervised using Mobile Device Management (MDM) and the app itself must be enabled for this mode by MDM.');
    } else if (didStart) {
      _showSnackBar(context, 'Kiosk mode enabled successfully');
    }
  }

  // Handle kiosk stop response
  void handleKioskStop(bool? didStop, BuildContext context) {
    if (didStop == false) {
      _showSnackBar(context,
          'Kiosk mode could not be stopped or was not active to begin with.');
    } else if (didStop == true) {
      _showSnackBar(context, 'Kiosk mode disabled successfully');
    }
  }

  // Show snackbar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
