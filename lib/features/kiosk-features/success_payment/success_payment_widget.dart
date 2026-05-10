import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/services/kds_service/client_service.dart';
import 'package:kiosk_point_of_sale/data/models/kds_device_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/pay_widget/components/pay_header_component.dart';

import 'components/invoice_options_component.dart';
import 'components/success_icon_component.dart';
import 'components/success_message_component.dart';

class SuccessPaymentWidget extends StatefulWidget {
  final SalesInvoice salesInvoice;

  const SuccessPaymentWidget({
    super.key,
    required this.salesInvoice,
  });

  static String routeName = 'SuccessPayment';
  static String routePath = '/successPayment';

  @override
  State<SuccessPaymentWidget> createState() => _SuccessPaymentWidgetState();
}

class _SuccessPaymentWidgetState extends State<SuccessPaymentWidget> {
  final ClientService _clientService = ClientService();

  Future<void> _sendOrderToKDS() async {
    try {
      // Get all KDS devices
      final kdsDevices = await AppPreferences().getKdsDevices();

      if (kdsDevices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No KDS devices configured')),
        );
        return;
      }

      // Group invoice items by category
      final Map<String, List<SalesItemsModel>> itemsByCategory = {};
      for (final item in widget.salesInvoice.salesOrderItems) {
        if (!itemsByCategory.containsKey(item.categoryId)) {
          itemsByCategory[item.categoryId] = [];
        }
        itemsByCategory[item.categoryId]!.add(item);
      }

      // Send orders to appropriate KDS devices
      final List<Future<void>> sendTasks = [];

      for (final kdsDevice in kdsDevices) {
        // Find items that match this KDS device's categories
        final List<SalesItemsModel> matchingItems = [];

        for (final categoryId in kdsDevice.selectedCategories) {
          if (itemsByCategory.containsKey(categoryId)) {
            matchingItems.addAll(itemsByCategory[categoryId]!);
          }
        }

        // Only send if there are matching items
        if (matchingItems.isNotEmpty) {
          // Create a new invoice with only the matching items
          final filteredInvoice = _createFilteredInvoice(matchingItems);

          // Add to send tasks
          sendTasks.add(_sendToKdsDevice(kdsDevice, filteredInvoice));
        }
      }

      // Execute all send tasks
      if (sendTasks.isNotEmpty) {
        await Future.wait(sendTasks);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order sent to ${sendTasks.length} KDS device(s)'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No items match any KDS device categories'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending orders: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendToKdsDevice(KdsDevice device, SalesInvoice invoice) async {
    try {
      await _clientService.sendOrderToKDS(
        hostIp: device.ip,
        invoice: invoice,
      );
      print('Successfully sent order to KDS device: ${device.name} (${device.ip})');
    } catch (e) {
      print('Failed to send order to KDS device: ${device.name} (${device.ip}) - Error: $e');
      // Re-throw to be handled by the calling function
      rethrow;
    }
  }

  SalesInvoice _createFilteredInvoice(List<SalesItemsModel> filteredItems) {
    // Calculate totals for filtered items
    double subTotal = 0;
    double tax = 0;
    double total = 0;

    for (final item in filteredItems) {
      subTotal += double.tryParse(item.price) ?? 0;
      tax += double.tryParse(item.tax) ?? 0;
      total += double.tryParse(item.total) ?? 0;
    }

    // Create a copy of the original invoice
    final filteredInvoice = widget.salesInvoice.copy();

    // Update the items and totals
    filteredInvoice.salesOrderItems = filteredItems;
    filteredInvoice.salesOrderModel.totalAmount = total.toString();
    filteredInvoice.salesOrderModel.subTotal = subTotal.toString();
    filteredInvoice.salesOrderModel.tax = tax.toString();

    return filteredInvoice;
  }

  @override
  void initState() {
    super.initState();
    _sendOrderToKDS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: SafeArea(
        top: true,
        child: GestureDetector(
          onTap: () {
            if (kDebugMode) {
              _sendOrderToKDS();
            }
          },
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: AppColors.accent4,
                image: DecorationImage(
                  fit: BoxFit.contain,
                  alignment: AlignmentDirectional(-1.0, -1.0),
                  image: AssetImage(AppAssets.successBackgroundImage),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Success Icon Component
                  Container(
                    color: Colors.white,
                    child: PayHeaderComponent(isBack: false),
                  ),

                  // Success Message Component
                  SuccessMessageComponent(orderNumber: widget.salesInvoice.salesOrderModel.receiptNumber ?? ''),

                  // Invoice Options Component
                  InvoiceOptionsComponent(salesInvoice: widget.salesInvoice),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
