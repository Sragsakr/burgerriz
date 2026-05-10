// ignore_for_file: unused_element, use_build_context_synchronously, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

class PhoneInput extends ConsumerStatefulWidget {
  const PhoneInput({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PhoneInputState();
}

class _PhoneInputState extends ConsumerState<PhoneInput> {
  final TextEditingController _phoneController = TextEditingController(text: kDebugMode ? "" : "");
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
              Directionality(
                textDirection: TextDirection.ltr,
                child: IntlPhoneField(
                  controller: _phoneController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: translator(arText: 'رقم الهاتف', enText: 'Phone Number'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  initialCountryCode: 'SA',
                  onChanged: (phone) {
                    dPrint(phone.completeNumber);
                    ref.read(invoicePhoneProvider.notifier).update((state) => phone.completeNumber);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
