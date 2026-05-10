import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_choice_chips.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/theme/report_group_theme.dart';
import 'package:kiosk_point_of_sale/core/enums/discount_enum.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/data/models/payment_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/store/store_info.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';

class PaymentBreakdownNotifier extends StateNotifier<List<PaymentItem>> {
  PaymentBreakdownNotifier() : super([]);

  void removeAllPaymentsOfType(int tenderId) {
    state = state.where((payment) => payment.tenderTypeId != tenderId).toList();
  }

  void addPayment(PaymentChoiceData method, double amount, int tenderTypeId) {
    state = [
      ...state,
      PaymentItem(
          paymentChoice: method, amount: amount, tenderTypeId: tenderTypeId)
    ];
  }

  void removePayment(int index) {
    if (index >= 0 && index < state.length) {
      state = [...state]..removeAt(index);
    }
  }

  void clearPayments() {
    state = [];
  }

  double get totalPaid => state.fold(0, (sum, item) => sum + item.amount);

  double getRemainingAmount(double totalAmount) {
    return (totalAmount - totalPaid).clamp(0, double.infinity);
  }

  // Dynamically calculate totals for each payment method
  Map<int, Map<String, dynamic>> get paymentTotals {
    final totals = <int, Map<String, dynamic>>{};

    for (var payment in state) {
      int tenderId = payment.paymentChoice.tenderId;
      String enName = payment.paymentChoice.enName;
      String arName = payment.paymentChoice.arName;

      totals.update(
        tenderId,
        (existing) =>
            {...existing, 'total': existing['total'] + payment.amount},
        ifAbsent: () =>
            {'enName': enName, 'arName': arName, 'total': payment.amount},
      );
    }

    dPrint("totals is $totals");
    return totals;
  }

  double getMethodTotal(int tenderId) => state.fold(
      0.0,
      (sum, item) =>
          sum + (item.paymentChoice.tenderId == tenderId ? item.amount : 0));
}

// Payment Breakdown Provider
final paymentBreakdownProvider =
    StateNotifierProvider<PaymentBreakdownNotifier, List<PaymentItem>>((ref) {
  return PaymentBreakdownNotifier();
});

// Selected Payment Method Provider
final selectedPaymentMethodProvider =
    StateProvider<PaymentChoiceData?>((ref) => null);
final saleTypeNotifier = StateProvider<SaleType?>((ref) => null);
final invoicePhoneProvider = StateProvider<String>((ref) => '');

// Multi-store kiosk providers — persist for the entire order session
final selectedReportGroupIdProvider = StateProvider<int?>((ref) => null);
final selectedStoreInfoProvider = StateProvider<StoreInfo?>((ref) => null);
final availableSaleTypesProvider = StateProvider<List<SaleType>>((ref) => []);

/// Session branding (accent, logos, header art, [ReportGroupThemeData.isSteakHouseBrand]).
/// Single-store mode always resolves to the same theme in kiosk and mobile.
final reportGroupThemeProvider = Provider<ReportGroupThemeData>((ref) {
  return ReportGroupSession.themeForSession(isMobile: AppConfig.isMobile);
});


// Subtotal Calculation Provider (Before Tax)
final subtotalAmountProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  double subtotal = 0;

  for (final item in cartItems) {
    final priceWithoutTax = (item.inclusive) ? item.price : item.price / (1.15);
    subtotal += priceWithoutTax * item.quantity;
  }

  return subtotal.roundToTwoDecimals();
});

// Tax Amount Calculation Provider
final taxAmountProvider = Provider<double>((ref) {
  final subtotal = ref.watch(subtotalAmountProvider);

  final discountAmount = ref.watch(discountAmountProvider);
  final allTax = (subtotal - discountAmount) * 0.15;
  return allTax.roundToTwoDecimals();
});

// Discount Providers
final messageProvider = StateProvider<String?>((ref) => null);
final discountTypeProvider = StateProvider<DiscountType?>((ref) => null);
final discountValueProvider = StateProvider<double>((ref) => 0.0);
// Discount Amount Calculation Provider (Newly Added)
final discountAmountProvider = Provider<double>((ref) {
  final subtotal = ref.watch(subtotalAmountProvider);
  final discount = ref.watch(discountValueProvider);
  final discountType = ref.watch(discountTypeProvider);

  double discountAmount = 0.0;

  if (discountType != null) {
    discountAmount = discountType == DiscountType.fixedValue
        ? discount
        : (subtotal * (discount / 100));
  }

  return discountAmount.clamp(0, subtotal).roundToTwoDecimals();
});

final totalAmountProvider = Provider<double>((ref) {
  final subtotal = ref.watch(subtotalAmountProvider);

  final discountAmount = ref.watch(discountAmountProvider);
  final totalAmount = (subtotal - discountAmount) * 1.15;
  return totalAmount.clamp(0, double.infinity).roundToTwoDecimals();
});

// Remaining Amount Provider (After Applying Discounts)
final remainingAmountProvider = Provider<double>((ref) {
  final totalAmount = ref.watch(totalAmountProvider);
  dPrint("totalAmount $totalAmount");
  final payments = ref.watch(paymentBreakdownProvider);
  final totalPaid = payments.fold(0.0, (sum, payment) => sum + payment.amount);

  return (totalAmount - totalPaid).clamp(0, double.infinity);
});

// Total Quantity Provider
final totalQuantProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (qty, item) => qty + item.quantity);
});

// Change Amount Provider (When Paid More Than Total)
final changeAmountProvider = Provider<double>((ref) {
  final totalAmount = ref.watch(totalAmountProvider);
  final payments = ref.watch(paymentBreakdownProvider);
  final totalPaid = payments.fold(0.0, (sum, payment) => sum + payment.amount);

  return (totalPaid > totalAmount) ? (totalPaid - totalAmount) : 0.0;
});

// Can Add Payment Provider (Checks if Payment Method is Selected)
final canAddPaymentProvider = Provider<bool>((ref) {
  final selectedMethod = ref.watch(selectedPaymentMethodProvider);
  return selectedMethod != null;
});

// Extension for Rounding Numbers to Two Decimals
extension DoubleExtensions on num {
  double roundToTwoDecimals() {
    final DecimalsNumbers num = AppConfig.decimalsNumbers;
    if (num == DecimalsNumbers.two) {
      return (this * 100).roundToDouble() / 100;
    } else {
      return (this * 100000).roundToDouble() / 100000;
    }
  }

  double roundToFourDecimals() {
    return (this * 100000).roundToDouble() / 100000;
  }

  String toFixedDecimals() {
    final DecimalsNumbers decimalsSetting = AppConfig.decimalsNumbers;
    return decimalsSetting == DecimalsNumbers.two
        ? roundToTwoDecimals().toStringAsFixed(2)
        : roundToTwoDecimals().toStringAsFixed(5);
  }
}

enum DecimalsNumbers {
  two(2),
  four(4);

  final int value;

  const DecimalsNumbers(this.value);
}
// NOTE: Do NOT use generateSalesInvoice(ref) inside a provider, as it requires WidgetRef.
// Instead, call this logic directly in your widget or async function where you have a WidgetRef:
//
// final salesInvoice = await generateSalesInvoice(ref);
// final finalInvoice = await PromotionsServices.applyAllPromotionsToInvoice(ref, salesInvoice);
// final totalPromotionValue = getTotalPromotionValue(finalInvoice);
//
// Remove the providers below as they cause type errors.
// final finalInvoiceWithPromotionsProvider = ...
// final totalPromotionValueProvider = ...

// Utility function to get the total value of all promotions applied to an invoice
// (order-level + item-level)
double getTotalPromotionValue(SalesInvoice invoice) {
  double total = 0.0;
  total += invoice.salesOrderModel.promotionValue ?? 0.0;
  for (final item in invoice.salesOrderItems) {
    total += item.promotionValue ?? 0.0;
  }
  return total;
}
