import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_widgets.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';

class QuantityInputDialog extends ConsumerStatefulWidget {
  String? value;
  final bool allowDecimal;
  QuantityInputDialog({super.key, this.value, this.allowDecimal = false});

  @override
  ConsumerState<QuantityInputDialog> createState() =>
      _QuantityInputDialogState();
}

class _QuantityInputDialogState extends ConsumerState<QuantityInputDialog> {
  late TextEditingController _barcodeController;
  late FocusNode _barcodeFocusNode;

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(
        text: widget.value ?? (widget.allowDecimal ? '1.0' : '1'));
    _barcodeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translator(arText: ' الكمية', enText: ' Quantity'),
              style: FlutterFlowTheme.of(context)
                  .titleMedium
                  .copyWith(color: Colors.black),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _barcodeController,
              focusNode: _barcodeFocusNode,
              autofocus: true,
              textAlign: TextAlign.center,
              keyboardType: widget.allowDecimal
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              inputFormatters: widget.allowDecimal
                  ? [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      // Allow only one decimal point
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.split('.').length > 2) {
                          return oldValue;
                        }
                        return newValue;
                      }),
                    ]
                  : [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
              decoration: InputDecoration(
                hintText:
                    translator(arText: 'ادخل الكمية', enText: 'Enter Quantity'),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  context,
                  text: translator(arText: 'الغاء', enText: 'Cancel'),
                  color: Colors.grey.shade300,
                  textColor: Colors.black,
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                _buildButton(
                  context,
                  text: translator(arText: 'تأكيد', enText: 'Confirm'),
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    final text = _barcodeController.text.trim();
                    if (text.isEmpty) {
                      Navigator.of(context)
                          .pop(widget.allowDecimal ? '1.0' : '1');
                      return;
                    }

                    // Validate the input
                    if (widget.allowDecimal) {
                      final value = double.tryParse(text);
                      if (value != null && value > 0) {
                        Navigator.of(context).pop(text);
                      } else {
                        _showErrorDialog(
                            context,
                            translator(
                                arText: 'يرجى إدخال رقم  أكبر من الصفر',
                                enText:
                                    'Please enter a valid number greater than zero'));
                      }
                    } else {
                      final value = int.tryParse(text);
                      if (value != null && value > 0) {
                        Navigator.of(context).pop(text);
                      } else {
                        _showErrorDialog(
                            context,
                            translator(
                                arText: 'يرجى إدخال رقم صحيح أكبر من الصفر',
                                enText:
                                    'Please enter a valid integer greater than zero'));
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String text,
      required Color color,
      required Color textColor,
      required VoidCallback onPressed}) {
    return FFButtonWidget(
      onPressed: onPressed,
      text: text,
      options: FFButtonOptions(
        width: 100,
        height: 40,
        color: color,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              fontFamily: 'Readex Pro',
              color: textColor,
            ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showAppDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translator(arText: 'خطأ', enText: 'Error')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(translator(arText: 'موافق', enText: 'OK')),
          ),
        ],
      ),
    );
  }
}
