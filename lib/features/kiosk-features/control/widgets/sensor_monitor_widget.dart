import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/sdks/sdk_logic/led_status_manager.dart';

class SensorMonitorWidget extends StatefulWidget {
  const SensorMonitorWidget({super.key});

  @override
  State<SensorMonitorWidget> createState() => _SensorMonitorWidgetState();
}

class _SensorMonitorWidgetState extends State<SensorMonitorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Column(
        children: [
          const Text(
            'System Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LEDStatusManager.instance.getStatusDescription(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
