// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/providers/nearpay_provider.dart';
import 'package:path_provider/path_provider.dart';

import 'nearpay_api_services.dart';
// ignore_for_file: avoid_print

Future<void> initializeNearpay() async {
  print('Initializing Nearpay ...');
  try {
    final initializeResponse = await nearpay!.initialize().catchError((e) {
      dPrint(e.toString());
    });
    print('initializeResponse $initializeResponse');
  } catch (e) {
    dPrint("Error initializing Nearpay: $e'");
    throw Exception('Error initializing Nearpay: $e');
  }
  print('Nearpay initialized successfully.');
}

Future<void> nearPaySetUp() async {
  try {
    //if you want to install the plugin immediatly after initializing then use the setup method (optional)
    final setupResponse = await nearpay!.setup();
    print('setupResponse $setupResponse');
  } catch (e, t) {
    dPrint("Error setup Nearpay: $e'");
    dPrint("Error setup Nearpay: Trace $t'");
    throw Exception('Error setup Nearpay: $e');
  }
}

Future<void> processPurchase({
  required String transactionId,
  required int amount,
  required BuildContext context,
  required WidgetRef ref,
}) async {
  print('Processing purchase ...');
  try {
    print('Start Processing purchase ...');
    final response = await nearpay!.purchase(
      amount: amount,
      transactionId: transactionId,
      // customerReferenceNumber: uuid.v4(),
      enableReceiptUi: true,
      enableReversalUi: true,
      enableUiDismiss: true,
      finishTimeout: 3,
    );
    print('Purchase successful: ${response.toJson()}');
    print('Purchase successful');
    // customSnackbar(context, response.toJson().toString(), true);
    ref.read(nearpayPaymentDoneProvider.notifier).state = true;

    // context.go('/');
  } catch (e, t) {
    // customSnackbar(context, e.toString(), false);
    print('Error during transaction: $e');
    print('Error during transaction Trace: $t');
    throw Exception('Error during transaction: $e');
  }
  print('Purchase process completed.');
}

//refund
Future<void> processRefund({
  required String originalTransactionUUID,
  required String transactionId,
  required int amount,
  required BuildContext context,
  required WidgetRef ref,
}) async {
  print('Processing Refund ...');
  try {
    print('Start Processing Refund ...');
    final response = await nearpay!.refund(
      originalTransactionUUID: originalTransactionUUID,
      amount: amount,
      transactionId: transactionId,
      enableReceiptUi: true,
      enableReversalUi: true,
      enableUiDismiss: true,
      finishTimeout: 3,
    );
    print('Purchase successful: ${response.toJson()}');
    print('Purchase successful');
    // customSnackbar(context, response.toJson().toString(), true);
    ref.read(nearpayPaymentDoneProvider.notifier).state = true;

    // context.go('/');
  } catch (e, t) {
    // customSnackbar(context, e.toString(), false);
    print('Error during transaction: $e');
    print('Error during transaction Trace: $t');
    throw Exception('Error during transaction: $e');
  }
  print('Purchase process completed.');
}

Future<void> processLogout() async {
  print('Processing logout ...');
  try {
    final response = await nearpay!.logout();
    nearpay?.close();
    nearpay = null;
    clearCache();
    print('Logout successful');
    print('Logout successful: $response');
  } catch (e) {
    print('Error during logout: $e');
    throw Exception('Error during logout: $e');
  }
  print('Logout successful completed.');
}

Future<void> clearCache() async {
  try {
    // Get the temporary directory
    final cacheDir = await getTemporaryDirectory();

    // Check if the directory exists, then delete it
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }

    // Optionally, get the app's document directory and clear it as well
    final appDir = await getApplicationDocumentsDirectory();
    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }

    print("Cache cleared successfully.");
  } catch (e) {
    print("Error clearing cache: $e");
  }
}
