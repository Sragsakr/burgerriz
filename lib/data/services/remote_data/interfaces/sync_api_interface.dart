import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SyncApiInterface {
  /// Send transactions to the backend
  Future<Response?> sendTransactions(WidgetRef ref);
  Future<Response?> sendRefundsTransactions(WidgetRef ref);

  /// Send refund transactions to the backend
  Future<Response?> sendRefundNotifications(WidgetRef ref);

  /// Send orders to ZATCA
  Future<void> sendOrdersToZacta(WidgetRef ref);

  /// Send refund orders to ZATCA
  Future<void> sendRefundOrdersToZacta(WidgetRef ref);
}
