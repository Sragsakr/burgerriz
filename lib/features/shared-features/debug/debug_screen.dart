import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_page_with_action_buttons.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_codes_fb_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_details_fb_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_store_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_details_fB_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_fB_table_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/coding_pattern/coding_pattern_settings_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/currency/currency_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/customer_tables/customer_address_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/customer_tables/customer_service.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/customer_tables/customer_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_fb_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_price_list_table.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/refund_reasons/refund_reson_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale__tender_type_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_store_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_items_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_orders_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_paymethods_table.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  Map<String, List<Map<String, dynamic>>> tableData = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllTableData();
  }

  Future<void> _loadAllTableData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load data from all tables using their getAll methods
      final deviceInfo = await DeviceConfigTable.getAll();
      final menuItems = await MenuItemFBTable.getAll();
      final categories = await MenuItemSyncRepository().getAllCategories();
      final unitMeasures = await MenuItemPriceListTable.getAll();
      final salesItems = await SalesItemsTable.getAll();
      final salesOrders = await SalesOrderTable.getAll();
      final salesPayMethods = await SalesPayMethodTable.getAll();
      final customers = await CustomerTable.getAll();
      final customerAddresses = await CustomerAddressTable.getAll();
      final customersWithAddresses =
          await CustomerService.getAllCustomersWithAddresses();
      final saleTypes = await SaleTypeTable.getAll();
      final saleTypePriceLists = await SaleTypePriceListTable.getAll();
      final saleTypeTranslations = await SaleTypeTranslationTable.getAll();
      final saleTypeStores = await SaleTypeStoresTable.getAll();
      final saleTenderTypes = await SaleTenderTypeTable.getAll();
      final codingPatternSettings = await CodingPatternSettingsTable.getAll();
      final refundReasons = await RefundResonTable.getAll();
      final currency = await CurrencyTable.getAll();

      // Promotion tables
      final promotionsFB = await PromotionsFBTable.getAll();
      final promotionCodesFB = await PromotionCodesFBTable.getAll();
      final promotionFBItems = await PromotionFBItemTable.getAll();
      final promotionFBStores = await PromotionFBStoreTable.getAll();
      final promotionDetailsFB = await PromotionDetailsFBTable.getAll();
      final promotionDetailsFBExcludedMenuItems =
          await PromotionDetailsFBExcludedMenuItemTable.getAll();
      final promotionFBItemExcludedMenuItems =
          await PromotionFBItemExcludedMenuItemTable.getAll();

      setState(() {
        tableData = {
          'Device Info': deviceInfo.map((e) => e.toJson()).toList(),
          'Menu Items': menuItems.map((e) => e.toJson()).toList(),
          'Categories': categories.map((e) => e.toJson()).toList(),
          'Unit Measures (Price Lists)': unitMeasures.map((e) => e.toJson()).toList(),
          'Sales Items': salesItems.map((e) => e.toMap()).toList(),
          'Sales Orders': salesOrders.map((e) => e.toMap()).toList(),
          'Sales Pay Methods': salesPayMethods.map((e) => e.toMap()).toList(),
          'Customers': customers.map((e) => e.toMap()).toList(),
          'Customer Addresses':
              customerAddresses.map((e) => e.toMap()).toList(),
          'Customers with Addresses':
              customersWithAddresses.map((e) => e.toMap()).toList(),
          'Sale Types': saleTypes.map((e) => e.toMap()).toList(),
          'Sale Type Price Lists':
              saleTypePriceLists.map((e) => e.toMap()).toList(),
          'Sale Type Translations':
              saleTypeTranslations.map((e) => e.toMap()).toList(),
          'Sale Type Stores': saleTypeStores.map((e) => e.toMap()).toList(),
          'Sale Tender Types': saleTenderTypes.map((e) => e.toMap()).toList(),
          'Coding Pattern Settings':
              codingPatternSettings.map((e) => e.toMap()).toList(),
          'Refund Reasons': refundReasons.map((e) => e.toMap()).toList(),
          'Currency': currency.map((e) => e.toMap()).toList(),

          // Promotion tables
          'Promotions FB': promotionsFB.map((e) => e.toJson()).toList(),
          'Promotion Codes FB':
              promotionCodesFB.map((e) => e.toJson()).toList(),
          'Promotion FB Items':
              promotionFBItems.map((e) => e.toJson()).toList(),
          'Promotion FB Stores':
              promotionFBStores.map((e) => e.toJson()).toList(),
          'Promotion Details FB':
              promotionDetailsFB.map((e) => e.toJson()).toList(),
          'Promotion Details FB Excluded Menu Items':
              promotionDetailsFBExcludedMenuItems
                  .map((e) => e.toMap())
                  .toList(),
          'Promotion FB Item Excluded Menu Items':
              promotionFBItemExcludedMenuItems.map((e) => e.toMap()).toList(),
        };
        isLoading = false;
      });
      dPrint('tableData is ${tableData.keys}');
    } catch (e) {
      dPrint('Error loading table data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageWithActionButtons(
      buttons: [
        ButtonSettings(
          onTap: _loadAllTableData,
          title: translator(
            arText: 'تحديث البيانات',
            enText: 'Refresh Data',
          ),
          icon: Icons.refresh,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Device Info'),
          title: translator(
            arText: 'معلومات الجهاز',
            enText: 'Device Info',
          ),
          icon: Icons.device_hub,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Menu Items'),
          title: translator(
            arText: 'عناصر القائمة',
            enText: 'Menu Items',
          ),
          icon: Icons.menu_book,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Categories'),
          title: translator(
            arText: 'الفئات',
            enText: 'Categories',
          ),
          icon: Icons.category,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Unit Measures'),
          title: translator(
            arText: 'وحدات القياس',
            enText: 'Unit Measures',
          ),
          icon: Icons.straighten,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Sales Items'),
          title: translator(
            arText: 'عناصر المبيعات',
            enText: 'Sales Items',
          ),
          icon: Icons.shopping_cart,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Sales Orders'),
          title: translator(
            arText: 'طلبات المبيعات',
            enText: 'Sales Orders',
          ),
          icon: Icons.list_alt,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Sales Pay Methods'),
          title: translator(
            arText: 'طرق الدفع',
            enText: 'Payment Methods',
          ),
          icon: Icons.payment,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Customers'),
          title: translator(
            arText: 'العملاء',
            enText: 'Customers',
          ),
          icon: Icons.people,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Customer Addresses'),
          title: translator(
            arText: 'عناوين العملاء',
            enText: 'Customer Addresses',
          ),
          icon: Icons.location_on,
        ),
        ButtonSettings(
          onTap: () =>
              _showTableDataDialog(context, 'Customers with Addresses'),
          title: translator(
            arText: 'العملاء مع العناوين',
            enText: 'Customers with Addresses',
          ),
          icon: Icons.person_pin,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Sale Types'),
          title: translator(
            arText: 'أنواع المبيعات',
            enText: 'Sale Types',
          ),
          icon: Icons.sell,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Sale Type Price Lists'),
          title: translator(
            arText: 'قوائم أسعار أنواع المبيعات',
            enText: 'Sale Type Price Lists',
          ),
          icon: Icons.price_check,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Sale Type Translations'),
          title: translator(
            arText: 'ترجمات أنواع المبيعات',
            enText: 'Sale Type Translations',
          ),
          icon: Icons.translate,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Sale Type Stores'),
          title: translator(
            arText: 'متاجر أنواع المبيعات',
            enText: 'Sale Type Stores',
          ),
          icon: Icons.store,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Sale Tender Types'),
          title: translator(
            arText: 'أنواع العطاءات',
            enText: 'Sale Tender Types',
          ),
          icon: Icons.receipt_long,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Coding Pattern Settings'),
          title: translator(
            arText: 'إعدادات الترميز',
            enText: 'Coding Settings',
          ),
          icon: Icons.settings,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Refund Reasons'),
          title: translator(
            arText: 'أسباب الاسترداد',
            enText: 'Refund Reasons',
          ),
          icon: Icons.undo,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Currency'),
          title: translator(
            arText: 'العملة',
            enText: 'Currency',
          ),
          icon: Icons.attach_money,
        ),

        // Promotion tables
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Promotions FB'),
          title: translator(
            arText: 'العروض الترويجية',
            enText: 'Promotions',
          ),
          icon: Icons.local_offer,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Promotion Codes FB'),
          title: translator(
            arText: 'رموز العروض الترويجية',
            enText: 'Promotion Codes',
          ),
          icon: Icons.qr_code,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Promotion FB Items'),
          title: translator(
            arText: 'عناصر العروض الترويجية',
            enText: 'Promotion Items',
          ),
          icon: Icons.inventory,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Promotion FB Stores'),
          title: translator(
            arText: 'متاجر العروض الترويجية',
            enText: 'Promotion Stores',
          ),
          icon: Icons.store,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(context, 'Promotion Details FB'),
          title: translator(
            arText: 'تفاصيل العروض الترويجية',
            enText: 'Promotion Details',
          ),
          icon: Icons.details,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(
              context, 'Promotion Details FB Excluded Menu Items'),
          title: translator(
            arText: 'العناصر المستثناة من تفاصيل العروض',
            enText: 'Excluded Menu Items from Details',
          ),
          icon: Icons.block,
        ),
        ButtonSettings(
          onTap: () => _showTableDataDialog(
              context, 'Promotion FB Item Excluded Menu Items'),
          title: translator(
            arText: 'العناصر المستثناة من عناصر العروض',
            enText: 'Excluded Menu Items from Items',
          ),
          icon: Icons.do_not_disturb,
        ),
      ],
      actions: [
        IconButton(
          icon: Icon(
            Icons.language,
            size: ResponsiveHelper.getResponsiveSize(context, 24),
          ),
          onPressed: () async {
            await switchAppLanguage(ref, context);
          },
        ),
      ],
      onPressedLeading: () {
        context.go('/cashier-page');
      },
      pageTitle: 'debug',
    );
  }

  void _showTableDataDialog(BuildContext context, String tableName) {
    final data = tableData[tableName] ?? [];

    showAppDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$tableName (${data.length} records)'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: data.isEmpty
              ? Center(
                  child: Text(
                    translator(
                      arText: 'لا توجد بيانات',
                      enText: 'No data available',
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: data.map((record) {
                      return Card(
                        margin: const EdgeInsets.all(4),
                        child: ExpansionTile(
                          title: Text(
                            record.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: record.entries.map((entry) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${entry.key}: ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            entry.value?.toString() ?? 'null',
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translator(
              arText: 'إغلاق',
              enText: 'Close',
            )),
          ),
        ],
      ),
    );
  }
}
