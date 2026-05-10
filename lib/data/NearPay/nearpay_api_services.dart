// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:nearpay_flutter_sdk/nearpay.dart';
import 'package:uuid/uuid.dart';

import 'nearpay_services.dart';

// Global variables
const uuid = Uuid();
late Nearpay? nearpay;
bool isNearpayInitialized = false;
// bool isNearpayLoading = false;

Future<void> setupAndInitializeNearpay({required String terminalID}) async {
  try {
    final headers = await AppUrls.getNearPayHeader();
    final tokenUrl = await AppUrls.getNearPayTokenUrl();
    final env = await AppUrls.getNearPayEnvironment();
    final response = await Dio().get(
      tokenUrl,
      data: {
        'terminal_id': terminalID,
      },
      options: Options(
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      final token = response.data['token'];
      print('$terminalID\n' + token);

      print('PASS');

      // Create Nearpay instance
      nearpay = Nearpay(
        authType: AuthenticationType.jwt,
        authValue: token,
        env: env,
        locale: Locale.localeDefault,
      );

      // Initialize and setup
      await initializeNearpay();
      //if you want to install the plugin immediatly after initializing then use the setup method (optional)
      await nearPaySetUp();
      isNearpayInitialized = true;
      print('Nearpay initialized successfully. $isNearpayInitialized');
    }
  } catch (e) {
    isNearpayInitialized = false;
    print('Error in setupAndInitializeNearpay $isNearpayInitialized: $e');
    throw Exception('Failed to setup Nearpay: $e');
  }
}

Future<void> handleNearpayTransaction({
  required String transactionId,
  required String terminalID,
  required int amount,
  required BuildContext context,
  required WidgetRef ref,
}) async {
  try {
    await setupAndInitializeNearpay(terminalID: terminalID);
    await processPurchase(
      transactionId: transactionId,
      amount: amount,
      context: context,
      ref: ref,
    );
  } catch (e) {
    // context.go('/checkout-page');
    customSnackbar(context, "Error during purchase" + e.toString(), false);
    print('Error in handleNearpayTransaction: $e');
    throw Exception('Transaction failed: $e');
  }
}

Future<void> handleNearpayTransactionRefund({
  required String originalTransactionUUID,
  required String transactionId,
  required String terminalID,
  required int amount,
  required BuildContext context,
  required WidgetRef ref,
}) async {
  try {
    await setupAndInitializeNearpay(terminalID: terminalID);
    await processRefund(
      originalTransactionUUID: originalTransactionUUID,
      transactionId: transactionId,
      amount: amount,
      context: context,
      ref: ref,
    );
  } catch (e) {
    customSnackbar(context, "Error during Refund" + e.toString(), false);
    print('Error in handleNearpayTransactionRefund: $e');
    throw Exception('Transaction failed: $e');
  }
}
