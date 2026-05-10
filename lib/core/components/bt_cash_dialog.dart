import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_widgets.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/sync_request_helper.dart';
import 'package:kiosk_point_of_sale/data/NearPay/nearpay_api_services.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_paymethod_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/meta_data_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';

class BTCashDialog extends ConsumerStatefulWidget {
  const BTCashDialog({super.key});

  @override
  ConsumerState<BTCashDialog> createState() => _BTCashDialogState();
}

class _BTCashDialogState extends ConsumerState<BTCashDialog> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  TextInputType keyBoardType = TextInputType.numberWithOptions(decimal: true);

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translator(arText: 'ادخل المبلغ', enText: 'Enter Amount'),
              style: FlutterFlowTheme.of(context)
                  .titleMedium
                  .copyWith(color: Colors.black),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              focusNode: _amountFocusNode,
              autofocus: true,
              keyboardType: keyBoardType,
              decoration: InputDecoration(
                hintText:
                    translator(arText: 'ادخل المبلغ', enText: 'Enter Amount'),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  context,
                  text: translator(arText: 'الغاء', enText: 'Cancel'),
                  color: Colors.grey.shade300,
                  textColor: Colors.black,
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                _buildButton(
                  context,
                  text: translator(arText: 'تأكيد', enText: 'Confirm'),
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () async {
                    if (_amountController.text.trim().isEmpty) {
                      Navigator.of(context).pop(null);
                      return;
                    } else {
                      int? orderId;
                      String createdAt = DateTime.now().toIso8601String();
                      String updatedAt = DateTime.now().toIso8601String();
                      String deletedAt = DateTime.now().toIso8601String();
                      final workDate =
                          await SyncRequestHelper().getBusinessDay(createdAt);
                      dPrint("workDate: $workDate");
                      String date = workDate == null
                          ? DateTime.now().toIso8601String().split('T').first
                          : workDate.toIso8601String().split('T').first;

                      final subTotalAmount = 0.0000;
                      final discountType = 0.0000;
                      final discountValue = 0.0000;
                      final discountAmount = 0.0000;
                      final totalAmount =
                          double.tryParse(_amountController.text.trim()) ?? 0.0;
                      final taxAmount =
                          (subTotalAmount - discountAmount) * 0.15;

                      String note = '';
                      int isRefund = 0;
                      final userId = await AppPreferences().getCashierId();
                      final cashierShifts = await CashierShiftTable.getAll();
                      final shift = cashierShifts.first;

                      final tenantId = await AppPreferences().getTenant();
                      final tenderType = await AppPreferences().getTenderType();
                      final storeId = await AppPreferences().getStore();
                      final userName = await AppPreferences().getUsername();
                      final saleId = uuid.v4();
                      SalesOrderModel salesOrder = SalesOrderModel(
                        id: orderId,
                        createdAt: createdAt,
                        customerId: null,
                        saleNotificationDetailId: '',
                        refundResonId: '',
                        change: 0.0,

                        updatedAt: updatedAt,
                        deletedAt: deletedAt,
                        cashierName: userName,
                        haveRefund: 0,
                        invoiceId: null,
                        cashierShiftId: shift.cashierShiftId!,
                        workDate: date,
                        subTotalBeforeDiscount: subTotalAmount
                            .roundToTwoDecimals()
                            .toStringAsFixed(2),
                        totalAmountBeforeDiscount: "",
                        taxBeforeDiscount:
                            taxAmount.roundToTwoDecimals().toStringAsFixed(2),
                        subTotal: subTotalAmount
                            .roundToTwoDecimals()
                            .toStringAsFixed(2),
                        tax: taxAmount.roundToTwoDecimals().toStringAsFixed(2),
                        totalAmount:
                            totalAmount.roundToTwoDecimals().toStringAsFixed(2),
                        note: note,
                        isRefund: isRefund,
                        userId: userId.toString(),
                        tenantId: tenantId,
                        discountType: null,
                        discountValue: null,
                        discount: null,
                        uuid: saleId,
                        orderNumber: '',
                        receiptNumber: null,
                        isBackOfficeSync: 0,
                        isZactaSync: 0,
                        // returnedFromTransactionId: '',
                        customerPhone: "",
                        // icvuuid: 0,
                        // invoiceTypeCode: '',
                        // notValidReason: '',
                        // statusId: 0,
                        paymentMethod: 0,
                        saleTypeId: -1,
                        // templateType: 0,
                      );
                      List<SalesItemsModel> salesOrderItems = [];
                      List<SalesPayMethodModel> salesOrderPayMethods = [
                        SalesPayMethodModel(
                          id: null,
                          nameEn: '',
                          nameAr: '',
                          amount: totalAmount,
                          tenantId: tenantId,

                          tenderTypeId: int.parse(tenderType),
                          orderId: saleId, // New field in fromMap
                          uniqueId: uuid.v4(),
                        )
                      ];
                      SalesInvoice btInvoice = SalesInvoice(
                          salesOrderModel: salesOrder,
                          salesOrderItems: salesOrderItems,
                          salesOrderPayMethods: salesOrderPayMethods);
                      await SalesOrdersRepositoryImpl()
                          .saveSalesOrder(btInvoice, orderNo: null);
                      await MetadataTable.setPtCash(
                          double.tryParse(_amountController.text) ?? 0.0);
                      Navigator.of(context).pop(_amountController.text.trim());
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String text,
      required Color color,
      required Color textColor,
      required VoidCallback onPressed}) {
    return FFButtonWidget(
      onPressed: onPressed,
      text: text,
      options: FFButtonOptions(
        width: 100,
        height: 40,
        color: color,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              fontFamily: 'Readex Pro',
              color: textColor,
            ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// Usage
Future<String?> showBTCashDialog(BuildContext context) async {
  return await showAppDialog<String>(
    context: context,
    builder: (context) => BTCashDialog(),
  );
}
