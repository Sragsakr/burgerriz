import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/confirm_back_dialog.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/enums/discount_enum.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_widgets.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/permission_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/selected_variant_grouping.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/drago/drago_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/invoice_view.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/kiosk_printing/thermal_printer_service.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/network_printing/network_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/optimized_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/loading_services/enhanced_loading_service.dart';
import 'package:kiosk_point_of_sale/core/services/kiosk_mode_services/kiosk_management_service.dart';
import 'package:kiosk_point_of_sale/data/NearPay/nearpay_api_services.dart';
import 'package:kiosk_point_of_sale/data/models/refund_reson_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/data/models/store/device_info_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/refund_reasons/refund_reson_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_orders_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/providers/nearpay_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';
import 'package:uuid/uuid.dart';

class OrderCard extends ConsumerStatefulWidget {
  final SalesInvoice order;
  final bool isAdmin;
  final VoidCallback onRefund;

  const OrderCard({
    super.key,
    required this.order,
    required this.isAdmin,
    required this.onRefund,
  });

  @override
  ConsumerState<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<OrderCard> {
  SaleType? saleType;
  bool isRefunded = false;
  bool isRelatedRefunded = false;

  String? refundReasonText;

  @override
  void initState() {
    getSaleType();
    checkRefund();
    loadRefundReason();
    super.initState();
  }

  getSaleType() async {
    List<SaleType> saleTypes = await generateSaleTypeList();
    setState(() {
      saleType = saleTypes.firstWhere(
          (element) =>
              element.saleTypeId == widget.order.salesOrderModel.saleTypeId,
          orElse: () =>
              SaleType(saleTypeId: 0, nameAr: '', nameEn: '', saleNature: 0));
    });
  }

  checkRefund() async {
    List<SalesOrderModel> salesOrdersDB = await SalesOrderTable.getAll();
    isRefunded = salesOrdersDB.any((element) =>
        element.refReceiptNumber != null &&
        element.refReceiptNumber == widget.order.salesOrderModel.receiptNumber);
    dPrint(
        "isRefunded $isRefunded ${widget.order.salesOrderModel.refReceiptNumber}");
    isRelatedRefunded = salesOrdersDB.any((element) =>
        widget.order.salesOrderModel.refReceiptNumber != null &&
        element.receiptNumber == widget.order.salesOrderModel.refReceiptNumber);
    dPrint(
        "isRelatedRefunded $isRelatedRefunded receiptNumber ${widget.order.salesOrderModel.refReceiptNumber}");
    setState(() {});
  }

  loadRefundReason() async {
    if (widget.order.salesOrderModel.isRefund == 1) {
      try {
        final reasonId =
            int.tryParse(widget.order.salesOrderModel.refundResonId ?? '');
        if (reasonId != null) {
          final reason = await RefundResonTable.getById(reasonId);
          if (reason != null) {
            setState(() {
              refundReasonText = reason.description;
            });
          }
        }
      } catch (e) {
        dPrint('Error loading refund reason: $e');
      }
    }
  }

  Future<void> handleNearpayPayment(
    BuildContext context,
    WidgetRef ref,
    double nearpayTotal, {
    required String originalTransactionUUID,
    required String transactionId,
  }) async {
    print('Processing Nearpay: $nearpayTotal');
    DeviceConfigModel? appConfig = await DeviceConfigTable.getDeviceInfo();
    if (appConfig == null) {
      throw Exception('No app config found in the database');
    }

    if (appConfig.terminalId == null) {
      ref.read(nearpayPaymentDoneProvider.notifier).state = true;
    } else {
      await handleNearpayTransactionRefund(
        originalTransactionUUID: originalTransactionUUID,
        transactionId: transactionId,
        terminalID: appConfig.terminalId!,
        amount: (nearpayTotal * 100).toInt(),
        context: context,
        ref: ref,
      );
    }
  }

  Future<RefundResonModel?> _showRefundReasonDialog() async {
    List<RefundResonModel> reasons = await RefundResonTable.getAll();

    // If no reasons in local database, return null
    if (reasons.isEmpty) {
      customSnackbar(
          context,
          translator(
              arText: "لا توجد أسباب للإرجاع، يرجى مزامنة البيانات أولاً",
              enText: "No refund reasons available, please sync data first"),
          true);
      return null;
    }

    return showAppDialog<RefundResonModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        RefundResonModel? tempSelectedReason;
        return AlertDialog(
          title: Text(
            translator(
                arText: "اختر سبب الإرجاع", enText: "Select Refund Reason"),
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyLarge,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: reasons.length,
                      itemBuilder: (context, index) {
                        final reason = reasons[index];
                        return RadioListTile<RefundResonModel>(
                          title: Text(reason.description),
                          value: reason,
                          groupValue: tempSelectedReason,
                          onChanged: (RefundResonModel? value) {
                            setState(() {
                              tempSelectedReason = value;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        translator(arText: "إلغاء", enText: "Cancel"),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    MaterialButton(
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        translator(arText: "تأكيد", enText: "Confirm"),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        if (tempSelectedReason != null) {
                          Navigator.of(context).pop(tempSelectedReason);
                        } else {
                          // Show error that selection is required
                          customSnackbar(
                              context,
                              translator(
                                  arText: "يرجى اختيار سبب للإرجاع",
                                  enText: "Please select a refund reason"),
                              true);
                        }
                      },
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

  List<Widget> _buildGroupedOrderVariations(
    BuildContext context,
    List<Map<String, dynamic>> variations,
  ) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final out = <Widget>[];
    var firstGroup = true;
    for (final group in groupVariationMaps(variations)) {
      if (!firstGroup) {
        out.add(const SizedBox(height: 4));
      }
      firstGroup = false;
      final header = variationMapGroupHeader(group.first, isEnglish);
      if (header.isNotEmpty) {
        out.add(
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: Text(
              header,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
      for (final variation in group) {
        String variationText = 'N/A';
        String mainTranslation = '';
        if (isEnglish) {
          variationText = variation['variationNameEn'] ?? 'N/A';
        } else {
          variationText = variation['variationNameAr'] ?? 'N/A';
        }
        final mainAr = variation['mainTranslationAr'] ?? '';
        final mainEn = variation['mainTranslationEn'] ?? '';
        if (mainAr.isNotEmpty || mainEn.isNotEmpty) {
          mainTranslation = isEnglish ? mainEn : mainAr;
          if (mainTranslation.isNotEmpty) {
            mainTranslation = '($mainTranslation)';
          }
        }
        if (variationText.isEmpty || variationText == 'N/A') {
          if (variation['variantValueId'] != null) {
            variationText = 'Variant ${variation['variantValueId']}';
          }
        }
        final qty = (variation['quantity'] as num?)?.toDouble() ?? 1.0;
        final qtyLabel = qty > 1 ? ' x${qty.toInt()}' : '';
        final isFree = variation['isFree'] == true;
        final price = (variation['variationPrice'] as num?)?.toDouble() ?? 0.0;
        out.add(
          Padding(
            padding:
                EdgeInsets.only(left: header.isNotEmpty ? 8.0 : 0, bottom: 2.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '  • $variationText$qtyLabel $mainTranslation',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 12),
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                if (isFree)
                  Text(
                    isEnglish ? 'Free' : 'مجاني',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 11),
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (price > 0)
                  Text(
                    '+${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 11),
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    // dPrint(widget.order.salesOrderModel.id.toString());
    DateTime dateTime = DateTime.parse(widget.order.salesOrderModel.createdAt);

    // Format the date
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

    // Format the time
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    return InkWell(
      onTap: () {
        dPrint(widget.order.toJson().toString());
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.order.salesOrderModel.isZactaSync == 0)
                    CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.red,
                      child: Text(
                        "Z",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 9)),
                      ),
                    ),
                  if (widget.order.salesOrderModel.isBackOfficeSync == 0)
                    CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.red,
                      child: Text(
                        "B",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 9)),
                      ),
                    ),
                  Text(
                    "${translator(arText: 'رقم الفاتورة: ', enText: 'Invoice No: ')} ${widget.order.salesOrderModel.receiptNumber}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  if (widget.order.salesOrderModel.isRefund == 1)
                    Text(
                      translator(arText: 'مرتجع', enText: 'Refunded'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              // if (widget.order.salesOrderModel.refReceiptNumber != null)
              //   Row(
              //     children: [
              //       Text(
              //         "${translator(arText: 'رقم الفاتورة المرجعي: ', enText: 'Ref Invoice No: ')} ${widget.order.salesOrderModel.refReceiptNumber}",
              //         style: const TextStyle(fontWeight: FontWeight.bold),
              //       ),
              //     ],
              //   ),
              // Text("Customer Name: ${order.salesOrderModel.customerName}"),
              Row(
                children: [
                  Text(
                      "${translator(arText: 'الأجمالي: ', enText: 'Total Amount:')} ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(double.parse(widget.order.salesOrderModel.totalAmount)
                      .roundToTwoDecimals()
                      .toString()),
                ],
              ),
              if ((widget.order.salesOrderModel.discount ?? 0) > 0)
                Row(
                  children: [
                    Text(
                        "${translator(arText: 'الخصم: ', enText: 'Discount:')} ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (widget.order.salesOrderModel.discountType ==
                        DiscountType.percentage.value)
                      Text(
                        '(${widget.order.salesOrderModel.discount}%)',
                      ),
                    Text(
                        "${widget.order.salesOrderModel.discountValue?.roundToTwoDecimals().toStringAsFixed(2)}"),
                  ],
                ),
              // Text("Status: ${order.salesOrderModel.status}"),
              Row(
                children: [
                  Text(
                      "${translator(arText: 'وقت الطلب: ', enText: 'Created At:')}: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(" $formattedDate $formattedTime"),
                ],
              ),
              if (saleType != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "${translator(arText: 'نوع الطلب: ', enText: 'Sale Type:')}  ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      translator(
                          arText: saleType!.nameAr, enText: saleType!.nameEn),
                    ),
                  ],
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      "${translator(arText: "يوم العمل :", enText: 'Business Day')}  ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    widget.order.salesOrderModel.workDate,
                  ),
                ],
              ),

              // Display refund reason if this is a refunded order
              if (widget.order.salesOrderModel.isRefund == 1 &&
                  refundReasonText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${translator(arText: "سبب الإرجاع:", enText: 'Refund Reason:')}  ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          refundReasonText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              Text("${translator(arText: 'المنتجات: ', enText: 'Items:')}:",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: widget.order.salesOrderItems.map((item) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(translator(
                                arText:
                                    '${item.productNameAr}${item.unitNameAr != null && item.unitNameAr!.isNotEmpty ? " - ${item.unitNameAr}" : ""}',
                                enText:
                                    '${item.productNameEn}${item.unitNameEn != null && item.unitNameEn!.isNotEmpty ? " - ${item.unitNameEn}" : ""}')),
                          ),
                          Expanded(flex: 1, child: Text("x${item.quantity}")),
                          Expanded(flex: 1, child: Text(item.price)),
                        ],
                      ),
                      // Display variations if any
                      if (item.variations != null &&
                          item.variations!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildGroupedOrderVariations(
                                context, item.variations!),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.isAdmin)
                    if (!isRefunded && !isRelatedRefunded)
                      Center(
                        child: FFButtonWidget(
                          text: translator(arText: 'إرجاع', enText: 'Refund'),
                          onPressed: () async {
                            // Then show confirmation dialog
                            final res = await showAppDialog(
                              context: context,
                              builder: (context1) => ConfirmBackDialog(
                                  arMsg:
                                      'هل انت متأكد من إرجاع الطلب رقم ${widget.order.salesOrderModel.receiptNumber}',
                                  enMsg:
                                      'Are you sure you want to refund order number ${widget.order.salesOrderModel.receiptNumber} ',
                                  onAccept: () async {
                                    Navigator.pop(context1);
                                    // First show reason selection dialog
                                    final reason =
                                        await _showRefundReasonDialog();
                                    dPrint("selectedReason is $reason");
                                    if (reason == null) {
                                      // User cancelled or no reason selected
                                      return;
                                    }
                                    String refNumber = widget.order
                                            .salesOrderModel.receiptNumber ??
                                        '';
                                    String refSaleTransactionModelId =
                                        widget.order.salesOrderModel.uuid ?? '';
                                    final refundUUid = uuid.v4();

                                    /// here will make refund with near pay if not done do not complete
                                    bool paymentsNotEmpty = widget
                                        .order.salesOrderPayMethods.isNotEmpty;
                                    bool haveNearPay = paymentsNotEmpty &&
                                        widget.order.salesOrderPayMethods.any(
                                            (e) =>
                                                e.nameEn.toLowerCase() ==
                                                    "nearpay" ||
                                                (e.nameAr.toLowerCase() ==
                                                    "نيرباي"));

                                    if (haveNearPay) {
                                      final nearPayMethod = widget
                                          .order.salesOrderPayMethods
                                          .firstWhereOrNull((e) =>
                                              e.nameEn.toLowerCase() ==
                                                  "nearpay" ||
                                              (e.nameAr.toLowerCase() ==
                                                  "نيرباي"));
                                      if (nearPayMethod == null) {
                                        return;
                                      }
                                      final amount = nearPayMethod.amount;
                                      bool deviceHavePermissions =
                                          await checkDeviceRequirements();

                                      try {
                                        if (!deviceHavePermissions) {
                                          await KioskManagementService()
                                              .stopKiosk();
                                        }

                                        await handleNearpayPayment(
                                          context,
                                          ref,
                                          amount,
                                          originalTransactionUUID:
                                              refSaleTransactionModelId,
                                          transactionId: refundUUid,
                                        );
                                        bool userPermissions =
                                            await checkDeviceRequirements();

                                        if (!deviceHavePermissions &&
                                            userPermissions) {
                                          await KioskManagementService()
                                              .startKiosk();
                                        }
                                      } catch (e, t) {
                                        bool userPermissions =
                                            await checkDeviceRequirements();

                                        if (!deviceHavePermissions &&
                                            userPermissions) {
                                          await KioskManagementService()
                                              .startKiosk();
                                        }
                                        dPrint(e.toString());
                                        dPrint(t.toString());
                                        customSnackbar(
                                            navKey.currentState!.context,
                                            "Error during Refund From NearPay",
                                            false);
                                      }
                                      if (ref
                                              .read(nearpayPaymentDoneProvider
                                                  .notifier)
                                              .state !=
                                          true) {
                                        return;
                                      }
                                    }
                                    await updateOldOrder();

                                    try {
                                      /// new Refund Invoice
                                      await saveRefundOrder(
                                        refNumber,
                                        refSaleTransactionModelId,
                                        reason.id.toString(),
                                        reason.description.toString(),
                                        refundUUid,
                                      );

                                      enhancedLoadingService
                                          .showEnhancedLoading(
                                        context,
                                        message: translator(
                                            arText: "جاري طباعة الفاتورة",
                                            enText: "Printing Invoice"),
                                        isLottie: true,
                                      );
                                      List<int> printingData = [];

                                      await enhancedLoadingService
                                          .processPrinting(
                                        operationType: translator(
                                            arText: "فاتورة",
                                            enText: "Invoice"),
                                        // generateInvoice: () async {
                                        //   return widget.order;
                                        // },
                                        generatePdf: () async {
                                          printingData =
                                              await OptimizedPrinterController
                                                  .getOptimizedInvoicePdfByMode(
                                            invoice: widget.order,
                                          );
                                          return printingData;
                                        },
                                        // saveOrder: () async {
                                        //   return;
                                        // },
                                        sendInvoice: null,
                                        printInvoice: () async {
                                          String selectedMode =
                                              await AppPreferences()
                                                  .getPrinterMode();
                                          if (selectedMode == 'network') {
                                            await NetworkPrinterController
                                                .printInvoice(
                                                    data: printingData,
                                                    withSnac: false);
                                          } else {
                                            await DragoPrinterController
                                                .printInvoiceData(
                                                    data: printingData,
                                                    withSnac: false);
                                          }
                                        },
                                      );

                                      /// new Empty Invoice
                                      await saveNewOrder(
                                          refNumber, refSaleTransactionModelId);

                                      customSnackbar(
                                          context,
                                          translator(
                                              arText: 'تم الارجاع بنجاح',
                                              enText:
                                                  "Order Refund Successfully"),
                                          false);
                                      enhancedLoadingService.hideLoading();
                                      widget.onRefund.call();
                                    } catch (e, t) {
                                      // hideLoading(context);
                                      dPrint(e.toString());
                                      dPrint(t.toString());
                                      hideLoading(context);
                                      customSnackbar(
                                          context, e.toString(), false);
                                      return;
                                    }
                                  }),
                            );
                          },
                          options: FFButtonOptions(
                            width: 100,
                            height: 30.0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: !isRefunded
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.3),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  fontWeight: FontWeight.w400,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 15),
                                ),
                            elevation: 2.0,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                            hoverColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                  Center(
                    child: FFButtonWidget(
                      text: translator(
                          arText: 'عرض الفاتورة', enText: 'Show Invoice'),
                      onPressed: () async {
                        final deviceInfo =
                            await DeviceConfigTable.getDeviceInfo();
                        showAppDialog(
                          context: context,
                          builder: (context1) => InvoiceView(
                              invoice: widget.order,
                              deviceConfigModel: deviceInfo),
                        );
                      },
                      options: FFButtonOptions(
                        width: 100,
                        height: 30.0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: Theme.of(context).colorScheme.primary,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              fontFamily: 'Readex Pro',
                              fontWeight: FontWeight.w400,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 15),
                            ),
                        elevation: 2.0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                        hoverColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: FFButtonWidget(
                      text: translator(
                          arText: 'إعادة الطباعة', enText: 'Reprint'),
                      onPressed: () async {
                        enhancedLoadingService.showEnhancedLoading(
                          context,
                          message: translator(
                              arText: "جاري طباعة الفاتورة",
                              enText: "Printing Invoice"),
                          isLottie: true,
                        );
                        List<int> printingData = [];
                        await enhancedLoadingService.processPrinting(
                          operationType:
                              translator(arText: "فاتورة", enText: "Invoice"),
                          // generateInvoice: () async {
                          //   return widget.order;
                          // },
                          generatePdf: () async {
                            // Use optimized PDF generation
                            printingData = await OptimizedPrinterController
                                .getOptimizedInvoicePdfByMode(
                              invoice: widget.order,
                            );
                            return printingData;
                          },
                          // saveOrder: () async {
                          //   return;
                          // },
                          sendInvoice: null,
                          printInvoice: () async {
                            String selectedMode =
                                await AppPreferences().getPrinterMode();
                            if (selectedMode == 'network') {
                              await NetworkPrinterController.printInvoice(
                                  data: printingData, withSnac: false);
                            } else {
                              await DragoPrinterController.printInvoiceData(
                                  data: printingData, withSnac: false);
                            }
                          },
                        );
                        enhancedLoadingService.hideLoading();
                      },
                      options: FFButtonOptions(
                        width: 100,
                        height: 30.0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: Theme.of(context).colorScheme.primary,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              fontFamily: 'Readex Pro',
                              fontWeight: FontWeight.w400,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 15),
                            ),
                        elevation: 2.0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                        hoverColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  Center(
                    child: FFButtonWidget(
                      text: translator(
                          arText: 'ارسال الفاتورة', enText: 'Send Invoice'),
                      onPressed: () async {
                        final zatcaApiService =
                            ref.watch(zatcaApiServiceProvider);

                        if (widget
                            .order.salesOrderModel.customerPhone.isNotEmpty) {
                          showLoading(context);
                          try {
                            await zatcaApiService
                                .sendInvoiceToPhone(widget.order);
                            // save invoice
                          } catch (e, t) {
                            customSnackbar(context, e.toString(), false);
                            dPrint(e.toString());
                            dPrint(t.toString());
                          }
                        } else {
                          customSnackbar(
                              context,
                              translator(
                                  arText: "لا يوجد رقم هاتف ",
                                  enText: "No Phone Number"),
                              false);
                        }
                        hideLoading(context);
                      },
                      options: FFButtonOptions(
                        width: 100,
                        height: 30.0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: widget
                                .order.salesOrderModel.customerPhone.isNotEmpty
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                        textStyle: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              fontFamily: 'Readex Pro',
                              fontWeight: FontWeight.w400,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 15),
                            ),
                        elevation: 2.0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                        hoverColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveNewOrder(
    String refNumber,
    String refSaleTransactionModelId,
  ) async {
    SalesInvoice coby = widget.order.copy();
    final storeId = await AppPreferences().getStore();
    // final receiptNumber = await receiptID(int.parse(storeId));

    // String createdAt = DateTime.now().toIso8601String();
    // widget.order.salesOrderModel.createdAt = createdAt;

    /// new Empty Invoice
    coby.salesOrderModel.id = null;
    coby.salesOrderModel.refSaleTransactionModelId = refSaleTransactionModelId;
    coby.salesOrderModel.totalAmount = "0.0";
    coby.salesOrderModel.tax = "0.0";
    coby.salesOrderModel.subTotal = "0.0";
    coby.salesOrderModel.discountAmount = 0.0;
    coby.salesOrderModel.promotionValue = 0.0;
    coby.salesOrderModel.promotionAmount = 0.0;
    coby.salesOrderModel.promotionCode = null;
    coby.salesOrderModel.promotionName = null;
    coby.salesOrderModel.promotionType = null;
    coby.salesOrderModel.promotionId = null;

    coby.salesOrderModel.isRefund = 0;
    coby.salesOrderModel.uuid = const Uuid().v4();
    coby.salesOrderModel.refReceiptNumber = refNumber;
    coby.salesOrderModel.receiptNumber = refNumber;
    coby.salesOrderModel.isBackOfficeSync = 0;
    coby.salesOrderModel.isZactaSync = 1;
    coby.salesOrderItems = [];
    coby.salesOrderPayMethods = [];
    await SalesOrdersRepositoryImpl().saveSalesOrder(coby, orderNo: null);
  }

  Future<void> updateOldOrder() async {
    /// new Empty Invoice
    widget.order.salesOrderModel.haveRefund = 1;

    await SalesOrdersRepositoryImpl().updateSalesOrder(widget.order);
  }

  Future<void> saveRefundOrder(
    String refNumber,
    String refSaleTransactionModelId,
    String refundResonId,
    String saleNotificationDetailId,
    String refundUUid,
  ) async {
    SalesInvoice coby = widget.order.copy();

    final storeId = await AppPreferences().getStore();
    final receiptNumber = await receiptIDRefund();

    String createdAt = DateTime.now().toIso8601String();
    coby.salesOrderModel.createdAt = createdAt;
    coby.salesOrderModel.id = null;
    coby.salesOrderModel.refSaleTransactionModelId = refSaleTransactionModelId;
    coby.salesOrderModel.isRefund = 1;
    coby.salesOrderModel.refReceiptNumber = refNumber;
    coby.salesOrderModel.receiptNumber = receiptNumber;

    coby.salesOrderModel.isBackOfficeSync = 0;
    coby.salesOrderModel.isZactaSync = 0;
    coby.salesOrderModel.refundResonId = refundResonId;
    coby.salesOrderModel.saleNotificationDetailId = saleNotificationDetailId;
    coby.salesOrderModel.uuid = const Uuid().v4();
    for (var item in coby.salesOrderItems) {
      item.id = null;
      item.isRefund = 1;
    }
    for (var payMethod in coby.salesOrderPayMethods) {
      payMethod.id = null;
    }

    await SalesOrdersRepositoryImpl().saveSalesOrder(coby, orderNo: '');
  }
}
