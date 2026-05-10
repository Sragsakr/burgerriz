// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_new, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/providers/customer_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_page_with_action_buttons.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_model.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_address_model.dart';

class CustomerAddressesWidget extends ConsumerStatefulWidget {
  final CustomerModel customer;
  final SaleType saleType;

  const CustomerAddressesWidget({
    super.key,
    required this.customer,
    required this.saleType,
  });

  @override
  _CustomerAddressesWidgetState createState() =>
      _CustomerAddressesWidgetState();
}

class _CustomerAddressesWidgetState
    extends ConsumerState<CustomerAddressesWidget> {
  CustomerAddressModel? selectedAddress;

  @override
  void initState() {
    super.initState();
    // Set the initially selected address if any
    if (widget.customer.customerAddress.isNotEmpty) {
      final selected = widget.customer.customerAddress.firstWhere(
        (address) => address.isSelected,
        orElse: () => widget.customer.customerAddress.first,
      );
      selectedAddress = selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final addresses = widget.customer.customerAddress;

    return CustomPageWithActionButtons(
      buttons: [
        // Skip address selection button
        ButtonSettings(
          onTap: () => _proceedWithoutAddress(),
          title: isEnglish ? 'Skip Address' : 'تخطي العنوان',
          icon: Icons.location_off,
        ),
        // Show message if no addresses available
        if (addresses.isEmpty)
          ButtonSettings(
            onTap: () => _showNoAddressesDialog(context),
            title: isEnglish
                ? 'No Addresses Available\nTap to proceed without address'
                : 'لا توجد عناوين متاحة\nاضغط للمتابعة بدون عنوان',
            icon: Icons.info_outline,
          ),
        // Address buttons
        ...addresses.map((address) => ButtonSettings(
              onTap: () => _selectAddress(address),
              title: _getAddressDisplayText(address, isEnglish),
              icon: selectedAddress?.id == address.id
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            )),
      ],
      actions: [
        IconButton(
          icon: Icon(
            Icons.language,
          ),
          onPressed: () async {
            await switchAppLanguage(ref, context);
          },
        ),
      ],
      onPressedLeading: () {
        context.go('/customers', extra: widget.saleType);
      },
      pageTitle: 'customerAddresses',
    );
  }

  String _getAddressDisplayText(CustomerAddressModel address, bool isEnglish) {
    final parts = <String>[];

    if (address.city.isNotEmpty) {
      parts.add(address.city);
    }

    if (address.address.isNotEmpty) {
      parts.add(address.address);
    }

    if (address.zoneName != null && address.zoneName!.isNotEmpty) {
      parts.add(address.zoneName!);
    }

    if (address.streetName != null && address.streetName!.isNotEmpty) {
      parts.add(address.streetName!);
    }

    if (parts.isEmpty) {
      return isEnglish ? 'Address ${address.id}' : 'العنوان ${address.id}';
    }

    return parts.join('\n');
  }

  void _selectAddress(CustomerAddressModel address) {
    setState(() {
      selectedAddress = address;
    });

    // Store selected address in provider
    ref.read(selectedAddressProvider.notifier).state = address;

    // Navigate to sell page
    _navigateToSellPage();
  }

  void _proceedWithoutAddress() {
    // Clear selected address
    ref.read(selectedAddressProvider.notifier).state = null;

    // Navigate to sell page
    _navigateToSellPage();
  }

  void _navigateToSellPage() {
    // Set the sale type and navigate to sell page
    ref.read(saleTypeNotifier.notifier).state = widget.saleType;
    context.go('/sell-page');
  }

  void _showNoAddressesDialog(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              isEnglish ? 'No Addresses Available' : 'لا توجد عناوين متاحة'),
          content: Text(
            isEnglish
                ? 'This customer has no addresses. You can proceed without selecting an address.'
                : 'هذا العميل ليس لديه عناوين. يمكنك المتابعة بدون اختيار عنوان.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _proceedWithoutAddress();
              },
              child: Text(isEnglish
                  ? 'Proceed Without Address'
                  : 'المتابعة بدون عنوان'),
            ),
          ],
        );
      },
    );
  }
}
