import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/enums/discount_enum.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/order_calculator.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

import 'customer_provider.dart';

final orderSummaryProvider = FutureProvider<OrderSummary>((ref) async {
  final cartItems = ref.watch(cartProvider);
  final cartNotifier = ref.read(cartProvider.notifier);
  final discountType = ref.watch(discountTypeProvider);
  final discountValue = ref.watch(discountValueProvider);

  final payments = ref.watch(paymentBreakdownProvider);

  final decimalsSetting = AppConfig.decimalsNumbers;
  final customer = ref.watch(selectedCustomerProvider);
  // Check if customer is valid before applying discount
  double customerDiscountValue = 0.0;
  if (customer != null) {
    // Check if customer has valid date range
    if (customer.isDateRangeValid()) {
      customerDiscountValue = customer.discountPrcnt ?? 0.0;
    } else {
      // Customer is not valid, don't apply discount
      customerDiscountValue = 0.0;
    }
  }

  return await OrderCalculator.calculate(
    ref: ref,
    cartItems: cartItems,
    cartNotifier: cartNotifier,
    discountType: discountType,
    discountValue: discountValue,
    customerDiscountType: DiscountType.percentage,
    customerId: customer?.id,
    customerDiscountValue: customerDiscountValue,
    payments: payments,
    decimalsSetting: decimalsSetting,
    context: navKey.currentState!.context,
  ).timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      return OrderSummary(
        promotionName: '',
        salesInvoice: SalesInvoice(
          salesOrderModel: SalesOrderModel(
            id: null,
            promotionName: '',
            createdAt: '',
            updatedAt: '',
            deletedAt: '',
            cashierName: '',
            customerId: null,
            invoiceId: null,
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
          ),
          salesOrderItems: [],
          salesOrderPayMethods: [],
        ),
        subtotal: 0.0,
        discountAmount: 0.0,
        promotionAmount: 0.0,
        taxAmount: 0.0,
        totalAmount: 0.0,
        totalPaid: 0.0,
        remaining: 0.0,
        change: 0.0,
        taxBeforeDiscount: 0.0,
        totalAmountBeforeDiscount: 0.0,
        subTotalBeforeDiscount: 0.0,
        orderPromotionValue: 0.0,
        orderPromotionType: null,
        orderPromotionAmount: 0.0,
        orderPromotionCode: null,
        itemPromotions: {},
        promotionsRemoved: false,
        validationMessages: ['Order calculation timed out - please try again'],
        discountType: 0,
        discount: 0.0,
        promotionValue: 0.0,
        customerId: null,
      );
    },
  );
});
