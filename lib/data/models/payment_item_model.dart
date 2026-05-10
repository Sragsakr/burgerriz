import 'package:kiosk_point_of_sale/core/components/widgets/custom_choice_chips.dart';

class PaymentItem {
  final int tenderTypeId;
  final PaymentChoiceData paymentChoice;
  final double amount;
  final DateTime timestamp;

  PaymentItem({
    required this.tenderTypeId,
    required this.paymentChoice,
    required this.amount,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  PaymentItem copyWith({
    int? tenderTypeId,
    PaymentChoiceData? paymentMethod,
    double? amount,
    DateTime? timestamp,
  }) {
    return PaymentItem(
      tenderTypeId: tenderTypeId ?? this.tenderTypeId,
      paymentChoice: paymentMethod ?? paymentChoice,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
