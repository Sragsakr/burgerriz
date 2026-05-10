import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/NearPay/nearpay_api_services.dart';
import 'package:kiosk_point_of_sale/data/NearPay/nearpay_services.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';

class NfcTestDialog extends ConsumerStatefulWidget {
  const NfcTestDialog({super.key});

  @override
  ConsumerState<NfcTestDialog> createState() => _NfcTestDialogState();
}

class _NfcTestDialogState extends ConsumerState<NfcTestDialog> {
  bool _isTesting = false;
  String _testResult = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('NFC Payment Test'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'This will test NFC payment functionality with a 1 SAR test transaction.'),
          const SizedBox(height: 16),
          if (_isTesting)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Testing NFC payment...'),
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
          onPressed: _isTesting ? null : _testNfcPayment,
          child: const Text('Test NFC Payment'),
        ),
      ],
    );
  }

  Future<void> _testNfcPayment() async {
    setState(() {
      _isTesting = true;
      _testResult = '';
    });

    try {
      dPrint('Starting NFC payment test...');

      // Get device configuration
      final appConfig = await DeviceConfigTable.getDeviceInfo();
      if (appConfig == null) {
        throw Exception('No device configuration found');
      }

      if (appConfig.terminalId == null) {
        throw Exception('No terminal ID configured');
      }

      // Setup and initialize NearPay
      await setupAndInitializeNearpay(terminalID: appConfig.terminalId!);

      // Process test payment of 1 SAR (100 halalas)
      await processPurchase(
        transactionId: 'test_transaction_id',
        amount: 100, // 1 SAR in halalas
        context: context,
        ref: ref,
      );

      setState(() {
        _testResult =
            'NFC payment test successful! 1 SAR test transaction completed.';
      });

      dPrint('NFC payment test completed successfully');
    } catch (e, stackTrace) {
      dPrint('NFC payment test failed: $e');
      dPrint('Stack trace: $stackTrace');

      setState(() {
        _testResult = 'NFC payment test failed: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }
}
