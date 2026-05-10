import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_paymethod_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_items_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_orders_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_paymethods_table.dart';

Future<void> printAllSalesOrders() async {
  List<SalesOrderModel> salesOrdersDB = await SalesOrderTable.getAll();
  final List<Map<String, dynamic>> salesOrders =
      salesOrdersDB.map((order) => order.toMap()).toList();

  if (salesOrders.isEmpty) {
    print('\n═══════════════ SALES ORDERS (Empty) ═══════════════\n');
    return;
  }

  print('\n═══════════════ SALES ORDERS ═══════════════');
  print('Total Orders: ${salesOrders.length}');
  print('═══════════════════════════════════════════════════\n');

  for (var order in salesOrders) {
    print('┌─────────────────────────────────────────┐');
    print('│ Order ID: ${order['id']}');
    print('├─────────────────────────────────────────┤');
    print('│ Created At: ${order['createdAt']}');
    print('│ Updated At: ${order['updatedAt']}');
    print('│ Deleted At: ${order['deletedAt']}');
    print('│ Total Amount: ${order['totalAmount']}');
    print('│ Note: ${order['note']}');
    print('│ isSync: ${order['isSync']}');
    print(
        '│ Refund Status: ${order['isRefund'] == 1 ? "Refunded" : "Not Refunded"}');
    print('│ User ID: ${order['userId']}');
    print('│ Tenant ID: ${order['tenantId']}');
    print('└─────────────────────────────────────────┘\n');
  }
}

Future<void> pintAllSalesOrderItems() async {
  List<SalesItemsModel> salesItemsDB = await SalesItemsTable.getAll();
  dPrint('Sales Items: ${salesItemsDB.length}');
  final List<Map<String, dynamic>> salesItems =
      salesItemsDB.map((item) => item.toMap()).toList();

  if (salesItems.isEmpty) {
    print('\n═══════════════ SALES ITEMS (Empty) ═══════════════\n');
    return;
  }

  print('\n═══════════════ SALES ITEMS ═══════════════');
  print('Total Items: ${salesItems.length}');
  print('═══════════════════════════════════════════════════\n');

  String currentOrderId = '';
  for (var item in salesItems) {
    if (currentOrderId != item['orderId']) {
      currentOrderId = item['orderId'];
      print('┌─────────────────────────────────────────┐');
      print('│ Order ID: $currentOrderId');
      print('├─────────────────────────────────────────┤');
    }

    print('│ • Item ID: ${item['id']}');
    print('│   Product ID: ${item['productId']}');
    print('│   Product Name (EN): ${item['productNameEn']}');
    print('│   Product Name (AR): ${item['productNameAr']}');
    print(
        '│   Unit: ${item['unitOfMeasureNameEn']} (${item['unitOfMeasureNameAr']})');
    print('│   Quantity: ${item['quantity']}');
    print('│   Price: ${item['price']}');
    print('│   Total: ${item['total']}');
    print('│   Note: ${item['note']}');
    print('│   Order ID: ${item['orderId']}');
    print(
        '│   Refund Status: ${item['isRefund'] == 1 ? "Refunded" : "Not Refunded"}');
    print('├─────────────────────────────────────────┤');
  }
  print('═══════════════════════════════════════════════════\n');
}

Future<void> pintAllSalesOrderPayMethods() async {
  List<SalesPayMethodModel> payMethodsDB = await SalesPayMethodTable.getAll();
  final List<Map<String, dynamic>> payMethods =
      payMethodsDB.map((method) => method.toMap()).toList();

  if (payMethods.isEmpty) {
    print('\n═══════════════ SALES PAYMENT METHODS (Empty) ═══════════════\n');
    return;
  }

  print('\n═══════════════ SALES PAYMENT METHODS ═══════════════');
  print('Total Methods: ${payMethods.length}');
  print('═══════════════════════════════════════════════════\n');

  String currentOrderId = '';
  for (var method in payMethods) {
    if (currentOrderId != method['orderId']) {
      currentOrderId = method['orderId'];
      print('┌─────────────────────────────────────────┐');
      print('│ Order ID: $currentOrderId');
      print('├─────────────────────────────────────────┤');
    }

    print('│ • Payment ID: ${method['id']}');
    print('│   Method Name (EN): ${method['nameEn']}');
    print('│   Method Name (AR): ${method['nameAr']}');
    print('│   Amount: ${method['amount']}');
    print('│   User ID: ${method['userId']}');
    print('│   Tenant ID: ${method['tenantId']}');

    // Check if this is the last method for this order
    var isLastForOrder = payMethods.lastWhere(
          (m) => m['orderId'] == currentOrderId,
          orElse: () => method,
        ) ==
        method;

    if (isLastForOrder) {
      print('└─────────────────────────────────────────┘\n');
    } else {
      print('├─────────────────────────────────────────┤');
    }
  }
  print('═══════════════════════════════════════════════════\n');
}
