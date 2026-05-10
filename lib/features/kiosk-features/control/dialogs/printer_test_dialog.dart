import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/kiosk_printing/thermal_printer_service.dart';

class PrinterTestDialog extends StatefulWidget {
  const PrinterTestDialog({super.key});

  @override
  State<PrinterTestDialog> createState() => _PrinterTestDialogState();
}

class _PrinterTestDialogState extends State<PrinterTestDialog> {
  bool _isTesting = false;
  String _testResult = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Printer Test'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'This will test the thermal printer by printing a test receipt.'),
          const SizedBox(height: 16),
          if (_isTesting)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Testing printer...'),
              ],
            ),
          if (_testResult.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _testResult.contains('success')
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _testResult.contains('success')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              child: Text(
                _testResult,
                style: TextStyle(
                  color: _testResult.contains('success')
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isTesting ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: _isTesting ? null : _testPrinter,
          child: const Text('Test Printer'),
        ),
      ],
    );
  }

  Future<void> _testPrinter() async {
    setState(() {
      _isTesting = true;
      _testResult = '';
    });

    try {
      dPrint('Starting printer test...');

      // Create a simple test receipt
      final testFrames = await _createTestReceipt();

      // Print the test receipt
      await ThermalPrinterService.printInvoiceFinal(frames: testFrames);

      setState(() {
        _testResult = 'Printer test successful! Check the printed receipt.';
      });

      dPrint('Printer test completed successfully');
    } catch (e, stackTrace) {
      dPrint('Printer test failed: $e');
      dPrint('Stack trace: $stackTrace');

      setState(() {
        _testResult = 'Printer test failed: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<List<Uint8List>> _createTestReceipt() async {
    // This is a simplified test receipt
    // In a real implementation, you would use the proper receipt generation
    final testData = '''
=== PRINTER TEST ===
Date: ${DateTime.now().toString()}
Time: ${DateTime.now().hour}:${DateTime.now().minute}
Status: TESTING
========================
This is a test receipt to verify
that the thermal printer is working
correctly.
========================
Test completed successfully!
''';

    // Convert text to bytes (simplified)
    final bytes = testData.codeUnits.map((e) => e.toUnsigned(8)).toList();
    return [Uint8List.fromList(bytes)];
  }
}
