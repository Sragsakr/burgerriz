import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/main.dart';

import 'http_requests.dart';
import 'local_end_points.dart';

class ClientService {
  //
  Completer<void>? _clientCompleter;

  Future<bool> checkConnection({
    required String hostIp,
    int? port,
    int timeout = 30000,
  }) async {
    bool isSuccess = false;
    final response = await LocalRequest.getRequest(
      host: port == null ? '$hostIp:8080' : '$hostIp:$port',
      path: LocalEndPoints.checkConnection,
      timeout: timeout,
      queryParams: {'senderIp': ""},
    );
    response.fold(
      (l) {
        log(l.code.toString());
        log(l.message);
      },
      (r) {
        isSuccess = true;
        log(r.body);
      },
    );
    return isSuccess;
  }

  //
  _completeSendToNotifierCompleter() {
    _clientCompleter?.complete();
    _clientCompleter = null;
  }

  Future<void> sendOrderToKDS({
    required String hostIp,
    required SalesInvoice invoice,
    // required int orderId,
  }) async {
    if (_clientCompleter != null && !_clientCompleter!.isCompleted) {
      await _clientCompleter!.future;
    }
    try {
      final isConnected = await checkConnection(hostIp: hostIp);
      if (!isConnected) {
        _completeSendToNotifierCompleter();
      }
    } catch (e) {
      _completeSendToNotifierCompleter();
    }

    /// role = waiter,super
    _clientCompleter = Completer<void>();
    final response = await LocalRequest.postRequest(
      host: '$hostIp:8080',
      path: LocalEndPoints.sendOrderToKDS,
      body: invoice.toKdsBody(),
      headers: {"role": "waiter"},
    );
    response.fold(
      (l) {
        ScaffoldMessenger.of(
          navKey.currentState!.context,
        ).showSnackBar(SnackBar(content: Text(l.message)));
        log(l.code.toString());
        log(l.message);
        _completeSendToNotifierCompleter();
      },
      (r) {
        ScaffoldMessenger.of(
          navKey.currentState!.context,
        ).showSnackBar(SnackBar(content: Text(r.body)));
        log(r.body);
        _completeSendToNotifierCompleter();
      },
    );
  }

  Future<(bool, String)> checkItemValidToUpdate({
    required String hostIp,
    int? port,
    int timeout = 1000,
    required String orderId,
    required String itemGuid,
    required String delete,
  }) async {
    bool isSuccess = false;
    final response = await LocalRequest.getRequest(
      host: port == null ? '$hostIp:8080' : '$hostIp:$port',
      path: LocalEndPoints.checkItemValidToUpdate,
      timeout: timeout,
      queryParams: {'orderId': orderId, 'itemGuid': itemGuid, 'delete': delete},
    );
    response.fold(
      (l) {
        log(l.code.toString());
        log(l.message);
        isSuccess = false;
      },
      (r) {
        isSuccess = true;
        log(r.body);
      },
    );
    return (isSuccess, response.fold((l) => l.message, (r) => r.body));
  }
}

// CASE 1: New Order with Multiple New Items
const newOrderCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 1,
      "itemGuid": "1cdc6791-3093-4d53-b250-c976516d49a2",
      "refItemGuid": "",
      "action": "new",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "مندي دجاج",
      "nameEn": "Chicken Mandi",
      "quantity": "20",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'صلصة حارة']",
      "modifiresEn": "['Meal', 'Spicy Sauce']",
    },
    {
      "sortOrder": 2,
      "itemGuid": "2cdc6791-3093-4d53-b250-c976516d49a3",
      "refItemGuid": "",
      "action": "new",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "شاورما دجاج",
      "nameEn": "Chicken Shawarma",
      "quantity": "3",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة']",
      "modifiresEn": "['Meal']",
    },
  ],
};

// CASE 2: Modified Items Only (Quantity and Modifiers)
const modifiedItemsCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 1,
      "itemGuid": "",
      "refItemGuid": "1cdc6791-3093-4d53-b250-c976516d49a2",
      "action": "add",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "مندي دجاج",
      "nameEn": "Chicken Mandi",
      "quantity": "2",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'صلصة حارة', 'جبنة زيادة']",
      "modifiresEn": "['Meal', 'Spicy Sauce', 'Extra Cheese']",
    },
  ],
};

// CASE 3: Deleted Items Only
const deletedItemsCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 1,
      "itemGuid": "",
      "refItemGuid": "1cdc6791-3093-4d53-b250-c976516d49a2",
      "action": "delete",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "مندي دجاج",
      "nameEn": "Chicken Mandi",
      "quantity": "5",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'صلصة حارة']",
      "modifiresEn": "['Meal', 'Spicy Sauce']",
    },
  ],
};

// CASE 4: New Items Added to Existing Order
const newItemsAddedCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 3,
      "itemGuid": "3cdc6791-3093-4d53-b250-c976516d49a4",
      "refItemGuid": "",
      "action": "new",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "برجر دجاج",
      "nameEn": "Chicken Burger",
      "quantity": "1",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة']",
      "modifiresEn": "['Meal']",
    },
  ],
};

// CASE 5: Modified and Added Items
const modifiedAndAddedCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 1,
      "itemGuid": "",
      "refItemGuid": "1cdc6791-3093-4d53-b250-c976516d49a2",
      "action": "add",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "مندي دجاج",
      "nameEn": "Chicken Mandi",
      "quantity": "2",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'صلصة حارة']",
      "modifiresEn": "['Meal', 'Spicy Sauce']",
    },
    {
      "sortOrder": 3,
      "itemGuid": "3cdc6791-3093-4d53-b250-c976516d49a4",
      "refItemGuid": "",
      "action": "new",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "برجر دجاج",
      "nameEn": "Chicken Burger",
      "quantity": "1",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة']",
      "modifiresEn": "['Meal']",
    },
  ],
}; // CASE 5: Modified and Added Items
const modifiedCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 1,
      "itemGuid": "",
      "refItemGuid": "1cdc6791-3093-4d53-b250-c976516d49a2",
      "action": "add",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "مندي دجاج",
      "nameEn": "Chicken Mandi",
      "quantity": "2",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'صلصة حارة']",
      "modifiresEn": "['Meal', 'Spicy Sauce']",
    },
  ],
};

// CASE 6: Modified and Deleted Items
const modifiedAndDeletedCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 1,
      "itemGuid": "",
      "refItemGuid": "1cdc6791-3093-4d53-b250-c976516d49a2",
      "action": "add",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "مندي دجاج",
      "nameEn": "Chicken Mandi",
      "quantity": "2",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'صلصة حارة']",
      "modifiresEn": "['Meal', 'Spicy Sauce']",
    },
    {
      "sortOrder": 2,
      "itemGuid": "",
      "refItemGuid": "2cdc6791-3093-4d53-b250-c976516d49a3",
      "action": "delete",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "شاورما دجاج",
      "nameEn": "Chicken Shawarma",
      "quantity": "3",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة']",
      "modifiresEn": "['Meal']",
    },
  ],
};

// CASE 7: Added and Deleted Items
const addedAndDeletedCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 3,
      "itemGuid": "3cdc6791-3093-4d53-b250-c976516d49a4",
      "refItemGuid": "",
      "action": "new",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "برجر دجاج",
      "nameEn": "Chicken Burger",
      "quantity": "1",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة']",
      "modifiresEn": "['Meal']",
    },
    {
      "sortOrder": 2,
      "itemGuid": "",
      "refItemGuid": "2cdc6791-3093-4d53-b250-c976516d49a3",
      "action": "delete",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "شاورما دجاج",
      "nameEn": "Chicken Shawarma",
      "quantity": "3",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة']",
      "modifiresEn": "['Meal']",
    },
  ],
};

// CASE 8: All Operations (Modified, Added, and Deleted)
const allOperationsCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 1,
      "itemGuid": "",
      "refItemGuid": "1cdc6791-3093-4d53-b250-c976516d49a2",
      "action": "add",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "مندي دجاج",
      "nameEn": "Chicken Mandi",
      "quantity": "2",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'صلصة حارة']",
      "modifiresEn": "['Meal', 'Spicy Sauce']",
    },
    {
      "sortOrder": 3,
      "itemGuid": "3cdc6791-3093-4d53-b250-c976516d49a4",
      "refItemGuid": "",
      "action": "new",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "برجر دجاج",
      "nameEn": "Chicken Burger",
      "quantity": "1",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة']",
      "modifiresEn": "['Meal']",
    },
    {
      "sortOrder": 2,
      "itemGuid": "",
      "refItemGuid": "2cdc6791-3093-4d53-b250-c976516d49a3",
      "action": "delete",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "شاورما دجاج",
      "nameEn": "Chicken Shawarma",
      "quantity": "3",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة']",
      "modifiresEn": "['Meal']",
    },
  ],
};

// CASE 9: Multiple Modifications to Same Item
const multipleModificationsCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 1,
      "itemGuid": "",
      "refItemGuid": "1cdc6791-3093-4d53-b250-c976516d49a2",
      "action": "add",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "مندي دجاج",
      "nameEn": "Chicken Mandi",
      "quantity": "2",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'صلصة حارة']",
      "modifiresEn": "['Meal', 'Spicy Sauce']",
    },
    {
      "sortOrder": 1,
      "itemGuid": "",
      "refItemGuid": "1cdc6791-3093-4d53-b250-c976516d49a2",
      "action": "add",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "مندي دجاج",
      "nameEn": "Chicken Mandi",
      "quantity": "1",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'صلصة حارة', 'جبنة زيادة']",
      "modifiresEn": "['Meal', 'Spicy Sauce', 'Extra Cheese']",
    },
  ],
};

// CASE 10: Complex Order with Multiple Operations
const complexOrderCase = {
  "id": 17472223323100,
  "invoiceId": "INV-17472223323100",
  "order_id": 17472223323100,
  "created_at": "2025-05-14T11:32:12.399521",
  "status": "Pending",
  "table_number": "T1",
  "customer_name": "John Doe",
  "items": [
    {
      "sortOrder": 1,
      "itemGuid": "",
      "refItemGuid": "1cdc6791-3093-4d53-b250-c976516d49a2",
      "action": "add",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "مندي دجاج",
      "nameEn": "Chicken Mandi",
      "quantity": "2",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'صلصة حارة']",
      "modifiresEn": "['Meal', 'Spicy Sauce']",
    },
    {
      "sortOrder": 2,
      "itemGuid": "",
      "refItemGuid": "2cdc6791-3093-4d53-b250-c976516d49a3",
      "action": "delete",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "شاورما دجاج",
      "nameEn": "Chicken Shawarma",
      "quantity": "2",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة']",
      "modifiresEn": "['Meal']",
    },
    {
      "sortOrder": 3,
      "itemGuid": "3cdc6791-3093-4d53-b250-c976516d49a4",
      "refItemGuid": "",
      "action": "new",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "برجر دجاج",
      "nameEn": "Chicken Burger",
      "quantity": "1",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة']",
      "modifiresEn": "['Meal']",
    },
    {
      "sortOrder": 4,
      "itemGuid": "4cdc6791-3093-4d53-b250-c976516d49a5",
      "refItemGuid": "",
      "action": "new",
      "customerNo": "P1",
      "itemStatus": "Pending",
      "name": "بيتزا دجاج",
      "nameEn": "Chicken Pizza",
      "quantity": "1",
      "orderRefId": "INV-17472223323100",
      "modifires": "['وجبة', 'جبنة زيادة']",
      "modifiresEn": "['Meal', 'Extra Cheese']",
    },
  ],
};
