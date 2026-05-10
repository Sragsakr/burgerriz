//reset cart prices
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/customer_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/providers/promotion_provider.dart';

void resetPaymentAndCartValues(WidgetRef ref) {
  // Reset selected payment method to null
  ref.read(selectedPaymentMethodProvider.notifier).state = null;
  ref.read(invoicePhoneProvider.notifier).update(
        (state) => "",
      );

  ref.read(appliedPromotionsProvider.notifier).state = [];
  // ref.read(appliedPromotionsDialogProvider.notifier).state = [];  // Clear all payments in the payment breakdown
  ref.read(paymentBreakdownProvider.notifier).clearPayments();

  // Clear all items in the cart
  ref.read(cartProvider.notifier).clearCart();

  // clear Discounts
  ref.read(discountTypeProvider.notifier).state = null;
  ref.read(discountValueProvider.notifier).state = 0.0;

  // Clear selected customer and address
  ref.read(selectedCustomerProvider.notifier).state = null;
  ref.read(selectedAddressProvider.notifier).state = null;
}

void resetPaymentValues(WidgetRef ref) {
  // Reset selected payment method to null
  ref.read(selectedPaymentMethodProvider.notifier).state = null;

  // Clear all payments in the payment breakdown
  ref.read(paymentBreakdownProvider.notifier).clearPayments();
}
