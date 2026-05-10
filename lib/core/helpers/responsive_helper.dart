import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Screen size breakpoints in logical pixels
  // Assuming 96 DPI (standard for most devices)
  // 1 inch = 96 logical pixels
  static const double _mobileMaxWidth = 10 * 96; // 10 inches = 960px
  static const double _tabletMaxWidth = 12 * 96; // 12 inches = 1152px
  static const double _kioskMinWidth = 12 * 96; // 12 inches = 1152px
  
  // Target Android kiosk resolution for 30-inch portrait display
  static const double TARGET_KIOSK_WIDTH = 1366.0; // Target width in pixels (portrait mode)
  static const double TARGET_KIOSK_HEIGHT = 768.0; // Target height in pixels (portrait mode)
  static const double TARGET_KIOSK_SIZE_INCHES = 30.0; // Target diagonal size in inches

  /// Convert logical pixels to inches
  static double pixelsToInches(double pixels) {
    return pixels / 96.0; // Assuming 96 DPI
  }

  /// Convert inches to logical pixels
  static double inchesToPixels(double inches) {
    return inches * 96.0; // Assuming 96 DPI
  }

  /// Get screen width in inches
  static double getScreenWidthInInches(BuildContext context) {
    // dPrint("Screen inchs: ${pixelsToInches(MediaQuery.sizeOf(context).width)}");
    return pixelsToInches(MediaQuery.sizeOf(context).width);
  }

  /// Get screen height in inches
  static double getScreenHeightInInches(BuildContext context) {
    return pixelsToInches(MediaQuery.sizeOf(context).height);
  }

  /// Check if device is mobile (0-10 inches)
  static bool isMobile(BuildContext context) {
    // if(kDebugMode) return false;
    double screenWidthInches = getScreenWidthInInches(context);
    return screenWidthInches >= 0 && screenWidthInches < 10;
  }

  /// Check if device is tablet (10-12 inches)
  static bool isTablet(BuildContext context) {
    // if(kDebugMode) return false;

    double screenWidthInches = getScreenWidthInInches(context);
    return screenWidthInches >= 10 && screenWidthInches < 12;
  }

  /// Check if device is kiosk (12-32 inches)
  static bool isKiosk(BuildContext context) {
    if (kDebugMode) return true;

    double screenWidthInches = getScreenWidthInInches(context);
    return screenWidthInches >= 12 && screenWidthInches <= 32;
  }

  /// Check if device is large tablet (12+ inches)
  static bool isLargeTablet(BuildContext context) {
    double screenWidthInches = getScreenWidthInInches(context);
    return screenWidthInches >= 12;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height;
  }

  /// Get device type as string
  static String getDeviceType(BuildContext context) {
    if (isMobile(context)) {
      return 'Mobile';
    } else if (isTablet(context)) {
      return 'Tablet';
    } else if (isKiosk(context)) {
      return 'Kiosk';
    } else {
      return 'Unknown';
    }
  }

  /// Get screen size category
  static String getScreenSizeCategory(BuildContext context) {
    double widthInches = getScreenWidthInInches(context);
    if (widthInches < 10) {
      return 'Small (${widthInches.toStringAsFixed(1)}")';
    } else if (widthInches < 12) {
      return 'Medium (${widthInches.toStringAsFixed(1)}")';
    } else {
      return 'Large (${widthInches.toStringAsFixed(1)}")';
    }
  }

  /// Check if device is small screen (mobile)
  static bool isSmallScreen(BuildContext context) {
    return isMobile(context);
  }

  /// Check if device is medium screen (tablet)
  static bool isMediumScreen(BuildContext context) {
    return isTablet(context);
  }

  /// Check if device is large screen (kiosk)
  static bool isLargeScreen(BuildContext context) {
    return isKiosk(context);
  }

  /// Get responsive padding based on device type
  static double getResponsivePadding(BuildContext context) {
    double screenWidthInches = getScreenWidthInInches(context);

    if (isMobile(context)) {
      // Mobile: 0-10 inches - compact padding
      if (screenWidthInches < 5) {
        return 8.0; // Very small screens
      } else if (screenWidthInches < 7) {
        return 12.0; // Small screens
      } else {
        return 16.0; // Standard mobile
      }
    } else if (isTablet(context)) {
      // Tablet: 10-12 inches - medium padding
      if (screenWidthInches < 11) {
        return 20.0; // Small tablets
      } else {
        return 24.0; // Large tablets
      }
    } else {
      // Kiosk: 12-32 inches - larger padding for touch interaction
      if (screenWidthInches < 15) {
        return 28.0; // Small kiosks
      } else if (screenWidthInches < 20) {
        return 32.0; // Medium kiosks
      } else {
        return 40.0; // Large kiosks
      }
    }
  }

  /// Get responsive font size based on device type
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidthInches = getScreenWidthInInches(context);

    if (isMobile(context)) {
      // Mobile: 0-10 inches - smaller fonts for compact screens
      if (screenWidthInches < 5) {
        return baseSize * 0.9; // Very small screens
      } else if (screenWidthInches < 7) {
        return baseSize * 0.95; // Small screens
      } else {
        return baseSize; // Standard mobile
      }
    } else if (isTablet(context)) {
      // Tablet: 10-12 inches - medium fonts
      if (screenWidthInches < 11) {
        return baseSize * 1.1; // Small tablets
      } else {
        return baseSize * 1.2; // Large tablets
      }
    } else {
      // Kiosk: 12-32 inches - larger fonts for readability
      if (screenWidthInches < 15) {
        return baseSize * 1.3; // Small kiosks
      } else if (screenWidthInches < 20) {
        return baseSize * 1.4; // Medium kiosks
      } else {
        return baseSize * 1.6; // Large kiosks
      }
    }
  }

  /// Get responsive size based on device type
  static double getResponsiveSize(BuildContext context, double baseSize) {
    double screenWidthInches = getScreenWidthInInches(context);

    if (isMobile(context)) {
      // Mobile: 0-10 inches - compact sizing
      if (screenWidthInches < 5) {
        return baseSize * 0.8; // Very small screens
      } else if (screenWidthInches < 7) {
        return baseSize * 0.9; // Small screens
      } else {
        return baseSize; // Standard mobile
      }
    } else if (isTablet(context)) {
      // Tablet: 10-12 inches - medium sizing
      if (screenWidthInches < 11) {
        return baseSize * 1.3; // Small tablets
      } else {
        return baseSize * 1.5; // Large tablets
      }
    } else {
      // Kiosk: 12-32 inches - larger sizing for touch interaction
      if (screenWidthInches < 15) {
        return baseSize * 1.6; // Small kiosks
      } else if (screenWidthInches < 20) {
        return baseSize * 1.8; // Medium kiosks
      } else {
        return baseSize * 2.0; // Large kiosks
      }
    }
  }

  /// Get responsive grid count based on device type
  static int getResponsiveGridCount(BuildContext context) {
    double screenWidthInches = getScreenWidthInInches(context);

    if (isMobile(context)) {
      // Mobile: 0-10 inches - fewer columns for readability
      if (screenWidthInches < 5) {
        return 2; // Very small screens
      } else if (screenWidthInches < 7) {
        return 2; // Small screens
      } else {
        return 3; // Standard mobile
      }
    } else if (isTablet(context)) {
      // Tablet: 10-12 inches - medium columns
      if (screenWidthInches < 11) {
        return 4; // Small tablets
      } else {
        return 5; // Large tablets
      }
    } else {
      // Kiosk: 12-32 inches - more columns for larger screens
      if (screenWidthInches < 15) {
        return 6; // Small kiosks
      } else if (screenWidthInches < 20) {
        return 7; // Medium kiosks
      } else {
        return 8; // Large kiosks
      }
    }
  }

  /// Get responsive spacing based on device type
  static double getResponsiveSpacing(BuildContext context) {
    double screenWidthInches = getScreenWidthInInches(context);

    if (isMobile(context)) {
      // Mobile: 0-10 inches - compact spacing
      if (screenWidthInches < 5) {
        return 4.0; // Very small screens
      } else if (screenWidthInches < 7) {
        return 6.0; // Small screens
      } else {
        return 8.0; // Standard mobile
      }
    } else if (isTablet(context)) {
      // Tablet: 10-12 inches - medium spacing
      if (screenWidthInches < 11) {
        return 10.0; // Small tablets
      } else {
        return 12.0; // Large tablets
      }
    } else {
      // Kiosk: 12-32 inches - larger spacing
      if (screenWidthInches < 15) {
        return 16.0; // Small kiosks
      } else if (screenWidthInches < 20) {
        return 20.0; // Medium kiosks
      } else {
        return 24.0; // Large kiosks
      }
    }
  }

  /// Get responsive button size based on device type
  static double getResponsiveButtonSize(BuildContext context) {
    double screenWidthInches = getScreenWidthInInches(context);

    if (isMobile(context)) {
      // Mobile: 0-10 inches - compact buttons
      if (screenWidthInches < 5) {
        return 36.0; // Very small screens
      } else if (screenWidthInches < 7) {
        return 40.0; // Small screens
      } else {
        return 44.0; // Standard mobile
      }
    } else if (isTablet(context)) {
      // Tablet: 10-12 inches - medium buttons
      if (screenWidthInches < 11) {
        return 48.0; // Small tablets
      } else {
        return 52.0; // Large tablets
      }
    } else {
      // Kiosk: 12-32 inches - larger buttons for touch interaction
      if (screenWidthInches < 15) {
        return 56.0; // Small kiosks
      } else if (screenWidthInches < 20) {
        return 64.0; // Medium kiosks
      } else {
        return 72.0; // Large kiosks (30-inch falls here)
      }
    }
  }

  /// Check if device matches target Android kiosk resolution (1366x768)
  /// Uses a tolerance of ±10 pixels to account for screen density variations
  static bool isTargetKioskResolution(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const tolerance = 10.0;
    return (size.width >= TARGET_KIOSK_WIDTH - tolerance &&
            size.width <= TARGET_KIOSK_WIDTH + tolerance) &&
           (size.height >= TARGET_KIOSK_HEIGHT - tolerance &&
            size.height <= TARGET_KIOSK_HEIGHT + tolerance);
  }

  /// Get scale factor optimized for 1366x768 resolution on 30-inch Android display
  /// Returns 1.0 for exact 1366x768, and scales proportionally for other sizes
  static double getKiosk1366x768ScaleFactor(BuildContext context) {
    if (isTargetKioskResolution(context)) {
      return 1.0; // Base scale for 1366x768
    }
    
    final screenWidthInches = getScreenWidthInInches(context);
    
    // For kiosk devices, use width-based scaling relative to 1366px
    // At 30-inch diagonal in portrait, width ≈ 26.1 inches, which falls in large kiosk category
    if (isKiosk(context)) {
      final targetWidthInches = pixelsToInches(TARGET_KIOSK_WIDTH);
      final scaleFactor = screenWidthInches / targetWidthInches;
      // Clamp scale factor to reasonable bounds (0.5 to 2.5) for very large displays
      return scaleFactor.clamp(0.5, 2.5);
    }
    
    // For non-kiosk devices, return base scale
    return 1.0;
  }
}
