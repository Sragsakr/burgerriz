// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/loading_animation.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/loading_animation_for_print.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/secure_token_storage.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_model.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_store_model.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_translation_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_paymethod_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_store_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/providers/customer_provider.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';

Completer<void>? _ordersSyncCompleter;

Future<void> syncOrders(WidgetRef ref) async {
  final syncApiService = ref.watch(syncApiServiceProvider);
  final pluginSyncLogService = ref.read(pluginSyncLogApiServiceProvider);
  final records = await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();
  final haveUnSyncedOrders = records.any((record) => record.salesOrderModel.isBackOfficeSync == 0);
  // if (kDebugMode) return;
  try {
    if (_ordersSyncCompleter != null && !_ordersSyncCompleter!.isCompleted) {
      await _ordersSyncCompleter!.future;
    }

    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    _ordersSyncCompleter = Completer<void>();
    await syncApiService.sendTransactions(ref);
    await syncApiService.sendRefundsTransactions(ref);
    if (deviceInfo != null && deviceInfo.tenantIdZatca != null) {
      await syncApiService.sendOrdersToZacta(ref);
      await syncApiService.sendRefundOrdersToZacta(ref);
    }
    await syncApiService.sendRefundNotifications(ref);

    // Create the sync log entry
    if (haveUnSyncedOrders) {
      await pluginSyncLogService.createPluginSyncLog(
        date: DateTime.now().toIso8601String(),
      );
    }
    _ordersSyncCompleter?.complete();
    _ordersSyncCompleter = null;
  } catch (e, t) {
    _ordersSyncCompleter?.complete();
    _ordersSyncCompleter = null;
    dPrint(e.toString());
    dPrint(t.toString());

    // customSnackbar(navKey.currentState!.context, e.toString(), false);
  }
}

Future<void> syncMenuData(BuildContext context, WidgetRef ref, ValueNotifier<double> progressNotifier) async {
  // Progress step constants
  const double progressCurrencies = 0.1;
  const double progressSaleTenderTypes = 0.2;
  const double progressSaleTypes = 0.3;
  const double progressSaleTypeTranslations = 0.4;
  const double progressSaleTypeStores = 0.55;
  const double progressSaleTypePriceLists = 0.5;
  const double progressGenerateSaleTypeList = 0.6;
  const double progressMenuStart = 0.6;
  const double progressMenuEnd = 0.8;
  const double progressPromotions = 0.85;
  const double progressSynchronization = 0.9; // New progress step for synchronization
  const double progressCustomers = 0.95;
  const double progressDone = 1.0;

  String? tenantId = await AppPreferences().getTenant();
  String? token = await SecureTokenStorage().getAccessToken();

  final currencyApiService = ref.watch(currencyApiServiceProvider);
  final menuItemSyncService = ref.watch(menuItemSyncApiServiceProvider);
  final unitOfMeasureService = ref.watch(unitOfMeasureTranslationApiServiceProvider);
  final productCategoryService = ref.watch(productCategoryApiServiceProvider);
  final primaryCategoryService = ref.watch(primaryCategoryApiServiceProvider);
  final secondaryCategoryService = ref.watch(secondaryCategoryApiServiceProvider);
  final saleTypesService = ref.watch(saleTypesApiServiceProvider);
  final promotionsApiService = ref.watch(promotionsApiServiceProvider);
  final customerNotifier = ref.read(customerNotifierProvider.notifier);
  final refundResonApiService = ref.read(refundResonApiServiceProvider);
  final synchronizationApiService = ref.read(synchronizationApiServiceProvider);
  final codingPatternSettingsApiService = ref.read(codingPatternSettingsApiServiceProvider);

  await currencyApiService.fetchCurrencies();
  progressNotifier.value = progressCurrencies;

  await saleTypesService.getSaleTenderTypes();
  progressNotifier.value = progressSaleTenderTypes;

  await saleTypesService.getSaleTypes();
  progressNotifier.value = progressSaleTypes;

  await saleTypesService.getSaleTypeTranslations();
  progressNotifier.value = progressSaleTypeTranslations;
  await saleTypesService.getSaleTypeStores();
  progressNotifier.value = progressSaleTypeStores;

  // await SaleTypesApiServices().getSaleTypeStores();
  await saleTypesService.getSaleTypePriceLists();
  progressNotifier.value = progressSaleTypePriceLists;

  // getSaleTypesFromDataBase
  List<SaleType> saleTypes = await generateSaleTypeList();
  progressNotifier.value = progressGenerateSaleTypeList;

  dPrint("===================");
  dPrint(saleTypes.length.toString());

  // Sync menu item data using new sync services
  await menuItemSyncService.syncAllMenuItemData();
  progressNotifier.value = progressMenuStart + (progressMenuEnd - progressMenuStart) * 0.25;

  await unitOfMeasureService.fetchUnitOfMeasureTranslations();
  progressNotifier.value = progressMenuStart + (progressMenuEnd - progressMenuStart) * 0.5;

  await productCategoryService.fetchProductCategories();
  await productCategoryService.fetchProductCategoryTranslations();
  await productCategoryService.fetchProductCategoryLevels();
  progressNotifier.value = progressMenuStart + (progressMenuEnd - progressMenuStart) * 0.75;

  await primaryCategoryService.fetchPrimaryCategories();
  await primaryCategoryService.fetchPrimaryCategoryTranslations();

  await secondaryCategoryService.fetchSecondaryCategories();
  await secondaryCategoryService.fetchSecondaryCategoryTranslations();
  progressNotifier.value = progressMenuEnd;

  try {
    await refundResonApiService.fetchRefundResons();
  } catch (e) {
    dPrint(e.toString());
  }

  // Sync promotions
  await promotionsApiService.syncAllPromotionTablesFromRemote();
  progressNotifier.value = progressPromotions;

  await synchronizationApiService.getMenuItemVariations();
  await synchronizationApiService.getVariantTableElements();
  await synchronizationApiService.getVariantTranslationElements();
  await synchronizationApiService.getVariationValues();
  await synchronizationApiService.getVariationValueTranslations();
  await synchronizationApiService.getVariationValueTranslationPricing();
  await synchronizationApiService.syncAllComboMealData();
  await synchronizationApiService.getReportGroupTranslations();

  progressNotifier.value = progressSynchronization;

  // Sync customers
  try {
    await customerNotifier.syncCustomers(
      tenantId: tenantId,
      token: token,
    );
    dPrint('Customer sync completed successfully');
  } catch (e) {
    dPrint('Customer sync failed: $e');
    // Continue with sync even if customer sync fails
  }
  try {
    await codingPatternSettingsApiService.getSalesCodePattern();
    dPrint('Sales Code Pattern sync completed successfully');
  } catch (e) {
    dPrint('Sales Code Pattern sync failed: $e');
    // Continue with sync even if customer sync fails
  }
  try {
    await codingPatternSettingsApiService.getSalesCodePatternForRefund();

    dPrint('Sales Code Pattern for Refund sync completed successfully');
  } catch (e) {
    dPrint('Sales Code Pattern for Refund sync failed: $e');
    // Continue with sync even if customer sync fails
  }
  progressNotifier.value = progressCustomers;

  // Guarantee it finishes exactly at 100%
  progressNotifier.value = progressDone;
}

Future<List<SaleType>> generateSaleTypeList() async {
  List<SaleTypeTranslationModel> saleTypeTranslations = await SaleTypeTranslationTable.getAll();
  String? storeId = await AppPreferences().getStore();

  List<SaleTypeModel> saleTypes = await SaleTypeTable.getAll();
  // SaleType Stores
  List<SaleTypeStoresModel> saleTypeStores = await SaleTypeStoresTable.getAll();

  // Filter sale types based on store
  List<int> allowedSaleTypeIds = [];

  int storeIdInt = int.tryParse(storeId) ?? 0;
  allowedSaleTypeIds =
      saleTypeStores.where((store) => store.storeId == storeIdInt).map((store) => store.saleTypeId).toList();

  // Group translations by saleTypeId
  Map<int, Map<String, String>> grouped = {};

  for (var item in saleTypeTranslations) {
    int saleTypeId = item.saleTypeId;

    // Skip if store filtering is enabled and this sale type is not allowed for this store
    if (!allowedSaleTypeIds.contains(saleTypeId)) {
      continue;
    }

    String name = item.name;
    int languageId = item.languageId;

    // Ensure entry exists
    grouped.putIfAbsent(saleTypeId, () => {'en': '', 'ar': ''});

    // Assign based on languageId
    if (languageId == 1) {
      grouped[saleTypeId]!['en'] = name;
    } else if (languageId == 2) {
      grouped[saleTypeId]!['ar'] = name;
    }
  }

  // Convert map to list of SaleType
  return grouped.entries.map((entry) {
    final saleNature = saleTypes.firstWhere((element) => element.id == entry.key);
    return SaleType(
        saleTypeId: entry.key,
        nameEn: entry.value['en'] ?? '',
        nameAr: entry.value['ar'] ?? '',
        saleNature: saleNature.saleNatural);
  }).toList();
}

List<Map<String, dynamic>> getSaleTypeSummary(List<SalesInvoice> salesOrders, List<SaleType> saleTypes) {
  Map<int, Map<String, dynamic>> summary = {};

  for (var order in salesOrders) {
    if (order.salesOrderItems.isNotEmpty) {
      int saleTypeId = order.salesOrderModel.saleTypeId;
      double orderTotal = double.tryParse(order.salesOrderModel.totalAmount) ?? 0.0;

      if (!summary.containsKey(saleTypeId)) {
        // Find the sale type name
        SaleType? saleType = saleTypes.firstWhere(
          (st) => st.saleTypeId == saleTypeId,
          orElse: () => SaleType(nameEn: "Unknown", nameAr: "غير معروف", saleTypeId: saleTypeId, saleNature: 0),
        );

        summary[saleTypeId] = {
          "saleTypeId": saleTypeId,
          "saleTypeNameEn": saleType.nameEn,
          "saleTypeNameAr": saleType.nameAr,
          "orderCount": 0,
          "totalAmount": 0.0,
        };
      }

      summary[saleTypeId]!["orderCount"] += 1;
      summary[saleTypeId]!["totalAmount"] += orderTotal;
    }
  }

  return summary.values.toList();
}

List<Map<String, dynamic>> getTenderSummary(
  List<SalesInvoice> salesOrders,
) {
  Map<int, Map<String, dynamic>> summary = {};

  for (var order in salesOrders) {
    for (var pay in order.salesOrderPayMethods) {
      int tenderId = pay.tenderTypeId;
      double orderTotal = pay.amount;

      if (!summary.containsKey(tenderId)) {
        // Find the sale type name
        SalesPayMethodModel? payMethodModel = order.salesOrderPayMethods.firstWhere(
          (st) => st.tenderTypeId == tenderId,
        );

        summary[tenderId] = {
          "tenderId": tenderId,
          "nameEn": payMethodModel.nameEn,
          "nameAr": payMethodModel.nameAr,
          "orderCount": 0,
          "totalAmount": 0.0,
        };
      }

      summary[tenderId]!["orderCount"] += 1;
      summary[tenderId]!["totalAmount"] += orderTotal;
    }
  }

  return summary.values.toList();
}

void hideLoading(BuildContext context) {
  if (context.mounted) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}

void showLoading(BuildContext context,
    {String? message, ValueNotifier<double>? progressNotifier, bool isLottie = false}) {
  showAppDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LoadingPopup(
        isLottie: isLottie,
        message: message,
        progressNotifier: progressNotifier, // Pass it here!
      );
    },
  );
}

void showLoadingForPrint(BuildContext context,
    {String? message, ValueNotifier<double>? progressNotifier, bool isLottie = false}) {
  showAppDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LoadingPopupForPrint(
        isLottie: isLottie,
        message: message,
        progressNotifier: progressNotifier, // Pass it here!
      );
    },
  );
}

class SaleType {
  final String nameEn;
  final String nameAr;
  final int saleTypeId;
  final int saleNature;

  SaleType({required this.nameEn, required this.nameAr, required this.saleTypeId, required this.saleNature});

  String get imagePath {
    switch (saleNature) {
      case 0:
        return AppAssets.store;

      case 1:
        return AppAssets.takeAway;

      case 2:
        return AppAssets.delivery;

      default:
        return AppAssets.delivery;
    }
  }
}

Future<String?> selectDate(BuildContext context) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDate != null) {
    return DateFormat('yyyy-MM-dd').format(pickedDate); // Format to YYYY-MM-DD
  }
  return null;
}
