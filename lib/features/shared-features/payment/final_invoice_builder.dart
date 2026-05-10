import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/sync_request_helper.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/order_calculator.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_paymethod_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';
import 'package:uuid/uuid.dart';

Future<SalesInvoice> generateFinalInvoice(String selectedMode, WidgetRef ref, BuildContext context, String userMobile,
    {bool temp = false}) async {
  const uuid = Uuid();
  String createdAt = DateTime.now().toIso8601String();
  final orderSummaryAsync = ref.watch(orderSummaryProvider);

  final workDate = await SyncRequestHelper().getBusinessDay(createdAt);

  String date = workDate == null
      ? DateTime.now().toIso8601String().split('T').first
      : workDate.toIso8601String().split('T').first;

  final orderSummary = orderSummaryAsync.when(
    data: (summary) {
      dPrint("OrderSummary data received successfully");
      return summary;
    },
    loading: () {
      dPrint("OrderSummary is still loading");
      throw Exception('Order summary is loading');
    },
    error: (error, stack) {
      dPrint("OrderSummary error: $error");
      throw Exception('Error loading order summary: $error');
    },
  );

  final userName = await AppPreferences().getUsername();
  final cashierShifts = await CashierShiftTable.getAll();
  final tenantId = await AppPreferences().getTenant();
  final userId = await AppPreferences().getCashierId();
  final shift = cashierShifts.first;
  final saleType = ref.watch(saleTypeNotifier.notifier);
  final receiptNumber = temp ? null : await receiptID();
  final totalPaid = ref.watch(paymentBreakdownProvider).fold<num>(
        0.0,
        (sum, payment) => sum + payment.amount,
      );
  final String change =
      (totalPaid > orderSummary.totalAmount) ? (totalPaid - orderSummary.totalAmount).toStringAsFixed(2) : '0.00';

  final salesOrderModel = SalesOrderModel(
    id: null,
    uuid: uuid.v4(),
    customerId: orderSummary.customerId,
    createdAt: createdAt,
    updatedAt: createdAt,
    workDate: date,
    change: double.tryParse(change) ?? 0.0,
    deletedAt: '',
    cashierName: userName,
    tenantId: tenantId,
    invoiceId: null,
    haveRefund: 0,
    cashierShiftId: shift.cashierShiftId!,
    subTotalBeforeDiscount: orderSummary.subTotalBeforeDiscount.toStringAsFixed(2),
    totalAmountBeforeDiscount: orderSummary.totalAmountBeforeDiscount.toStringAsFixed(2),
    taxBeforeDiscount: orderSummary.taxBeforeDiscount.toStringAsFixed(2),
    subTotal: orderSummary.subtotal.toStringAsFixed(2),
    tax: orderSummary.taxAmount.toStringAsFixed(2),
    totalAmount: orderSummary.totalAmount.toStringAsFixed(2),
    note: '',
    isRefund: 0,
    userId: userId.toString(),
    discountType: orderSummary.discountType,
    discountValue: orderSummary.discountAmount,
    discountAmount: orderSummary.discountAmount,
    discount: orderSummary.discount,
    receiptNumber: receiptNumber,
    orderNumber: '',
    saleTypeId: saleType.state!.saleTypeId,
    isBackOfficeSync: 0,
    isZactaSync: 0,
    customerPhone: userMobile,
    paymentMethod: 0,
    promotionCode: orderSummary.orderPromotionCode,
    promotionType: orderSummary.orderPromotionType,
    promotionValue: orderSummary.promotionValue,
    promotionAmount: orderSummary.orderPromotionType == null ? null : orderSummary.orderPromotionAmount,
    promotionName: orderSummary.promotionName,
    saleNotificationDetailId: '',
    refundResonId: '',
  );
  dPrint("###salesOrderModel: ${salesOrderModel.toMap()}");

  final cartItems = ref.watch(cartProvider);
  final salesItemsList = <SalesItemsModel>[];

  ItemPromotionData? findItemPromotion(CartItem item) {
    return orderSummary.itemPromotions[int.parse(item.productId)];
  }

  for (var item in cartItems) {
    ItemPromotionData? itemPromotion = findItemPromotion(item);
    final salesItem =
        orderSummary.salesInvoice.salesOrderItems.firstWhere((element) => element.productId == item.productId);
    final newPrice = double.parse(salesItem.price);
    const double taxRate = 0.15;

    final double itemPrice = newPrice;
    final double itemQuantity = item.quantity.toDouble();

    double basePricePerUnit = 0.0;
    double totalBaseAmount = 0.0;
    double subTotalBeforeDiscount = 0.0;

    if (item.inclusive) {
      totalBaseAmount = itemPrice * 1.15;
      basePricePerUnit = itemPrice;
      subTotalBeforeDiscount = (basePricePerUnit * itemQuantity).roundToTwoDecimals();
    } else {
      totalBaseAmount = itemPrice;
      basePricePerUnit = itemPrice / (1 + taxRate);
      subTotalBeforeDiscount = (basePricePerUnit * itemQuantity).roundToTwoDecimals();
    }

    dPrint("####@subTotalBeforeDiscount is $subTotalBeforeDiscount");
    final totalBeforeTax = totalBaseAmount * itemQuantity;
    dPrint("####@totalBeforeDiscount is $totalBeforeTax");
    double vatBeforeDiscount = (totalBeforeTax - subTotalBeforeDiscount).roundToTwoDecimals();
    dPrint("###@vatBeforeDiscount is $vatBeforeDiscount");
    double promotionValue = salesItem.promotionValue ?? 0.0;
    double discount = salesItem.discount ?? 0.0;

    double subTotalAfterDiscount = subTotalBeforeDiscount - discount - promotionValue;
    if (subTotalAfterDiscount < 0) {
      subTotalAfterDiscount = 0.0;
    }
    double dicountVat = ((discount + promotionValue) * taxRate).roundToTwoDecimals();
    dPrint("###@dicountVat is $dicountVat ${(discount + promotionValue) * taxRate}");
    double vatAfterDiscount = vatBeforeDiscount - dicountVat;

    dPrint("**Item: ${item.nameEn}");
    dPrint("  New Price: $newPrice");
    dPrint("  Base Price Per Unit: ${basePricePerUnit.toStringAsFixed(2)}");
    dPrint("  Total Base Amount (per unit, incl VAT): $totalBaseAmount");
    dPrint("  SubTotal Before Discount: $subTotalBeforeDiscount");
    dPrint("  Promotion Value: $promotionValue");
    dPrint("  SubTotal After Discount: $subTotalAfterDiscount");
    dPrint("  VAT After Discount (total): $vatAfterDiscount");
    dPrint("  VAT After Discount (per unit): ${(vatAfterDiscount / itemQuantity).roundToFourDecimals()}");

    final salesItemsModel = SalesItemsModel(
      id: null,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      productId: item.productId,
      categoryId: item.categoryId,
      productNameEn: item.nameEn,
      productNameAr: item.nameAr,
      unitOfMeasureId: item.unitId.toString(),
      unitNameEn: item.unitNameEn,
      unitNameAr: item.unitNameAr,
      quantity: item.quantity.toString(),
      price: basePricePerUnit.toStringAsFixed(2),
      total: totalBaseAmount.toString(),
      note: '',
      tax: (vatAfterDiscount / item.quantity).toStringAsFixed(4),
      isRefund: 0,
      userId: userId.toString(),
      tenantId: tenantId,
      uniqueId: uuid.v4(),
      invoiceId: '',
      isExclusive: item.inclusive,
      discount: 0.0,
      loyaltyDiscount: 0.0,
      promotionValue: itemPromotion?.promotionValue ?? 0.0,
      vatBeforeDiscount:
          (double.parse(totalBaseAmount.toStringAsFixed(2)) - double.parse(basePricePerUnit.toStringAsFixed(2)))
              .roundToTwoDecimals(),
      additionalAllowns: 0.0,
      priceIncludeVAT: double.parse(totalBaseAmount.toStringAsFixed(2)),
      promotionCode: itemPromotion?.promotionCode,
      promotionCodeId: itemPromotion?.promotionCodeId,
      promotionType: itemPromotion?.promotionType,
      promotionAmount: itemPromotion?.promotionAmount ?? 0.0,
      promotionName: itemPromotion?.promotionName ?? "",
      selectedFreeItemId: salesItem.selectedFreeItemId,
      selectedFreeProductName: salesItem.selectedFreeProductName,
      selectedFreeProductNameAr: salesItem.selectedFreeProductNameAr,
      selectedFreeProductQuantity: salesItem.selectedFreeProductQuantity,
      isPromotionDuplicated: salesItem.isPromotionDuplicated,
      selectedFreeProductPrice: salesItem.selectedFreeProductPrice,
      freeItemSelectionState: salesItem.freeItemSelectionState,
      selectedFreeUUid: uuid.v4(),
      comboMealItems: (item.comboItems != null && item.comboItems!.isNotEmpty)
          ? item.comboItems!
              .map((combo) => {
                    'id': uuid.v4(),
                    'menuItemId': combo.menuItemId,
                    'quantity': combo.quantity,
                    'price': combo.price,
                    'comboNameEn': combo.nameEn,
                    'comboNameAr': combo.nameAr,
                  })
              .toList()
          : null,
      variations: _buildVariationsFromCartItem(item),
    );
    salesItemsList.add(salesItemsModel);
  }

  final paymentTotals = ref.watch(paymentBreakdownProvider.notifier).paymentTotals;
  final salesPayMethodsList = <SalesPayMethodModel>[];
  final String tenant = await AppPreferences().getTenant();

  for (var entry in paymentTotals.entries) {
    int tenderId = entry.key;
    double totalAmount = (entry.value["total"] as num).toDouble();
    if (totalAmount > 0) {
      final payMethodModel = SalesPayMethodModel(
        id: null,
        orderId: '',
        nameEn: entry.value["enName"],
        nameAr: entry.value["arName"],
        amount: totalAmount,
        tenantId: tenant,
        tenderTypeId: tenderId,
        uniqueId: uuid.v4(),
      );
      salesPayMethodsList.add(payMethodModel);
    }
  }

  final SalesInvoice finalInvoice = SalesInvoice(
    salesOrderModel: salesOrderModel,
    salesOrderItems: salesItemsList,
    salesOrderPayMethods: salesPayMethodsList,
  );
  return finalInvoice;
}

List<Map<String, dynamic>>? _buildVariationsFromCartItem(CartItem item) {
  List<Map<String, dynamic>>? variations;

  if (item.variations.isNotEmpty) {
    variations = item.variations
        .map((variation) => {
              'variantId': variation.variationValue.variantId,
              'variantValueId': variation.variationValue.id,
              'variationNameEn': variation.variationEn?.name ?? '',
              'variationNameAr': variation.variationAr?.name ?? '',
              'variationPrice': variation.price?.price ?? 0.0,
              'mainTranslationAr': variation.mainTranslationAr?.name ?? '',
              'mainTranslationEn': variation.mainTranslationEn?.name ?? '',
            })
        .toList();
  }

  if (item.selectedVariants.isNotEmpty) {
    final selectedVariantMaps = item.selectedVariants
        .map((sv) => {
              'variantId': sv.variantId,
              'variantValueId': sv.variantValueId,
              'variationNameEn': sv.nameEn,
              'variationNameAr': sv.nameAr,
              'variationPrice': sv.isFree ? 0.0 : sv.price,
              'quantity': sv.quantity,
              'isFree': sv.isFree,
              'mainTranslationAr': '',
              'mainTranslationEn': '',
              'groupNameAr': sv.groupNameAr,
              'groupNameEn': sv.groupNameEn,
              'modifierNatureAr': sv.modifierNatureAr,
              'modifierNatureEn': sv.modifierNatureEn,
              'isModifier': sv.isModifier,
            })
        .toList();

    if (variations == null) {
      variations = selectedVariantMaps;
    } else {
      variations.addAll(selectedVariantMaps);
    }
  }

  return variations;
}
