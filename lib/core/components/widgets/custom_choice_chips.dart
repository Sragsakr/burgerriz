// Model for our choice data
import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';

enum PaymentMethod { cash, nearPay }

class PaymentChoiceData {
  final int tenderId;
  final String arName;
  final String enName;
  final IconData icon;
  // final PaymentMethod paymentMethod;

  PaymentChoiceData({
    required this.tenderId,
    required this.arName,
    required this.enName,
    required this.icon,
    // required this.paymentMethod,
  });

  String name(context) {
    final language = FFLocalizations.of(context).languageCode;
    return language == 'en' ? enName : arName;
  }
}

// The actual widget
class CustomChoiceChips extends StatefulWidget {
  final List<PaymentChoiceData> choices;
  final Function(PaymentChoiceData?) onChanged;
  final PaymentChoiceData? selectedValue;

  const CustomChoiceChips({
    super.key,
    required this.choices,
    required this.onChanged,
    required this.selectedValue,
  });

  @override
  State<CustomChoiceChips> createState() => _CustomChoiceChipsState();
}

class _CustomChoiceChipsState extends State<CustomChoiceChips> {
  @override
  Widget build(BuildContext context) {
    print('-----------');
    for (var choice in widget.choices) {
      print(
          'choice ${choice.name(context)} isSelected ${choice == widget.selectedValue}');
    }
    return Wrap(
      spacing: 8,
      children: widget.choices.map((choice) {
        final isSelected =
            ((choice.tenderId == widget.selectedValue?.tenderId)) ||
                (choice.arName == widget.selectedValue?.arName) ||
                (choice.enName == widget.selectedValue?.enName);

        return InkWell(
          onTap: () => widget.onChanged(choice),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFAF2A26) : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  choice.icon,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  choice.name(context),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontSize: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 20
                        : 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
