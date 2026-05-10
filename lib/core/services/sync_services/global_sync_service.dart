import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/plugin_sync_log_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/sync_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/providers/promotion_provider.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';

// Standalone sync function that doesn't require WidgetRef
Future<void> performStandaloneSync() async {
  try {
    // log('Starting standalone sync operations');

    // Create a new instance of SyncApiService for standalone use
    final syncApiService = SyncApiService();
    await syncApiService.initialize();

    final pluginSyncLogService = PluginSyncLogApiService();
    await pluginSyncLogService.initialize();
    final records = await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();
    final haveUnSyncedOrders =
        records.any((record) => record.salesOrderModel.isBackOfficeSync == 0 && record.salesOrderPayMethods.isNotEmpty);
    // Send transactions
    await syncApiService.sendTransactionsStandalone();
    // log('Transactions sync completed');

    // Send refund transactions
    await syncApiService.sendRefundsTransactionsStandalone();
    // log('Refund transactions sync completed');

    // Check if Zatca is enabled
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    if (deviceInfo != null && deviceInfo.tenantIdZatca != null) {
      await syncApiService.sendOrdersToZactaStandalone();
      await syncApiService.sendRefundOrdersToZactaStandalone();
      // log('Zatca sync completed');
    }

    // Send refund notifications
    await syncApiService.sendRefundNotificationsStandalone();

    if (haveUnSyncedOrders) {
      await pluginSyncLogService.createPluginSyncLog(
        date: DateTime.now().toIso8601String(),
      );
    }
    // log('Refund notifications sync completed');

    // log('Standalone sync completed successfully');
  } catch (e, stackTrace) {
    log('Error during standalone sync: $e');
    log('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<void> _refreshPromotionCatalogAfterTransactionalSync(WidgetRef? ref) async {
  if (ref == null) return;
  final token = await AppPreferences().getAccessToken();
  if (token.isEmpty) return;
  try {
    await ref.read(promotionsApiServiceProvider).syncAllPromotionTablesFromRemote();
    ref.read(promotionCatalogRevisionProvider.notifier).state++;
  } catch (e, stackTrace) {
    log('Promotion catalog refresh after sync failed: $e');
    log('Stack trace: $stackTrace');
  }
}

class GlobalSyncService {
  static final GlobalSyncService _instance = GlobalSyncService._internal();
  factory GlobalSyncService() => _instance;
  GlobalSyncService._internal();

  Timer? _syncTimer;
  bool _isInitialized = false;
  WidgetRef? _ref;

  /// Initialize the global sync service
  /// This should be called after login when we have a valid WidgetRef
  void initialize(WidgetRef ref) {
    if (_isInitialized) {
      // log('Global sync service already initialized');
      return;
    }

    // log('Initializing global sync service');
    _isInitialized = true;
    _ref = ref;
    _startSyncTimer();
  }

  /// Start the periodic sync timer
  void _startSyncTimer() async {
    try {
      // Get sync interval from app preferences
      final syncTimeString = await AppPreferences().getSyncInterval();
      final syncTime = int.tryParse(syncTimeString) ?? 0;
      // final syncTime = 1;
      bool syncIsNotZero = syncTime != 0;

      final duration = syncIsNotZero ? Duration(minutes: syncTime) : const Duration(seconds: 30);

      // log('Starting global sync timer with ${syncIsNotZero ? '$syncTime minutes' : '30 seconds'} interval');

      _syncTimer?.cancel();
      _syncTimer = Timer.periodic(duration, (timer) async {
        // log('Global sync timer triggered');

        try {
          await performStandaloneSync();
          // await _refreshPromotionCatalogAfterTransactionalSync(_ref);
        } catch (e, stackTrace) {
          log('Global sync error: $e');
          log('Global sync trace: $stackTrace');
        }
      });
    } catch (e, stackTrace) {
      log('Error starting sync timer: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Stop the sync timer
  void stop() {
    // log('Stopping global sync service');
    _syncTimer?.cancel();
    _syncTimer = null;
    _isInitialized = false;
    _ref = null;
  }

  /// Restart the sync timer (useful when sync interval changes)
  Future<void> restart(WidgetRef ref) async {
    // log('Restarting global sync timer...');
    stop();
    initialize(ref);
  }

  /// Check if the service is running
  bool get isRunning => _syncTimer != null && _syncTimer!.isActive;

  /// Get the current sync interval from preferences
  Future<int> getSyncInterval() async {
    final syncTimeString = await AppPreferences().getSyncInterval();
    return int.tryParse(syncTimeString) ?? 0;
  }
}

// Provider for the global sync service
final globalSyncServiceProvider = Provider<GlobalSyncService>((ref) {
  return GlobalSyncService();
});
