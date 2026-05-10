import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/enums/discount_enum.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/free_item_service.dart';
import 'package:kiosk_point_of_sale/data/NearPay/nearpay_api_services.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/payment_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_vm.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/providers/promotion_provider.dart';
import 'package:kiosk_point_of_sale/repository/promotions/promotions_services.dart';

class OrderSummary {
  final SalesInvoice salesInvoice;
  final double subtotal;
  final double discountAmount;
  final double promotionAmount;
  final String? promotionName;
  final double promotionValue;
  final double taxAmount;
  double totalAmount;
  final double totalPaid;
  final double remaining;
  final double change;
  // taxBeforeDiscount
  final double taxBeforeDiscount;
  // totalAmountBeforeDiscount
  final double totalAmountBeforeDiscount;
  // subTotalBeforeDiscount
  final double subTotalBeforeDiscount;
  // orderPromotionValue
  final double orderPromotionValue;
  // orderpromotionType
  final int? orderPromotionType;
  // orderpromotionAmount
  final double orderPromotionAmount;
  // orderpromotionCode
  final String? orderPromotionCode;
//for every item
  // itemPromotions - Map of itemId to promotion data
  final Map<int?, ItemPromotionData> itemPromotions;
  // Flag to indicate if promotions were removed due to negative total
  final bool promotionsRemoved;
  // Validation messages to show to user
  final List<String> validationMessages;
  // Discount type and value
  final int? discountType;
  final double discount;
  final String? customerId;

  OrderSummary({
    required this.salesInvoice,
    required this.subtotal,
    required this.promotionName,
    required this.discountAmount,
    required this.promotionAmount,
    required this.promotionValue,
    required this.taxAmount,
    required this.totalAmount,
    required this.totalPaid,
    required this.remaining,
    required this.change,
    required this.taxBeforeDiscount,
    required this.totalAmountBeforeDiscount,
    required this.subTotalBeforeDiscount,
    required this.orderPromotionValue,
    this.orderPromotionType,
    required this.orderPromotionAmount,
    this.orderPromotionCode,
    required this.itemPromotions,
    required this.promotionsRemoved,
    required this.validationMessages,
    this.discountType,
    required this.discount,
    required this.customerId,
  });

// toJson
  Map<String, dynamic> toJson() {
    return {
      'salesInvoice': salesInvoice.toJson(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'promotionAmount': promotionAmount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'remaining': remaining,
      'change': change,
      'taxBeforeDiscount': taxBeforeDiscount,
      'totalAmountBeforeDiscount': totalAmountBeforeDiscount,
      'subTotalBeforeDiscount': subTotalBeforeDiscount,
      'orderPromotionValue': orderPromotionValue,
      'orderPromotionType': orderPromotionType,
      'orderPromotionAmount': orderPromotionAmount,
      'orderPromotionCode': orderPromotionCode,
      'itemPromotions': itemPromotions,
      'promotionsRemoved': promotionsRemoved,
      'validationMessages': validationMessages,
      'discountType': discountType,
      'discount': discount,
      'customerId': customerId,
    };
  }
}

class ItemPromotionData {
  final double promotionValue;
  final int? promotionType;
  final double promotionAmount;
  final String? promotionCode;
  final int? promotionId;
  final int? promotionCodeId;
  final String? promotionName;

  ItemPromotionData({
    required this.promotionValue,
    this.promotionType,
    required this.promotionAmount,
    this.promotionCode,
    required this.promotionCodeId,
    this.promotionId,
    this.promotionName,
  });
}

class OrderCalculator {
  static const double TAX_RATE = 0.15;
  static String? _lastShownMessage;
  static DateTime? _lastMessageTime;

  /// Creates user-friendly validation messages
  static String _createValidationMessage(String key, [List<String> params = const []]) {
    switch (key) {
      case 'empty_cart':
        return translator(
            arText: "السلة فارغة. يرجى إضافة منتجات قبل المتابعة.",
            enText: "Cart is empty. Please add items before proceeding.");
      case 'negative_discount':
        return translator(
            arText: "قيمة الخصم لا يمكن أن تكون سالبة.",
            enText: "Discount value cannot be negative.");
      case 'excessive_percentage':
        return translator(
            arText: "نسبة الخصم لا يمكن أن تتجاوز 100%.",
            enText: "Percentage discount cannot exceed 100%.");
      case 'discount_exceeds_subtotal':
        return translator(
            arText: "مبلغ الخصم لا يمكن أن يتجاوز المجموع الفرعي.",
            enText: "Discount amount cannot exceed subtotal.");
      case 'negative_total':
        return translator(
            arText: "المبلغ الإجمالي كان سالباً. تم تعديل العروض والخصومات.",
            enText: "Total amount was negative. Promotions and discounts have been adjusted.");
      case 'discount_removed':
        return translator(
            arText: "تم إزالة الخصم لمنع المبلغ السالب.",
            enText: "Discount has been removed to prevent negative total.");
      case 'no_payment':
        return translator(
            arText: "لم يتم اختيار طريقة دفع.", enText: "No payment method selected.");
      case 'negative_payment':
        return translator(
            arText: "مبلغ الدفع لا يمكن أن يكون سالباً.",
            enText: "Payment amount cannot be negative.");
      case 'excessive_promotion':
        return translator(
            arText: "مبلغ العرض مرتفع جداً. يرجى التحقق.",
            enText: "Promotion amount is very high. Please verify.");
      case 'zero_total':
        return translator(
            arText: "المبلغ الإجمالي يجب أن يكون أكبر من صفر.",
            enText: "Total amount must be greater than zero.");
      case 'invalid_quantity':
        return translator(
            arText: "المنتج ${params.isNotEmpty ? params[0] : ''}: الكمية يجب أن تكون أكبر من صفر.",
            enText:
                "Item ${params.isNotEmpty ? params[0] : ''}: Quantity must be greater than zero.");
      case 'negative_price':
        return translator(
            arText: "المنتج ${params.isNotEmpty ? params[0] : ''}: السعر لا يمكن أن يكون سالباً.",
            enText: "Item ${params.isNotEmpty ? params[0] : ''}: Price cannot be negative.");
      case 'zero_price':
        return translator(
            arText: "المنتج ${params.isNotEmpty ? params[0] : ''}: السعر لا يمكن أن يكون صفر.",
            enText: "Item ${params.isNotEmpty ? params[0] : ''}: Price cannot be zero.");
      case 'negative_payment_amount':
        return translator(
            arText: "الدفع ${params.isNotEmpty ? params[0] : ''}: المبلغ لا يمكن أن يكون سالباً.",
            enText: "Payment ${params.isNotEmpty ? params[0] : ''}: Amount cannot be negative.");
      default:
        return translator(arText: "حدث خطأ في التحقق.", enText: "Validation error occurred.");
    }
  }

  /// Display validation messages to user
  static Future<void> _showValidationMessages(List<String> messages, BuildContext context) async {
    dPrint("⚠️  Showing validation messages: $messages");

    if (messages.isEmpty) {
      dPrint("✅ No validation messages to show");
      return;
    }

    // Show warnings as SnackBar (non-blocking)
    if (messages.isNotEmpty) {
      String warningMessage = messages.join(' • ');
      dPrint("📢 Warning message: $warningMessage");

      // Prevent duplicate messages from showing repeatedly
      final now = DateTime.now();
      if (_lastShownMessage == warningMessage &&
          _lastMessageTime != null &&
          now.difference(_lastMessageTime!).inSeconds < 5) {
        // Same message shown recently, skip it
        dPrint("⏭️  Skipping duplicate message (shown recently)");
        return;
      }

      // Update tracking
      _lastShownMessage = warningMessage;
      _lastMessageTime = now;
      dPrint("📱 Displaying SnackBar with warning message");

      // Use SnackBar instead of dialog to prevent UI loops
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  warningMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      dPrint("✅ SnackBar displayed successfully");
    }
  }

  /// Calculates the complete order summary including subtotal, discounts, promotions, and taxes
  ///
  /// [ref] - Riverpod reference for accessing providers
  /// [cartItems] - List of items in the cart
  /// [discountType] - Type of discount (fixed value or percentage)
  /// [discountValue] - Value of the discount
  /// [payments] - List of payment methods and amounts
  /// [decimalsSetting] - Decimal precision setting
  /// [context] - BuildContext for showing validation messages (optional)
  ///
  /// Returns an [OrderSummary] object with all calculated values
  ///
  /// Throws [ArgumentError] if cart is empty or total amount is negative
  static Future<OrderSummary> calculate({
    required Ref ref,
    required CartNotifier cartNotifier,
    required List<CartItem> cartItems,
    required DiscountType? discountType,
    required double discountValue,
    required DiscountType customerDiscountType,
    required String? customerId,
    required double customerDiscountValue,
    required List<PaymentItem> payments,
    required DecimalsNumbers decimalsSetting,
    required BuildContext context,
  }) async {
    dPrint('=== OrderCalculator.calculate START ===');
    dPrint('📊 Input Parameters:');
    dPrint('   - Cart items count: ${cartItems.length}');
    dPrint('   - Discount type: $discountType');
    dPrint('   - customerDiscountValue  : $customerDiscountValue');
    dPrint('   - Discount value: $discountValue');
    dPrint('   - Payments count: ${payments.length}');
    dPrint('   - Decimals setting: $decimalsSetting');

    // Early exit if cart is empty
    if (cartItems.isEmpty) {
      dPrint('⚠️  Cart is empty - returning early');
      return _createEmptyOrderSummary();
    }

    final manualPromos = ref.watch(appliedPromotionsProvider);
    dPrint('🎯 Manual promotions count: ${manualPromos.length}');

    final List<String> validationMessages = [];

    // Step 1: Calculate basic values
    dPrint('🔢 Step 1: Calculating basic values...');
    final CalculationData calcData = _calculateBasicValues(
      cartItems: cartItems,
      discountType: null,
      discountValue: 0.0,
      customerDiscountType: customerDiscountType,
      customerDiscountValue: 0.0,
    );
    dPrint('✅ Basic values calculated:');
    dPrint('   - Subtotal: ${calcData.subtotal}');
    dPrint('   - Discount amount: ${calcData.discountAmount}');
    dPrint('   - Discount amount: ${calcData.discountValue}');

    // Step 2: Build sales invoice
    dPrint('📋 Step 2: Building sales invoice...');
    final SalesInvoice salesInvoice = _buildSalesInvoice(
      cartItems: cartItems,
      calcData: calcData,
    );
    dPrint(
        "sales order items after promotions: ${salesInvoice.salesOrderItems.map((e) => e.freeItemSelectionState)}");

    dPrint('✅ Sales invoice built with ${salesInvoice.salesOrderItems.length} items');

    // Step 3: Apply promotions and calculate final values
    dPrint('🎁 Step 3: Applying promotions...');

    final PromotionResult promotionResult = await _applyPromotions(
      salesInvoice: salesInvoice,
      manualPromos: manualPromos,
      subtotal: calcData.subtotal,
      ref: ref,
      customerDiscountValue: customerDiscountValue,
      cartNotifier: cartNotifier,
    );
    dPrint('✅ Promotions applied:');
    dPrint('   - Promotion amount: ${promotionResult.promotionAmount}');
    dPrint('   - Promotion value: ${promotionResult.promotionValue}');
    dPrint('   - Tax amount: ${promotionResult.taxAmount}');
    dPrint('   - Total amount: ${promotionResult.totalAmount}');

    // Step 4: Calculate payment totals
    dPrint('💳 Step 4: Calculating payment totals...');

    final totalAmount = promotionResult.totalAmount;
    final PaymentData paymentData = _calculatePaymentTotals(
      payments: payments,
      totalAmount: totalAmount,
    );
    dPrint('✅ Payment totals calculated:');
    dPrint('   - totalAmount: $totalAmount');
    dPrint('   - Total paid: ${paymentData.totalPaid}');
    dPrint('   - Remaining: ${paymentData.remaining}');
    dPrint('   - Change: ${paymentData.change}');

    // Step 5: Show validation messages if any
    if (validationMessages.isNotEmpty) {
      dPrint('⚠️  Step 5: Showing validation messages...');
      await _showValidationMessages(validationMessages, context);
    }
    var tempSaleInvoice = promotionResult.finalInvoice.copy();
    var updatedSaleInvoice = applyNormalDiscount(
        salesInvoice: tempSaleInvoice,
        discountType: discountType,
        discountAmount: discountValue,
        customerDiscountType: customerDiscountType,
        customerDiscountAmount: customerDiscountValue,
        promotionValue: promotionResult.promotionValue,
        subTotalBeforePromotion: promotionResult.finalPrices.subTotalBeforeDiscount);
    bool withDiscount = discountValue > 0 || customerDiscountValue > 0;
    final finalPricesAfterDiscount = ItemPrices(
        subTotalBeforeDiscount: promotionResult.finalPrices.subTotalBeforeDiscount,
        vatBeforeDiscount:
            double.tryParse(updatedSaleInvoice.salesOrderModel.taxBeforeDiscount ?? '0.0') ?? 0.0,
        subTotalAfterDiscount:
            double.tryParse(updatedSaleInvoice.salesOrderModel.subTotal ?? '0.0') ?? 0.0,
        vatAfterDiscount: double.tryParse(updatedSaleInvoice.salesOrderModel.tax ?? '0.0') ?? 0.0,
        discount: updatedSaleInvoice.salesOrderModel.discountValue ?? 0.0,
        promotionAmount: promotionResult.finalPrices.promotionAmount,
        promotionValue: promotionResult.finalPrices.promotionValue,
        total: double.parse(updatedSaleInvoice.salesOrderModel.totalAmount));

    // Step 6: Build final result

    final OrderSummary result = _buildOrderSummary(
      finalInvoice: promotionResult.finalInvoice,
      finalPrices: withDiscount ? finalPricesAfterDiscount : promotionResult.finalPrices,
      paymentData: paymentData,
      promotionAmount: promotionResult.promotionAmount,
      promotionValue: promotionResult.promotionValue,
      promotionName: promotionResult.promotionName ?? "",
      validationMessages: validationMessages,
      discountType: discountType,
      discountValue:
          withDiscount ? (updatedSaleInvoice.salesOrderModel.discountValue ?? 0.0) : discountValue,
      discountAmount: withDiscount
          ? updatedSaleInvoice.salesOrderModel.discountAmount ?? 0.0
          : calcData.discountAmount,
      decimalsSetting: decimalsSetting,
      customerId: customerId,
    );

    dPrint('🎉 OrderCalculator.calculate COMPLETED SUCCESSFULLY');
    dPrint('📈 Final Summary:');
    dPrint('   - Subtotal: ${result.subtotal}');
    dPrint('   - Discount2: ${result.discountAmount}');
    dPrint('   - Discount3: ${result.discount}');

    dPrint('   - Promotions: ${result.promotionAmount}');
    dPrint('   - Promotions value: ${result.promotionValue}');
    dPrint('   - Tax: ${result.taxAmount}');
    dPrint('   - Total: ${result.totalAmount}');
    dPrint('   - Paid: ${result.totalPaid}');
    dPrint('   - Remaining: ${result.remaining}');
    dPrint('   - Change: ${result.change}');
    dPrint('=== OrderCalculator.calculate END ===');
    // result.totalAmount = (result.subtotal -
    //     (result.discountAmount + result.promotionValue) +
    //     result.taxAmount);

    return result;
  }

  /// Creates an empty order summary for empty cart scenarios
  static OrderSummary _createEmptyOrderSummary() {
    dPrint('📭 Creating empty order summary for empty cart');
    return OrderSummary(
      salesInvoice: _createEmptySalesInvoice(),
      subtotal: 0.0,
      discountAmount: 0.0,
      promotionAmount: 0.0,
      taxAmount: 0.0,
      totalAmount: 0.0,
      totalPaid: 0.0,
      remaining: 0.0,
      change: 0.0,
      taxBeforeDiscount: 0.0,
      promotionValue: 0.0,
      totalAmountBeforeDiscount: 0.0,
      subTotalBeforeDiscount: 0.0,
      orderPromotionValue: 0.0,
      orderPromotionType: null,
      orderPromotionAmount: 0.0,
      orderPromotionCode: null,
      itemPromotions: {},
      promotionsRemoved: false,
      validationMessages: [],
      discountType: null,
      promotionName: "",
      discount: 0.0,
      customerId: null,
    );
  }

  /// Creates an empty sales invoice
  static SalesInvoice _createEmptySalesInvoice() {
    dPrint('📄 Creating empty sales invoice');
    return SalesInvoice(
      salesOrderModel: _createEmptySalesOrderModel(),
      salesOrderItems: [],
      salesOrderPayMethods: [],
    );
  }

  /// Creates an empty sales order model
  static SalesOrderModel _createEmptySalesOrderModel() {
    dPrint('📋 Creating empty sales order model');
    return SalesOrderModel(
      id: null,
      createdAt: '',
      updatedAt: '',
      deletedAt: '',
      cashierName: '',
      invoiceId: null,
      customerId: null,
      haveRefund: 0,
      cashierShiftId: 0,
      workDate: '',
      subTotalBeforeDiscount: '0.00',
      totalAmountBeforeDiscount: '',
      taxBeforeDiscount: '',
      subTotal: '0.00',
      tax: '',
      totalAmount: '',
      note: '',
      isRefund: 0,
      change: 0,
      userId: '',
      tenantId: '',
      discountType: 0,
      discountValue: 0,
      discount: 0,
      discountAmount: 0,
      uuid: '',
      orderNumber: '',
      receiptNumber: '',
      isBackOfficeSync: 0,
      isZactaSync: 0,
      customerPhone: '',
      paymentMethod: 0,
      saleTypeId: 0,
      saleNotificationDetailId: '',
      refundResonId: '',
    );
  }

  /// Calculates basic values like subtotal and discount amount
  static CalculationData _calculateBasicValues({
    required List<CartItem> cartItems,
    required DiscountType? discountType,
    required double discountValue,
    required DiscountType customerDiscountType,
    required double customerDiscountValue,
  }) {
    dPrint('🧮 Calculating basic values...');

    // Calculate subtotal
    final double subtotal = cartItems.fold(0, (sum, item) {
      final priceWithoutTax = item.inclusive ? item.price : item.price / (1.15);
      final itemTotal = priceWithoutTax * item.quantity;
      dPrint(
          '   📦 Item: ${item.nameEn} - Qty: ${item.quantity}, Price: ${item.price}, Total: $itemTotal');
      return sum + itemTotal;
    });
    dPrint('💰 Subtotal calculated: $subtotal');

    // Calculate discount amount
    double discountAmount = 0.0;
    if (discountValue > 0) {
      if (discountType == DiscountType.fixedValue) {
        discountAmount = discountValue;
        dPrint('💸 Fixed discount applied: $discountAmount');
      } else if (discountType == DiscountType.percentage) {
        discountAmount = subtotal * (discountValue / 100);
        dPrint('💸 Percentage discount applied: $discountValue% = $discountAmount');
      }
    } else {
      dPrint('💸 No discount applied');
    }
    // Calculate discount amount
    double customerDiscountAmount = 0.0;
    if (customerDiscountValue > 0) {
      if (customerDiscountType == DiscountType.fixedValue) {
        customerDiscountAmount = customerDiscountValue;
        dPrint('💸 Fixed customerDiscountAmount applied: $customerDiscountAmount');
      } else if (customerDiscountType == DiscountType.percentage) {
        customerDiscountAmount = subtotal * (customerDiscountValue / 100);
        dPrint('💸 Percentage discount applied: $customerDiscountValue% = $customerDiscountAmount');
      }
    } else {
      dPrint('💸 No discount applied');
    }
    discountAmount = discountAmount + customerDiscountAmount;
    dPrint('✅ Basic values calculation completed');
    return CalculationData(
      subtotal: subtotal,
      discountAmount: discountAmount,
      discountType: discountType,
      discountValue: discountAmount,
    );
  }

  /// need to test this function
  static SalesInvoice applyNormalDiscount({
    required SalesInvoice salesInvoice,
    required DiscountType? discountType,
    required double discountAmount,
    required DiscountType customerDiscountType,
    required double customerDiscountAmount,
    required double promotionValue,
    required double subTotalBeforePromotion,
  }) {
    dPrint('🧮 Calculating normal discount...');

    // Calculate subtotal
    final double subtotal = subTotalBeforePromotion - promotionValue;
    dPrint(
        '💰 Subtotal  After $subtotal 💰 Subtotal before discount: $subTotalBeforePromotion  💰 promotionValue: $promotionValue');

    // Calculate discount amount
    double discountValue = 0.0;
    if (discountAmount > 0) {
      if (discountType == DiscountType.fixedValue) {
        discountValue = discountAmount;
        dPrint('💸 Fixed discount applied: $discountAmount');
      } else if (discountType == DiscountType.percentage) {
        discountValue = subtotal * (discountAmount / 100);
        dPrint('💸 Percentage discount applied: $discountValue% = $discountAmount');
      }
    } else {
      dPrint('💸 No discount applied');
    }
    // Calculate discount amount
    double customerDiscountValue = 0.0;
    if (customerDiscountAmount > 0) {
      if (customerDiscountType == DiscountType.fixedValue) {
        customerDiscountValue = customerDiscountAmount;
        dPrint('💸 Fixed customerDiscountAmount applied: $customerDiscountAmount');
      } else if (customerDiscountType == DiscountType.percentage) {
        customerDiscountValue = subtotal * (customerDiscountAmount / 100);
        dPrint('💸 Percentage discount applied: $customerDiscountValue% = $customerDiscountAmount');
      }
    } else {
      dPrint('💸 No discount applied');
    }
    discountValue = discountValue + customerDiscountValue;
    final subTotalAfterDiscount = subtotal - discountValue;
    final totalAmount = subTotalAfterDiscount * 1.15;
    final tax = totalAmount - subTotalAfterDiscount;
    dPrint(
        '💰  Tax calculated: $tax  , subTotalAfterDiscount: $subTotalAfterDiscount , discountValue: $discountValue, discountAmount: $discountAmount totalAmount: $totalAmount');
    dPrint('✅ Basic values calculation completed');

    salesInvoice.salesOrderModel.tax = tax.toString();
    salesInvoice.salesOrderModel.totalAmount = totalAmount.toString();
    salesInvoice.salesOrderModel.discountType = _getDiscountTypeValue(discountType);
    salesInvoice.salesOrderModel.discountValue = discountValue;
    salesInvoice.salesOrderModel.discount = discountAmount;
    salesInvoice.salesOrderModel.discountAmount = discountAmount;

    dPrint(
        "✅ Normal discount applied to sales invoice ${salesInvoice.salesOrderModel.discountAmount}${salesInvoice.salesOrderModel.totalAmount}${salesInvoice.salesOrderModel.tax}${salesInvoice.salesOrderModel.subTotal}${salesInvoice.salesOrderModel.discountType}${salesInvoice.salesOrderModel.discountValue}");
    return salesInvoice;
  }

  /// Builds a sales invoice from cart items and calculation data
  static SalesInvoice _buildSalesInvoice({
    required List<CartItem> cartItems,
    required CalculationData calcData,
  }) {
    dPrint('🏗️  Building sales invoice...');

    final salesOrderModel = SalesOrderModel(
      id: null,
      createdAt: '',
      updatedAt: '',
      deletedAt: '',
      cashierName: '',
      invoiceId: null,
      customerId: null,
      haveRefund: 0,
      cashierShiftId: 0,
      workDate: '',
      subTotalBeforeDiscount: calcData.subtotal.toStringAsFixed(2),
      totalAmountBeforeDiscount: '',
      taxBeforeDiscount: '',
      subTotal: calcData.subtotal.toStringAsFixed(2),
      tax: '',
      totalAmount: '',
      note: '',
      isRefund: 0,
      userId: '',
      tenantId: '',
      discountType: _getDiscountTypeValue(calcData.discountType),
      discountValue: calcData.discountValue,
      discount: calcData.discountAmount,
      discountAmount: calcData.discountAmount,
      uuid: '',
      orderNumber: '',
      receiptNumber: '',
      isBackOfficeSync: 0,
      change: 0,
      isZactaSync: 0,
      customerPhone: '',
      paymentMethod: 0,
      saleTypeId: 0,
      saleNotificationDetailId: '',
      refundResonId: '',
    );

    dPrint(
        '📋 Sales order model created with discount type: ${_getDiscountTypeValue(calcData.discountType)}');

    final salesOrderItems = cartItems
        .asMap()
        .entries
        .map((entry) => _createSalesItemsModel(entry.value, entry.key))
        .toList();

    dPrint('📦 Created ${salesOrderItems.length} sales order items');

    return SalesInvoice(
      salesOrderModel: salesOrderModel,
      salesOrderItems: salesOrderItems,
      salesOrderPayMethods: [],
    );
  }

  /// Creates a sales items model from a cart item
  static SalesItemsModel _createSalesItemsModel(CartItem item, int cartIndex) {
    dPrint('   📝 Creating sales item: ${item.nameEn} (ID: ${item.productId})');
    dPrint(
        '   🎁 Free item state for cart item at index $cartIndex: ${item.freeItemSelectionState}');
    dPrint(
        '   🎁 Cart item details: productId=${item.productId}, unitId=${item.unitId}, quantity=${item.quantity}');

    // Convert variations to the format needed for sync
    List<Map<String, dynamic>>? variations;
    if (item.variations.isNotEmpty) {
      variations = item.variations
          .map((variation) => {
                'variantId': variation.variationAr?.id ?? variation.variationEn?.id,
                'variantValueId':
                    variation.variationAr?.variantValueId ?? variation.variationEn?.variantValueId,
                'variationNameEn': variation.variationEn?.name ?? '',
                'variationNameAr': variation.variationAr?.name ?? '',
                'variationPrice': variation.price?.price ?? 0.0,
                'mainTranslationAr': variation.mainTranslationAr?.name ?? '',
                'mainTranslationEn': variation.mainTranslationEn?.name ?? '',
              })
          .toList();
    }
    
    // Convert selectedVariants (from ItemCustomizationDialog) to variations format
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
              })
          .toList();
      
      if (variations == null) {
        variations = selectedVariantMaps;
      } else {
        variations.addAll(selectedVariantMaps);
      }
    }

    final salesItem = SalesItemsModel(
      id: null,
      createdAt: '',
      updatedAt: '',
      productId: item.productId,
      categoryId: item.categoryId,
      productNameEn: item.nameEn,
      productNameAr: item.nameAr,
      unitOfMeasureId: item.unitId.toString(),
      unitNameEn: item.unitNameEn,
      unitNameAr: item.unitNameAr,
      quantity: item.quantity.toString(),
      price: item.price.toString(),
      total: '',
      note: '',
      tax: '',
      isRefund: 0,
      userId: '',
      tenantId: '',
      uniqueId: uuid.v4(),
      invoiceId: '',
      isExclusive: item.inclusive,
      freeItemSelectionState: item.freeItemSelectionState,
      selectedFreeProductId: item.selectedFreeProductId,
      selectedFreeProductName: item.selectedFreeProductName,
      selectedFreeProductNameAr: item.selectedFreeProductNameAr,
      selectedFreeProductQuantity: item.selectedFreeProductQuantity,
      selectedFreeProductPrice: item.selectedFreeProductPrice,
      selectedFreeItemId: item.selectedFreeItemId,
      discount: 0.0,
      loyaltyDiscount: 0.0,
      promotionValue: 0.0,
      vatBeforeDiscount: 0.0,
      additionalAllowns: 0.0,
      priceIncludeVAT: 0.0,
      variations: variations,
    );

    // The free item selection state is now set directly in the constructor from CartItem
    dPrint(
        '   🎁 Free item state for ${item.nameEn}: ${salesItem.freeItemSelectionState} (cart index: $cartIndex)');
    dPrint('   🎁 SalesItem created with state: ${salesItem.freeItemSelectionState}');

    return salesItem;
  }

  /// Gets the discount type value for the sales order model
  static int? _getDiscountTypeValue(DiscountType? discountType) {
    if (discountType == DiscountType.fixedValue) return 1;
    if (discountType == DiscountType.percentage) return 2;
    return null;
  }

  /// Applies promotions to the sales invoice
  static Future<PromotionResult> _applyPromotions({
    required SalesInvoice salesInvoice,
    required List<PromotionVM> manualPromos,
    required double subtotal,
    required Ref ref,
    required double customerDiscountValue,
    required CartNotifier cartNotifier,
  }) async {
    dPrint('🎁 Applying promotions...');
    dPrint('   📊 Subtotal before promotions: $subtotal');
    dPrint('   🎯 Manual promotions to apply: ${manualPromos.length}');
    dPrint('   💸 Customer discount value: $customerDiscountValue');
    // Early exit for negative total scenarios
    if (subtotal <= 0) {
      dPrint('⚠️  Subtotal is zero or negative - skipping all promotions');
      return _createCleanPromotionResult(salesInvoice, subtotal);
    }
    if (customerDiscountValue > 0) {
      dPrint('⚠️  Subtotal is zero or negative - skipping all promotions');
      return _createCleanPromotionResult(salesInvoice, subtotal);
    }

    // Apply promotions
    dPrint('🔄 Calling PromotionsServices.applyAllPromotionsToInvoice...');
    final invoiceWithPromotions = await PromotionsServices.instance.applyAllPromotionsToInvoice(
      salesInvoice,
      manualPromos,
    );

    await _checkForFreeItemsAfterPromotions(
        invoiceWithPromotions.salesTransaction.salesOrderItems, ref);
    for (var item in invoiceWithPromotions.salesTransaction.salesOrderItems) {
      if (item.promotionCodeId == null) {
        item.freeItemSelectionState = null;
        item.selectedFreeProductId = null;
        item.selectedFreeProductName = null;
        item.selectedFreeProductNameAr = null;
        item.selectedFreeProductQuantity = null;
        item.selectedFreeProductPrice = null;
        item.selectedFreeItemId = null;
        item.isPromotionDuplicated = null;
      }
    }
    // Check if promotions don't match and clear them if needed
    if (invoiceWithPromotions.notMatch && manualPromos.isNotEmpty) {
      dPrint('⚠️  Promotions don\'t match - clearing promotions');
      _emptyPromotions(ref);
    }

    // Calculate invoice prices
    dPrint('🧮 Calculating invoice prices...');
    final invoicePrices = invoiceWithPromotions.salesTransaction.calculateInvoicePrices();

    // Extract values
    final promotionAmount = invoicePrices.promotionAmount;
    final promotionValue = invoicePrices.promotionValue;
    final taxAmount = invoicePrices.vatAfterDiscount;
    // final totalAmount = invoicePrices.total;
    final totalAmount = invoicePrices.subTotalBeforeDiscount.roundToTwoDecimals() +
        taxAmount -
        invoicePrices.discount -
        invoicePrices.promotionValue.roundToTwoDecimals();
    invoicePrices.total = totalAmount;
    dPrint('📊 Promotion results:');
    dPrint('   - invoicePrices.subTotalBeforeDiscount: ${invoicePrices.subTotalBeforeDiscount}');
    dPrint('   - Promotion amount: $promotionAmount');
    dPrint('   - Promotion value: $promotionValue');
    dPrint('   - Tax amount: $taxAmount');
    dPrint('   - Total amount R: $totalAmount ');
    // dPrint('   - Total amount R: $total');

    return PromotionResult(
      finalInvoice: invoiceWithPromotions.salesTransaction,
      finalPrices: invoicePrices,
      promotionAmount: promotionAmount,
      promotionValue: promotionValue,
      promotionName: invoiceWithPromotions.salesTransaction.salesOrderModel.promotionName,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
    );
  }

  /// Creates a clean promotion result without promotions
  static PromotionResult _createCleanPromotionResult(SalesInvoice salesInvoice, double subtotal) {
    dPrint('🧹 Creating clean promotion result (no promotions applied)');
    final cleanPrices = salesInvoice.calculateInvoicePrices();

    dPrint('📊 Clean calculation results:');
    dPrint('   - Subtotal before discount: ${cleanPrices.subTotalBeforeDiscount}');
    dPrint('   - Subtotal after discount: ${cleanPrices.subTotalAfterDiscount}');
    dPrint('   - VAT after discount: ${cleanPrices.vatAfterDiscount}');
    dPrint(
        '   - Total amount C: ${cleanPrices.subTotalAfterDiscount + cleanPrices.vatAfterDiscount}');

    return PromotionResult(
      finalInvoice: salesInvoice,
      finalPrices: cleanPrices,
      promotionAmount: 0.0,
      promotionValue: 0.0,
      promotionName: "",
      taxAmount: cleanPrices.vatAfterDiscount,
      totalAmount: cleanPrices.subTotalAfterDiscount + cleanPrices.vatAfterDiscount,
    );
  }

  /// Calculates payment totals
  static PaymentData _calculatePaymentTotals({
    required List<PaymentItem> payments,
    required double totalAmount,
  }) {
    dPrint('💳 Calculating payment totals...');
    dPrint('   💰 Total amount to pay: $totalAmount');
    dPrint('   📋 Number of payment methods: ${payments.length}');

    final double totalPaid = payments.fold(0, (sum, item) {
      dPrint('   💵 Payment method: ${item.paymentChoice} - Amount: ${item.amount}');
      return sum + item.amount;
    });

    final double remaining = (totalAmount - totalPaid).roundToTwoDecimals();
    final double change = (totalPaid > totalAmount) ? (totalPaid - totalAmount) : 0.0;

    dPrint('📊 Payment calculation results:');
    dPrint('   - Total paid: $totalPaid');
    dPrint('   - Total amount P: $totalAmount');
    dPrint('   - Remaining: $remaining');
    dPrint('   - Change: $change');

    return PaymentData(
      totalPaid: totalPaid,
      remaining: remaining,
      change: change,
    );
  }

  /// Builds the final order summary
  static OrderSummary _buildOrderSummary({
    required SalesInvoice finalInvoice,
    required ItemPrices finalPrices,
    required PaymentData paymentData,
    required double promotionAmount,
    required double promotionValue,
    required String promotionName,
    required List<String> validationMessages,
    required DiscountType? discountType,
    required double discountValue,
    required double discountAmount,
    required DecimalsNumbers decimalsSetting,
    required String? customerId,
  }) {
    dPrint('🏁 Building final order summary...');

    // Create item promotions map
    final Map<int?, ItemPromotionData> itemPromotions = _createItemPromotionsMap(
      finalInvoice: finalInvoice,
      promotionAmount: promotionAmount,
      decimalsSetting: decimalsSetting,
    );

    dPrint('📊 Final summary values:');
    dPrint('📊 Final   - Subtotal: ${finalPrices.subTotalBeforeDiscount}');
    dPrint('   - Discount: ${finalPrices.discount}');
    dPrint('   - Discount Amountss: $discountAmount');
    dPrint('   - Discount Type: $discountType');
    dPrint('   - Discount Valuess: $discountValue');
    dPrint('   - Promotion amount: $promotionAmount');
    dPrint('   - Promotion value: $promotionValue');
    dPrint('   - Tax: ${finalPrices.vatAfterDiscount}');
    dPrint('   - Total: ${finalPrices.total}');
    dPrint('   - Items with promotions: ${itemPromotions.length}');

    return OrderSummary(
      promotionName: promotionName,
      salesInvoice: finalInvoice,
      subtotal: _roundNumber(finalPrices.subTotalBeforeDiscount, decimalsSetting),
      discountAmount: _roundNumber(discountValue, decimalsSetting),
      promotionAmount: _roundNumber(promotionAmount, decimalsSetting),
      promotionValue: _roundNumber(promotionValue, decimalsSetting),
      taxAmount: _roundNumber(finalPrices.vatAfterDiscount, decimalsSetting),
      totalAmount: _roundNumber(finalPrices.total, decimalsSetting),
      totalPaid: _roundNumber(paymentData.totalPaid, decimalsSetting),
      remaining: _roundNumber(paymentData.remaining, decimalsSetting),
      change: _roundNumber(paymentData.change, decimalsSetting),
      taxBeforeDiscount: _roundNumber(finalPrices.vatBeforeDiscount, decimalsSetting),
      totalAmountBeforeDiscount: _roundNumber(
        finalPrices.subTotalBeforeDiscount + finalPrices.vatBeforeDiscount,
        decimalsSetting,
      ),
      subTotalBeforeDiscount: _roundNumber(finalPrices.subTotalBeforeDiscount, decimalsSetting),
      orderPromotionValue: promotionAmount == 0
          ? 0
          : _roundNumber(finalInvoice.salesOrderModel.promotionValue ?? 0, decimalsSetting),
      orderPromotionType: promotionAmount == 0 ? null : finalInvoice.salesOrderModel.promotionType,
      orderPromotionAmount: promotionAmount == 0
          ? 0
          : _roundNumber(finalInvoice.salesOrderModel.promotionAmount ?? 0, decimalsSetting),
      orderPromotionCode: promotionAmount == 0 ? null : finalInvoice.salesOrderModel.promotionCode,
      itemPromotions: itemPromotions,
      promotionsRemoved: promotionAmount == 0,
      validationMessages: validationMessages,
      discountType: discountType == DiscountType.percentage ? 1 : 0,
      discount: discountAmount,
      customerId: customerId,
    );
  }

  /// Creates item promotions map
  static Map<int?, ItemPromotionData> _createItemPromotionsMap({
    required SalesInvoice finalInvoice,
    required double promotionAmount,
    required DecimalsNumbers decimalsSetting,
  }) {
    dPrint('🎁 Creating item promotions map...');

    if (promotionAmount == 0) {
      dPrint('   ⚠️  No promotion amount - returning empty map');
      return {};
    }

    final itemsWithPromotions = finalInvoice.salesOrderItems
        .where((item) => item.promotionAmount != null && item.promotionAmount! > 0)
        .toList();

    dPrint('   📦 Found ${itemsWithPromotions.map((e) => e.promotionId)} items with promotions');

    final Map<int?, ItemPromotionData> result = Map.fromEntries(
      itemsWithPromotions.map((item) {
        dPrint('   🎯 Item ${item.productNameEn} has promotion: ${item.promotionAmount}');
        return MapEntry(
          int.parse(item.productId),
          ItemPromotionData(
            promotionValue: _roundNumber(item.promotionValue ?? 0, decimalsSetting),
            promotionType: item.promotionType,
            promotionAmount: _roundNumber(item.promotionAmount ?? 0, decimalsSetting),
            promotionCode: item.promotionCode,
            promotionCodeId: item.promotionCodeId,
            promotionId: item.promotionId,
            promotionName: item.promotionName,
          ),
        );
      }),
    );

    dPrint('✅ Item promotions map created with ${result.length} entries');
    return result;
  }

  /// Rounds a number based on decimal settings
  static double _roundNumber(num value, DecimalsNumbers decimalsSetting) {
    if (value.isNaN || value.isInfinite) {
      dPrint('⚠️  Invalid number detected: $value - returning 0.0');
      return 0.0;
    }

    double result;
    if (decimalsSetting == DecimalsNumbers.two) {
      result = (value * 100).roundToDouble() / 100;
    } else {
      result = (value * 100000).roundToDouble() / 100000;
    }

    // dPrint('🔢 Rounded $value to $result (decimals: $decimalsSetting)');
    return result;
  }

  /// Clears promotions and shows warning message
  static void _emptyPromotions(Ref<Object?> ref) {
    dPrint('🗑️  Clearing promotions from provider');
    ref.read(appliedPromotionsProvider.notifier).state = [];

    dPrint('⚠️  Showing promotion removal warning to user');
    ScaffoldMessenger.of(navKey.currentState!.context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                translator(
                  arText: "قيمة الخصم أكبر من المبلغ الإجمالي للخصم سيتم إزالته",
                  enText: "Discount Value greater than total amount Discount will be removed",
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(navKey.currentState!.context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Test function to demonstrate logging functionality
  /// This can be called to test the logging system
  static void testLogging() {
    dPrint('🧪 === OrderCalculator Logging Test ===');
    dPrint('📊 Testing different log levels and emojis');
    dPrint('✅ Success message test');
    dPrint('⚠️  Warning message test');
    dPrint('❌ Error message test');
    dPrint('🔢 Number calculation test: 123.456');
    dPrint('💰 Money calculation test: \$99.99');
    dPrint('📦 Item processing test: Product XYZ');
    dPrint('🎁 Promotion test: 20% off');
    dPrint('💳 Payment test: Cash payment');
    dPrint('🧮 Calculation test: 10 + 5 = 15');
    dPrint('📋 Invoice test: Invoice #12345');
    dPrint('🏁 Process completion test');
    dPrint('🎉 === Logging Test Completed ===');
  }

  /// Helper function to log calculation steps for debugging
  static void logCalculationStep(String step, Map<String, dynamic> data) {
    dPrint('🔍 Calculation Step: $step');
    data.forEach((key, value) {
      dPrint('   📊 $key: $value');
    });
  }

  /// Helper function to log error conditions
  static void logError(String context, String error, [dynamic additionalData]) {
    dPrint('❌ ERROR in $context: $error');
    if (additionalData != null) {
      dPrint('   📋 Additional data: $additionalData');
    }
  }

  /// Helper function to log success conditions
  static void logSuccess(String context, String message, [dynamic additionalData]) {
    dPrint('✅ SUCCESS in $context: $message');
    if (additionalData != null) {
      dPrint('   📋 Additional data: $additionalData');
    }
  }
}

/// Data class for calculation results
class CalculationData {
  final double subtotal;
  final double discountAmount;
  final DiscountType? discountType;
  final double discountValue;

  CalculationData({
    required this.subtotal,
    required this.discountAmount,
    this.discountType,
    this.discountValue = 0.0,
  });
}

/// Data class for promotion results
class PromotionResult {
  final SalesInvoice finalInvoice;
  final ItemPrices finalPrices;
  final double promotionAmount;
  final double promotionValue;
  final String? promotionName;
  final double taxAmount;
  final double totalAmount;

  PromotionResult({
    required this.finalInvoice,
    required this.finalPrices,
    required this.promotionAmount,
    required this.promotionValue,
    required this.promotionName,
    required this.taxAmount,
    required this.totalAmount,
  });
}

/// Data class for payment calculations
class PaymentData {
  final double totalPaid;
  final double remaining;
  final double change;

  PaymentData({
    required this.totalPaid,
    required this.remaining,
    required this.change,
  });
}

/// Check for free items after promotions are applied
Future<void> _checkForFreeItemsAfterPromotions(List<SalesItemsModel> salesItems, Ref ref) async {
  dPrint("_checkForFreeItemsAfterPromotions${salesItems.map((e) => e.promotionCodeId)}");
  try {
    // Get the current context from the navigator
    final context = navKey.currentContext;
    if (context == null) {
      dPrint('⚠️ No context available for free item selection');
      return;
    }

    // Check if any items have free products available
    final hasFreeItems = await FreeItemService.hasAnyFreeItemsAvailable(salesItems, ref);

    if (hasFreeItems) {
      dPrint('🎁 Free items available - showing selection dialogs');
      await FreeItemService.checkAndShowFreeItemDialogs(context, salesItems, ref);
    } else {
      dPrint('ℹ️ No free items available');
    }
  } catch (e) {
    dPrint('❌ Error checking for free items: $e');
  }
}
