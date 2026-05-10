package com.posmaena.kiosk

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Use the new unified plugin that combines both UsbPlugin and SensorPlugin functionality
        //   flutterEngine.plugins.add(UnifiedUsbPlugin())

        // Legacy plugins are now replaced by UnifiedUsbPlugin
       //  flutterEngine.plugins.add(UsbPlugin())
        // flutterEngine.plugins.add(SensorPlugin())
    }
}
