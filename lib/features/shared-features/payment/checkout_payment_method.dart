import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_choice_chips.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_tender_type_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale__tender_type_table.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

final availablePaymentMethodsProvider = StateProvider<List<PaymentChoiceData>>((ref) => []);

class PaymentMethodSelector extends ConsumerStatefulWidget {
  const PaymentMethodSelector({super.key});

  @override
  ConsumerState<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends ConsumerState<PaymentMethodSelector> {
  bool showNearPay = false;
  var isEnglish = Localizations.localeOf(navKey.currentState!.context).languageCode == 'en';
  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    final tenderTypes = await SaleTenderTypeTable.getAll();

    final hasTerminal = deviceInfo?.terminalId != null;
    final languageCode = isEnglish ? 1 : 2;
    final methods = tenderTypes
        .where((tender) => tender.isDeleted == 0 && tender.languageId == languageCode)
        .where((tender) => tender.name.toLowerCase() != 'nearpay' || hasTerminal)
        .map((tender) {
      return PaymentChoiceData(
        tenderId: tender.tenderTypeId,
        enName: _getEnglishName(tender.tenderTypeId, tenderTypes),
        arName: _getArabicName(tender.tenderTypeId, tenderTypes),
        icon: _getPaymentIcon(tender.name),
      );
    }).toList();

    ref.read(availablePaymentMethodsProvider.notifier).state = methods;
  }

  String _getArabicName(int tenderTypeId, List<SaleTenderTypeModel> tenderTypes) {
    final tenderType = tenderTypes.firstWhere((tender) =>
        tender.tenderTypeId == tenderTypeId && tender.isDeleted == 0 && tender.languageId == 2);
    return tenderType.name;
  }

  String _getEnglishName(int tenderTypeId, List<SaleTenderTypeModel> tenderTypes) {
    final tenderType = tenderTypes.firstWhere((tender) =>
        tender.tenderTypeId == tenderTypeId && tender.isDeleted == 0 && tender.languageId == 1);
    return tenderType.name;
  }

  IconData _getPaymentIcon(String paymentName) {
    final icons = {
      'cash': Icons.payments_outlined,
      'nearpay': Icons.credit_card,
      'visa': Icons.credit_card,
      'mastercard': Icons.payment,
    };
    return icons[paymentName.toLowerCase()] ?? Icons.account_balance_wallet;
  }

  @override
  Widget build(BuildContext context) {
    final selectedMethod = ref.watch(selectedPaymentMethodProvider);
    final availableMethods = ref.watch(availablePaymentMethodsProvider);

    return Material(
      color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FFLocalizations.of(context).getText('pchz7ef9'),
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: 'Inter Tight',
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontSize: MediaQuery.of(context).orientation == Orientation.landscape ? 30 : MediaQuery.sizeOf(context).width * 0.06,
                    ),
              ),
              const SizedBox(height: 10),
              if (availableMethods.isEmpty)
                const CircularProgressIndicator()
              else
                CustomChoiceChips(
                  choices: availableMethods,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(selectedPaymentMethodProvider.notifier).state = value;
                    }
                  },
                  selectedValue: selectedMethod,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
