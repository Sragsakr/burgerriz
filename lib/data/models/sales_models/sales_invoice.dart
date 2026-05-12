import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_paymethod_model.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:uuid/uuid.dart';

class SalesInvoice {
  SalesOrderModel salesOrderModel;
  List<SalesItemsModel> salesOrderItems;
  List<SalesPayMethodModel> salesOrderPayMethods;

  SalesInvoice({
    required this.salesOrderModel,
    required this.salesOrderItems,
    required this.salesOrderPayMethods,
  });
  Map<String, dynamic> toKdsBody() {
    const uuid = Uuid();
    final receiptNumber = salesOrderModel.receiptNumber ?? '';
    final invoiceId = 'INV-$receiptNumber';
    final numericOrderId = int.tryParse(receiptNumber) ?? receiptNumber.hashCode.abs();
    final kdsItems = <Map<String, dynamic>>[];
    var sortOrder = 1;

    for (final item in salesOrderItems) {
      final hasComboChildren = item.comboMealItems != null && item.comboMealItems!.isNotEmpty;

      if (hasComboChildren) {
        for (final comboChild in item.comboMealItems!) {
          final childQty = _parseQuantity(comboChild['quantity']);
          final parentQty = _parseQuantity(item.quantity);
          final totalQty = childQty * parentQty;

          kdsItems.add({
            "sortOrder": sortOrder,
            "itemGuid": uuid.v4(),

            "refItemGuid": "",
            "action": "new",
            "customerNo": "P1",
            "itemStatus": "Pending",
            "name": comboChild['comboNameAr']?.toString() ?? "",
            "nameEn": comboChild['comboNameEn']?.toString() ?? "",
            "quantity": _formatQuantity(totalQty),
            "orderRefId": invoiceId,
            "notes": "",
            "menuItemId": comboChild['menuItemId']?.toString() ?? "",
            "isCompo": true,
            "compoNameAr": item.productNameAr,
            "compoNameEn": item.productNameEn,
            "modifires": "",
            "modifiresEn": "",
          });
        }
        continue;
      }

      final modifierStrings = _buildModifiers(item.variations);
      final itemGuid = item.uniqueId.isNotEmpty ? item.uniqueId : uuid.v4();
      kdsItems.add({
        "sortOrder": sortOrder,
        "itemGuid": itemGuid,
        "refItemGuid": "",
        "action": "new",
        "customerNo": "P1",
        "itemStatus": "Pending",
        "name": item.productNameAr,
        "nameEn": item.productNameEn,
        "quantity": item.quantity.toString(),
        "orderRefId": invoiceId,
        "notes": item.note,
        "menuItemId": item.productId,
        "isCompo": false,
        "compoNameAr": "",
        "compoNameEn": "",
        "modifires": modifierStrings.$1,
        "modifiresEn": modifierStrings.$2,
      });
    }

    return {
      "id": numericOrderId,
      "invoiceId": invoiceId,
      "orderGuid":salesOrderModel.uuid,
      "order_id": numericOrderId,
      "created_at": salesOrderModel.createdAt,
      "status": "Pending",
      "table_number": "",
      "customer_name": "",
      "items": kdsItems,
    };
  }

  (String, String) _buildModifiers(List<Map<String, dynamic>>? variations) {
    if (variations == null || variations.isEmpty) return ("", "");

    final modifiersAr = <String>[];
    final modifiersEn = <String>[];

    for (final variation in variations) {
      final nameAr = variation['variationNameAr']?.toString() ?? '';
      final nameEn = variation['variationNameEn']?.toString() ?? '';
      final qty = _parseQuantity(variation['quantity']);
      final repeat = qty <= 0 ? 1 : qty.round();

      for (var i = 0; i < repeat; i++) {
        if (nameAr.isNotEmpty) modifiersAr.add(nameAr);
        if (nameEn.isNotEmpty) modifiersEn.add(nameEn);
      }
    }

    return (modifiersAr.join(','), modifiersEn.join(','));
  }

  double _parseQuantity(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _formatQuantity(double value) {
    return value == value.roundToDouble() ? value.round().toString() : value.toString();
  }

  // Create a deep copy of the SalesInvoice
  SalesInvoice copy() {
    return SalesInvoice(
      salesOrderModel: SalesOrderModel(
        id: salesOrderModel.id,
        invoiceId: salesOrderModel.invoiceId,
        orderNumber: salesOrderModel.orderNumber,
        receiptNumber: salesOrderModel.receiptNumber,
        refReceiptNumber: salesOrderModel.refReceiptNumber,
        createdAt: salesOrderModel.createdAt,
        workDate: salesOrderModel.workDate,
        updatedAt: salesOrderModel.updatedAt,
        deletedAt: salesOrderModel.deletedAt,
        totalAmount: salesOrderModel.totalAmount,
        subTotal: salesOrderModel.subTotal,
        tax: salesOrderModel.tax,
        totalAmountBeforeDiscount: salesOrderModel.totalAmountBeforeDiscount,
        subTotalBeforeDiscount: salesOrderModel.subTotalBeforeDiscount,
        taxBeforeDiscount: salesOrderModel.taxBeforeDiscount,
        note: salesOrderModel.note,
        isRefund: salesOrderModel.isRefund,
        haveRefund: salesOrderModel.haveRefund,
        userId: salesOrderModel.userId,
        cashierShiftId: salesOrderModel.cashierShiftId,
        tenantId: salesOrderModel.tenantId,
        refSaleTransactionModelId: salesOrderModel.refSaleTransactionModelId,
        customerPhone: salesOrderModel.customerPhone,
        isBackOfficeSync: salesOrderModel.isBackOfficeSync,
        isZactaSync: salesOrderModel.isZactaSync,
        paymentMethod: salesOrderModel.paymentMethod,
        saleTypeId: salesOrderModel.saleTypeId,
        zatcaReturnedFromTransactionId:
            salesOrderModel.zatcaReturnedFromTransactionId,
        discountType: salesOrderModel.discountType,
        discountValue: salesOrderModel.discountValue,
        discount: salesOrderModel.discount,
        discountAmount: salesOrderModel.discountAmount,
        uuid: salesOrderModel.uuid,
        cashierName: salesOrderModel.cashierName,
        saleNotificationDetailId: salesOrderModel.saleNotificationDetailId,
        refundResonId: salesOrderModel.refundResonId,
        promotionCode: salesOrderModel.promotionCode,
        promotionType: salesOrderModel.promotionType,
        promotionValue: salesOrderModel.promotionValue,
        promotionAmount: salesOrderModel.promotionAmount,
        promotionName: salesOrderModel.promotionName,
      ),
      salesOrderItems: salesOrderItems
          .map((item) => SalesItemsModel(
                id: item.id,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
                productId: item.productId,
                categoryId: item.categoryId,
                productNameEn: item.productNameEn,
                productNameAr: item.productNameAr,
                unitOfMeasureId: item.unitOfMeasureId,
                quantity: item.quantity,
                price: item.price,
                tax: item.tax,
                total: item.total,
                note: item.note,
                isRefund: item.isRefund,
                userId: item.userId,
                tenantId: item.tenantId,
                invoiceId: item.invoiceId,
                selectedFreeUUid: item.selectedFreeUUid,
                uniqueId: item.uniqueId,
                isExclusive: item.isExclusive,
                promotionId: item.promotionId,
                promotionCodeId: item.promotionCodeId,
                promotionCode: item.promotionCode,
                promotionType: item.promotionType,
                promotionValue: item.promotionValue,
                promotionAmount: item.promotionAmount,
                promotionName: item.promotionName,
                vatBeforeDiscount: item.vatBeforeDiscount,
                discount: item.discount,
                loyaltyDiscount: item.loyaltyDiscount,
                additionalAllowns: item.additionalAllowns,
                priceIncludeVAT: item.priceIncludeVAT,
                variations: item.variations,
                freeItemSelectionState: item.freeItemSelectionState,
                selectedFreeProductId: item.selectedFreeProductId,
                selectedFreeProductName: item.selectedFreeProductName,
                selectedFreeProductNameAr: item.selectedFreeProductNameAr,
                selectedFreeProductQuantity: item.selectedFreeProductQuantity,
                selectedFreeProductPrice: item.selectedFreeProductPrice,
                selectedFreeItemId: item.selectedFreeItemId,
                isPromotionDuplicated: item.isPromotionDuplicated,
              ))
          .toList(),
      salesOrderPayMethods: salesOrderPayMethods
          .map((payment) => SalesPayMethodModel(
                id: payment.id,
                nameEn: payment.nameEn,
                nameAr: payment.nameAr,
                amount: payment.amount,
                tenderTypeId: payment.tenderTypeId,
                orderId: payment.orderId,
                uniqueId: payment.uniqueId,
                tenantId: payment.tenantId,
              ))
          .toList(),
    );
  }

  // Helper: Calculate Invoice Prices (subTotalBeforeDiscount, vatBeforeDiscount, subTotalAfterDiscount, vatAfterDiscount, discount, promotionAmount)
  ItemPrices calculateInvoicePrices() {
    return _calculateInvoicePricesInternal(clampNegative: false);
  }

  // Helper: Calculate Invoice Prices for testing (allows negative values)
  ItemPrices calculateInvoicePricesForTesting() {
    print('=== calculateInvoicePricesForTesting called ===');
    final result = _calculateInvoicePricesInternal(clampNegative: false);
    print(
        'calculateInvoicePricesForTesting result - subtotal before discount: ${result.subTotalBeforeDiscount}');
    print(
        'calculateInvoicePricesForTesting result - subtotal after discount: ${result.subTotalAfterDiscount}');
    print(
        'calculateInvoicePricesForTesting result - VAT after discount: ${result.vatAfterDiscount}');
    print('===============================================');
    return result;
  }

  // Internal calculation method
  ItemPrices _calculateInvoicePricesInternal({required bool clampNegative}) {
    const double taxRate = 0.15;

    // Calculate totals from all items
    double subTotalBeforeDiscount = 0.0;
    double totalVatBeforeDiscount = 0.0;
    double totalDiscount = 0.0;
    double totalPromotionAmount = 0.0;
    double totalPromotionValue = 0.0;
    double totalItemsVat = 0.0;

    print('=== Invoice Price Calculation Debug ===');
    print('Number of items: ${salesOrderItems.length}');

    // Process each item in the invoice
    for (SalesItemsModel item in salesOrderItems) {
      print('Processing item: ${item.productNameEn}');
      print('Item price: ${item.price}');
      print('Item quantity: ${item.quantity}');
      print('Item isExclusive: ${item.isExclusive}');

      ItemPrices itemPrices = item.calculateItemPrices();

      print(
          'Item subtotal before discount: ${itemPrices.subTotalBeforeDiscount}');
      print('Item Vat before discount: ${itemPrices.vatBeforeDiscount}');
      print(
          'Item subtotal after discount: ${itemPrices.subTotalAfterDiscount}');
      print('Item Vat after discount: ${itemPrices.vatAfterDiscount}');
      print('Item discount: ${itemPrices.discount}');
      print('Item promotion amount: ${itemPrices.promotionAmount}');
      print('Item promotion value: ${itemPrices.promotionValue}');
      totalVatBeforeDiscount += itemPrices.vatBeforeDiscount;
      subTotalBeforeDiscount += itemPrices.subTotalBeforeDiscount;
      totalDiscount += itemPrices.discount;
      totalPromotionAmount += itemPrices.promotionAmount;
      totalPromotionValue += itemPrices.promotionValue;
      totalItemsVat += (itemPrices.vatAfterDiscount);
      // if (item.promotionType != null && item.promotionType != 0) {
      //   totalPromotionValue += PromotionHelpers.getPromotionValue(
      //       item.promotionType!,
      //       item.promotionAmount!,
      //       double.parse(item.price) / 1.15);
      // }
    }
    print('totalItemsVat: $totalItemsVat');
    print('Total promotion value: $totalPromotionValue');
    print('Total promotion amounts: $totalPromotionAmount');
    dPrint("###@salesOrderModel: ${salesOrderModel.toMap()}");
    // Add order-level discount and promotion from salesOrderModel
    double orderDiscount = salesOrderModel.discountAmount ?? 0.0;
    double orderPromotionValue = salesOrderModel.promotionValue ?? 0.0;
    double orderPromotionAmount = salesOrderModel.promotionValue ?? 0.0;

    print('orderPromotionAmount: ${salesOrderModel.promotionValue}');
    print('Order discount: $orderDiscount');
    print('Order promotion value: $orderPromotionValue');

    // Calculate total discount and promotion
    double totalDiscountAmount = totalDiscount + orderDiscount;
    double totalPromotionAmountFinal =
        totalPromotionAmount + orderPromotionAmount;
    double totalPromotionValueFinal = totalPromotionValue + orderPromotionValue;
    // Calculate subtotal after all discounts and promotions
    double subTotalAfterDiscount =
        subTotalBeforeDiscount - totalDiscountAmount - totalPromotionValueFinal;

    // Ensure subtotal doesn't go negative (only if clamping is enabled)
    if (clampNegative && subTotalAfterDiscount < 0) {
      subTotalAfterDiscount = 0.0;
    }
    double discountVat = ((totalDiscountAmount + orderPromotionValue) * taxRate)
        .roundToTwoDecimals();
    double totalItemsDIscVat = ((totalItemsVat) * taxRate).roundToTwoDecimals();
    dPrint("totalItemsDIscVat is $totalItemsVat");
    double vatAfterDiscount = totalItemsVat - discountVat;
    double total =
        (subTotalAfterDiscount + vatAfterDiscount).roundToTwoDecimals();

    double total2 = (subTotalBeforeDiscount +
        vatAfterDiscount -
        totalDiscountAmount -
        totalPromotionValueFinal);
    dPrint('#Final Total1: ${total} $total2');
    // dPrint('#Final Total2: ${total2}');

    dPrint('Final subtotal before discount: $subTotalBeforeDiscount');

    dPrint('Final subtotal after discount: $subTotalAfterDiscount ');
    dPrint('Final VAT before discount: $totalVatBeforeDiscount');
    dPrint('Final VAT after discount: $vatAfterDiscount');
    dPrint('Final discount Vat: $discountVat');
    dPrint('Total discount: $totalDiscountAmount');
    dPrint('Total promotion amount: $totalPromotionAmountFinal');
    dPrint('Total promotion value: $totalPromotionValueFinal');
    dPrint('Final Total: $total');
    dPrint(
        '🔢 Precision check - subTotalAfterDiscount: $subTotalAfterDiscount, vatAfterDiscount: $vatAfterDiscount');
    dPrint(
        '🔢 Final total calculation: $subTotalAfterDiscount + $vatAfterDiscount = $total');
    dPrint('=====================================');

    return ItemPrices(
      subTotalBeforeDiscount: subTotalBeforeDiscount,
      vatBeforeDiscount: totalVatBeforeDiscount,
      subTotalAfterDiscount: subTotalAfterDiscount,
      vatAfterDiscount: vatAfterDiscount,
      discount: totalDiscountAmount,
      promotionAmount: totalPromotionAmountFinal,
      promotionValue: totalPromotionValueFinal,
      total: total,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salesOrderModel': salesOrderModel.toMap(),
      'salesOrderItems': salesOrderItems.map((item) => item.toMap()).toList(),
      'salesOrderPayMethods':
          salesOrderPayMethods.map((method) => method.toMap()).toList(),
    };
  }
}
