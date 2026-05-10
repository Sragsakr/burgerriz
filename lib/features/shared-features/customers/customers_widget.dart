// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_new, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_page_with_action_buttons.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_model.dart';
import 'package:kiosk_point_of_sale/providers/customer_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

class CustomersWidget extends ConsumerStatefulWidget {
  final SaleType saleType;

  const CustomersWidget({
    super.key,
    required this.saleType,
  });

  @override
  _CustomersWidgetState createState() => _CustomersWidgetState();
}

class _CustomersWidgetState extends ConsumerState<CustomersWidget> {
  bool loading = false;
  List<CustomerModel> customers = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      loading = true;
    });

    try {
      await ref.read(customerNotifierProvider.notifier).loadAllCustomers();
      final allCustomers = ref.read(allCustomersProvider);
      setState(() {
        customers = allCustomers;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      dPrint('Error loading customers: $e');
    }
  }

  List<CustomerModel> get filteredCustomers {
    if (searchQuery.isEmpty) {
      return customers;
    }
    return customers.where((customer) {
      final query = searchQuery.toLowerCase();
      return customer.fullName.toLowerCase().contains(query) ||
          customer.cellPhone.contains(query) ||
          customer.code.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final filteredCustomersList = filteredCustomers;

    return CustomPageWithActionButtons(
      buttons: [
        // Search button
        ButtonSettings(
          onTap: () => _showSearchDialog(context),
          title: isEnglish ? 'Search Customers' : 'البحث عن العملاء',
          icon: Icons.search,
        ),
        // Skip customer selection button
        ButtonSettings(
          onTap: () => _proceedWithoutCustomer(),
          title: isEnglish ? 'Skip Customer' : 'تخطي العميل',
          icon: Icons.person_off,
        ),
        // Show message if no customers available
        if (filteredCustomersList.isEmpty && searchQuery.isEmpty)
          ButtonSettings(
            onTap: () => _showNoCustomersDialog(context),
            title: isEnglish
                ? 'No Customers Available\nTap to proceed without customer'
                : 'لا توجد عملاء متاحين\nاضغط للمتابعة بدون عميل',
            icon: Icons.info_outline,
          ),
        // Customer buttons
        ...filteredCustomersList.map((customer) => ButtonSettings(
              onTap: () => _selectCustomer(customer),
              title: '${customer.fullName}\n${customer.cellPhone}',
              icon: Icons.person,
            )),
      ],
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () => _loadCustomers(),
        ),
        IconButton(
          icon: Icon(
            Icons.language,
            size: ResponsiveHelper.getResponsiveSize(
              context,
              24,
            ),
          ),
          onPressed: () async {
            await switchAppLanguage(ref, context);
          },
        ),
      ],
      onPressedLeading: () {
        context.go('/sale_type-page');
      },
      pageTitle: 'customers',
    );
  }

  void _showSearchDialog(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEnglish ? 'Search Customers' : 'البحث عن العملاء'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: isEnglish
                  ? 'Enter name, phone, or code'
                  : 'أدخل الاسم أو الهاتف أو الكود',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  searchQuery = '';
                });
                Navigator.of(context).pop();
              },
              child: Text(isEnglish ? 'Clear' : 'مسح'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isEnglish ? 'Close' : 'إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _selectCustomer(CustomerModel customer) {
    // Store selected customer in provider

    if (customer.id == '-1') {
      _proceedWithoutCustomer();
    } else {
      // Navigate to address selection
      ref.read(selectedCustomerProvider.notifier).state = customer;
      context.go('/customer-addresses', extra: {
        'customer': customer,
        'saleType': widget.saleType,
      });
    }
  }

  void _proceedWithoutCustomer() {
    // Clear any selected customer
    ref.read(selectedCustomerProvider.notifier).state = null;
    ref.read(selectedAddressProvider.notifier).state = null;

    // Navigate directly to sell page
    _navigateToSellPage();
  }

  void _navigateToSellPage() {
    // Set the sale type and navigate to sell page
    ref.read(saleTypeNotifier.notifier).state = widget.saleType;
    context.go('/sell-page');
  }

  void _showNoCustomersDialog(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              isEnglish ? 'No Customers Available' : 'لا توجد عملاء متاحين'),
          content: Text(
            isEnglish
                ? 'No customers have been synced yet. You can proceed without selecting a customer, or go back to sync customers first.'
                : 'لم يتم مزامنة أي عملاء بعد. يمكنك المتابعة بدون اختيار عميل، أو العودة لمزامنة العملاء أولاً.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/sale-types');
              },
              child: Text(isEnglish ? 'Go Back' : 'العودة'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _proceedWithoutCustomer();
              },
              child: Text(isEnglish
                  ? 'Proceed Without Customer'
                  : 'المتابعة بدون عميل'),
            ),
          ],
        );
      },
    );
  }
}
