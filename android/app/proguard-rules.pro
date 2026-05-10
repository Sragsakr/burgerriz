# Ignore the specified classes and packages
-dontwarn com.pos.poslibusb.MCS7840Device
-dontwarn com.pos.poslibusb.MCS7840Driver
-dontwarn com.pos.poslibusb.PosLibUsb
-dontwarn com.pos.poslibusb.PosLog
-dontwarn com.pos.poslibusb.UsbDeviceFilter
-dontwarn com.pos.susdk.SUFunctions

# Ignore the unused classes
-ignorewarnings
-keep class !com.pos.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.pos.poslibusb.** { *; }
