// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_new, deprecated_member_use, use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_address_model.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_model.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/customer_provider.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/providers/promotion_provider.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';

class CustomersTableWidget extends ConsumerStatefulWidget {
  final SaleType saleType;

  const CustomersTableWidget({
    super.key,
    required this.saleType,
  });

  @override
  _CustomersTableWidgetState createState() => _CustomersTableWidgetState();
}

class _CustomersTableWidgetState extends ConsumerState<CustomersTableWidget> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Select Customer' : 'اختر العميل',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'Outfit',
                color: FlutterFlowTheme.of(context).gray600,
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/sale_type-page'),
        ),
        actions: [
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
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    // Search bar styled as in screenshot
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.red.shade200, width: 2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: isEnglish ? 'Search...' : 'بحث...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.search, color: Colors.red),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Table
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildCustomersTable(
                            filteredCustomersList, isEnglish),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCustomersTable(List<CustomerModel> customers, bool isEnglish) {
    bool isTablet = ResponsiveHelper.isTablet(context);
    dPrint('isTablet: $isTablet');
    return SizedBox(
      // width: isTablet ? double.infinity : 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          showCheckboxColumn: false,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
          dataRowColor: MaterialStateProperty.all(Colors.white),
          columnSpacing: 0, // Set to 0 for custom spacing
          horizontalMargin: 8,
          columns: [
            DataColumn(
              label: SizedBox(
                width: isTablet ? 130 : 30, // Ratio 1 - Code column
                child: Text(isEnglish ? 'Code' : 'الكود'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: isTablet
                    ? 420
                    : 100, // Ratio 4 - Name column (4x the base width)
                child: Text(isEnglish ? 'Name' : 'الاسم'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: isTablet
                    ? 190
                    : 50, // Ratio 2 - Cell Phone column (2x the base width)
                child: Text(isEnglish ? 'Cell Phone' : 'الهاتف'),
              ),
            ),
            // DataColumn(label: Text(isEnglish ? 'Street' : 'الشارع')),
            // DataColumn(label: Text(isEnglish ? 'Zone' : 'الحي')),
          ],
          rows: customers.map((customer) {
            final address = customer.customerAddress.isNotEmpty
                ? customer.customerAddress.first
                : null;
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: isTablet ? 130 : 50, // Ratio 1 - Match column width
                    child: _ellipsisText(
                        customer.code.isEmpty ? '-' : customer.code),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: isTablet ? 420 : 170, // Ratio 4 - Match column width
                    child: _ellipsisText(
                      customer.fullName.isEmpty ? '-' : customer.fullName,
                      bold: true,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: isTablet ? 190 : 100, // Ratio 2 - Match column width
                    child: _ellipsisText(
                      customer.cellPhone.isEmpty ? '-' : customer.cellPhone,
                    ),
                  ),
                ),
                // DataCell(
                //     _ellipsisText(address?.streetName ?? address?.address ?? '')),
                // DataCell(_ellipsisText(address?.zoneName ?? address?.city ?? '')),
              ],
              onSelectChanged: (_) {
                if (customer.id == '-1') {
                  _proceedWithoutCustomer();
                } else {
                  _showAddressPopup(context, customer);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _ellipsisText(String? text, {bool bold = false}) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120),
      child: Text(
        text ?? '-',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style:
            TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
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

  void _showAddressPopup(BuildContext context, CustomerModel customer) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final addresses = customer.customerAddress;
    int? selectedId = addresses.firstWhereOrNull((a) => a.isSelected)?.id ??
        (addresses.isNotEmpty ? addresses.first.id : null);

    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 80),
          child: Container(
            width: 350,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEnglish ? 'Select Address' : 'اختر العنوان',
                      style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 20),
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.power_settings_new, color: Colors.red),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(),
                // Address Table
                Container(
                  constraints: BoxConstraints(maxHeight: 220),
                  width: double.infinity,
                  child: addresses.isEmpty
                      ? Center(
                          child: Text(isEnglish
                              ? 'No addresses available'
                              : 'لا توجد عناوين'),
                        )
                      : SingleChildScrollView(
                          child: DataTable(
                            showCheckboxColumn: false,
                            headingRowColor:
                                MaterialStateProperty.all(Colors.grey.shade200),
                            dataRowColor:
                                MaterialStateProperty.all(Colors.white),
                            columnSpacing: 2,
                            horizontalMargin: 4,
                            columns: [
                              DataColumn(label: Text("")),
                              DataColumn(
                                  label:
                                      Text(isEnglish ? 'Address' : 'العنوان')),
                              DataColumn(
                                  label: Text(isEnglish ? 'Zone' : 'الحي')),
                              // DataColumn(
                              //     label: Text(isEnglish ? 'Street' : 'الشارع')),
                            ],
                            rows: addresses.map((address) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Checkbox(
                                      value: selectedId == address.id,
                                      onChanged: (val) {
                                        selectedId = address.id;
                                        (context as Element).markNeedsBuild();
                                      },
                                      activeColor: selectedId == address.id
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                  DataCell(_ellipsisText(address.address)),
                                  DataCell(_ellipsisText(
                                      address.zoneName ?? address.city)),
                                  // DataCell(
                                  //     _ellipsisText(address.streetName ?? '')),
                                ],
                                onSelectChanged: (_) {
                                  selectedId = address.id;
                                  (context as Element).markNeedsBuild();
                                },
                              );
                            }).toList(),
                          ),
                        ),
                ),
                SizedBox(height: 20),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        final selected = addresses
                            .firstWhereOrNull((a) => a.id == selectedId);
                        _selectCustomerWithAddress(customer, selected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectCustomerWithAddress(
      CustomerModel customer, CustomerAddressModel? address) async {
    // Store selected customer and address in provider
    ref.read(selectedCustomerProvider.notifier).state = customer;
    ref.read(selectedAddressProvider.notifier).state = address;
    // ref.read(invoicePhoneProvider.notifier).update(
    //       (state) => customer.cellPhone.replaceAll(' ', ''),
    //     );
    dPrint(
        "selectedCustomerProvider ${ref.watch(selectedCustomerProvider)?.fullName ?? 'null'}");
    // Preload data and navigate to sell page
    await _preloadDataAndNavigate();
  }

  void _proceedWithoutCustomer() async {
    // Clear any selected customer and address
    ref.read(selectedCustomerProvider.notifier).state = null;
    ref.read(selectedAddressProvider.notifier).state = null;

    // Preload data and navigate to sell page
    await _preloadDataAndNavigate();
  }

  Future<void> _preloadDataAndNavigate() async {
    // Show loading indicator
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Preload data
      await _preloadData(widget.saleType);

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to sell page
      context.go('/sell-page');
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error dialog
      showAppDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load menu data: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Future<void> _preloadData(SaleType saleType) async {
  //   ref.read(saleTypeNotifier.notifier).state = saleType;
  //   final priceList =
  //       await SaleTypePriceListTable.getBySaleTypeId(saleType.saleTypeId);
  //   final priceListId = priceList?.priceListId ?? 1;
  //   final syncRepo = MenuItemSyncRepository();
  //   final categories = await syncRepo.getAllCategories();
  //   ref.read(allProductsProvider.notifier).state = [];
  //   ref.read(categoriesProvider.notifier).state = categories;
  //
  //   for (var category in categories) {
  //     final products =
  //         await syncRepo.getProductsByCategory(category.id, priceListId);
  //     ref.read(productsProvider(category.id.toString()).notifier).state =
  //         products;
  //     ref.read(allProductsProvider.notifier).state.addAll(products);
  //     dPrint(
  //         'Category ${category.id} (${category.nameEn}): ${products.length} products');
  //   }
  Future<void> _preloadData(SaleType saleType) async {
    ref.read(saleTypeNotifier.notifier).state = saleType;
    final priceList =
    await SaleTypePriceListTable.getBySaleTypeId(saleType.saleTypeId);
    final priceListId = priceList?.priceListId ?? 1;
    final syncRepo = MenuItemSyncRepository();

    // Load all categories and products once (not per category loop)
    final categories = await syncRepo.getAllCategories();
    final allProducts = await syncRepo.getAllProducts(priceListId);

    ref.read(allProductsProvider.notifier).state = [];
    ref.read(categoriesProvider.notifier).state = categories;

    // Group products by category in memory
    final productsByCategory = <String, List<SyncProduct>>{};
    for (final product in allProducts) {
      final categoryKey = product.productCategoryId.toString();
      productsByCategory.putIfAbsent(categoryKey, () => []).add(product);
    }

    // Update providers with grouped products
    for (final category in categories) {
      final categoryKey = category.id.toString();
      final products = productsByCategory[categoryKey] ?? [];
      ref.read(productsProvider(categoryKey).notifier).state = products;
      ref.read(allProductsProvider.notifier).state.addAll(products);
      dPrint(
          'Category ${category.id} (${category.nameEn}): ${products.length} products');
    }

    // Don't reset customer and address when preloading data for a selected customer
    // Only reset payment and cart values, but preserve customer selection
    ref.read(selectedPaymentMethodProvider.notifier).state = null;
    ref.read(invoicePhoneProvider.notifier).state = "";
    ref.read(appliedPromotionsProvider.notifier).state = [];
    ref.read(paymentBreakdownProvider.notifier).clearPayments();
    ref.read(cartProvider.notifier).clearCart();
    ref.read(discountTypeProvider.notifier).state = null;
    ref.read(discountValueProvider.notifier).state = 0.0;
  }
}
