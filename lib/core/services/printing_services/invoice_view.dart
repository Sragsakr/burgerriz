import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/enums/discount_enum.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/selected_variant_grouping.dart';
import 'package:kiosk_point_of_sale/core/helpers/zatca_qr_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/store/device_info_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:intl/intl.dart' as intl;

class InvoiceView extends ConsumerStatefulWidget {
  final SalesInvoice invoice;
  final DeviceConfigModel? deviceConfigModel;

  const InvoiceView({super.key, required this.invoice, required this.deviceConfigModel});

  @override
  ConsumerState<InvoiceView> createState() => _InvoiceViewState();
}

class _InvoiceViewState extends ConsumerState<InvoiceView> {
  SaleType? saleType;
  DeviceConfigModel? deviceInfo;

  getSaleType() async {
    List<SaleType> saleTypes = await generateSaleTypeList();
    setState(() {
      saleType = saleTypes.firstWhere((element) => element.saleTypeId == widget.invoice.salesOrderModel.saleTypeId,
          orElse: () => SaleType(saleTypeId: 0, nameAr: '', nameEn: '', saleNature: 0));
    });
  }

  getDeviceInfo() async {
    final info = await DeviceConfigTable.getDeviceInfo();
    setState(() {
      deviceInfo = info;
    });
  }

  @override
  void initState() {
    getSaleType();
    getDeviceInfo();
    super.initState();
  }

  List<Widget> _buildGroupedInvoiceVariationRows(
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
            padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
            child: Text(
              header,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
      for (final variation in group) {
        String variationText = 'N/A';
        String mainTranslation = '';
        variationText = "${variation['variationNameAr']} - ${variation['variationNameEn']}";
        final mainAr = variation['mainTranslationAr'] ?? '';
        final mainEn = variation['mainTranslationEn'] ?? '';
        if (mainAr.isNotEmpty || mainEn.isNotEmpty) {
          mainTranslation = "($mainAr - $mainEn)";
        }
        if (variationText.isEmpty || variationText == 'N/A' || variationText == ' - ') {
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
            padding: EdgeInsets.only(
              left: header.isNotEmpty ? 24.0 : 16.0,
              top: 2.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '  • $variationText$qtyLabel $mainTranslation',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                if (isFree)
                  Text(
                    isEnglish ? 'Free' : 'مجاني',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (price > 0)
                  Text(
                    '+${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
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

  List<Widget> _buildComboMealInvoiceRows(List<Map<String, dynamic>> combos) {
    final out = <Widget>[];
    for (final combo in combos) {
      final nameAr = combo['comboNameAr']?.toString() ?? '';
      final nameEn = combo['comboNameEn']?.toString() ?? '';
      final pair = '$nameAr - $nameEn'.trim();
      final label = (pair.isEmpty || pair == '-') ? '  • ' : '  • $pair';
      final priceRaw = combo['price'];
      final priceNum = priceRaw is num ? priceRaw.toDouble() : double.tryParse(priceRaw?.toString() ?? '') ?? 0.0;
      out.add(
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 2.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              if (priceNum > 0)
                Text(
                  '+${priceNum.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final bool isRefund = widget.invoice.salesOrderModel.isRefund == 1;
    String ext = isRefund ? "2" : "1";
    final preRecipe = "${deviceInfo?.storeCode ?? ''}-${deviceInfo?.deviceNumber ?? ''}$ext-";
    final recieptNumber = preRecipe + (invoice.salesOrderModel.receiptNumber ?? '');
    final refRecieptNumber =
        (invoice.salesOrderModel.refReceiptNumber != null && invoice.salesOrderModel.refReceiptNumber?.length != 0)
            ? (preRecipe + (invoice.salesOrderModel.refReceiptNumber ?? ''))
            : "";
    DateTime dateTime = DateTime.parse(invoice.salesOrderModel.createdAt);

    // Format the date
    String formattedDate = intl.DateFormat('dd/MM/yyyy').format(dateTime);

    // Format the time
    String formattedTime = intl.DateFormat('hh:mm a').format(dateTime);
    String issueDate = '$formattedDate-$formattedTime';
    String regNo = widget.deviceConfigModel?.vat ?? '';
    String arTitle = invoice.salesOrderModel.isRefund == 1 ? 'مذكرة أئتمان مبسطه' : 'فاتورة ضريبية مبسطة';
    String enTitle = invoice.salesOrderModel.isRefund == 1 ? 'Simplified Credit Note' : "Simplified Tax Invoice";
    final totalDiscount = (invoice.salesOrderModel.discountValue ?? 0) + (invoice.salesOrderModel.promotionValue ?? 0);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0.8,
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
        flexibleSpace: FlexibleSpaceBar(
          title: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  translator(arText: ' فاتورة  ', enText: "Invoice "),
                  // 'POS',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Outfit',
                        color: FlutterFlowTheme.of(context).gray600,
                      ),
                ),
                Text(
                  "#${translator(arText: widget.invoice.salesOrderModel.orderNumber, enText: widget.invoice.salesOrderModel.orderNumber)}",
                  // 'POS',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Outfit',
                        color: FlutterFlowTheme.of(context).gray600,
                      ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          expandedTitleScale: 1.0,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFFAF2A26),
            size: 30.0,
          ),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Container(
              //   color: Colors.white,
              //   width: 400,
              //   child: Image.asset('assets/images/logo.png'),
              // ),
              Container(
                color: Colors.white,
                child: Center(
                  child: Text(enTitle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Container(
                color: Colors.white,
                child: Center(
                  child: Text(arTitle,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Container(
                color: Colors.white,
                child: const Center(
                  child: Text('---------------------------------------------',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text('رقم الفاتورة : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    // Text(invoice.salesOrderModel.localInvoiceNo.toString(),
                    //     style: const TextStyle(
                    //       color: Colors.black,
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.bold,
                    //     )),
                    const Spacer(flex: 1),
                    Text(recieptNumber,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    const Spacer(flex: 1),
                    const Text(' : Invoice No',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Center(
                      child: Text('اسم المتجر',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Center(
                      child: Text("Store Name",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.deviceConfigModel?.companyName ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Center(
                      child: Text('كود المتجر',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Center(
                      child: Text("Store Code",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.deviceConfigModel?.storeCode ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Center(
                      child: Text('عنوان المتجر',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Center(
                      child: Text("Store Address",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: AutoSizeText(
                        widget.deviceConfigModel?.address ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: const Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text('رقم تسجيل الضريبة: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    Spacer(flex: 1),
                    Text(' : Registration No',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),

              Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(regNo,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: const Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text('تاريخ  : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    Spacer(flex: 1),
                    Text(' :  Date',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(invoice.salesOrderModel.workDate,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: const Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text('تاريخ الإصدار : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    Spacer(flex: 1),
                    Text(' : Issue Date',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(issueDate,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              if (saleType != null)
                Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(translator(arText: saleType!.nameAr, enText: saleType!.nameAr),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                      Text("-",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(translator(arText: saleType!.nameEn, enText: saleType!.nameEn),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              Container(
                color: Colors.white,
                child: const Center(
                  child: Text('---------------------------------------------',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),

                decoration: const BoxDecoration(
                  color: Colors.white,
                  // border: Border(
                  //     top: BorderSide(color: Colors.black),
                  //     bottom: BorderSide(color: Colors.black))
                ),
                // width: 295,
                child: const Row(children: [
                  Expanded(
                    flex: 1,
                    child: Text('المنتجات\nProducts',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('الكمية\nQty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('سعر المنتج\nPrice',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('قيمة الضريبة \nالمضافة \nTaxs',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('سعر المنتج \nشامل الضريبة\nPrice with tax',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ]),
              ),
              Container(
                color: Colors.white,
                child: const Center(
                  child: Text('---------------------------------------------',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Column(
                children: [
                  ...invoice.salesOrderItems.map((item) {
                    final itemSubTotal = (double.parse(item.price) / 1.15);
                    final itemTax = double.parse(item.price) - itemSubTotal;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          // First line: Product name (full width)
                          Row(children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        '${item.productNameAr}${item.unitNameAr != null && item.unitNameAr!.isNotEmpty ? " - ${item.unitNameAr}" : ""}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        '${item.productNameEn}${item.unitNameEn != null && item.unitNameEn!.isNotEmpty ? " - ${item.unitNameEn}" : ""}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                          // Display variations if any
                          if (item.variations != null && item.variations!.isNotEmpty)
                            ..._buildGroupedInvoiceVariationRows(context, item.variations!),
                          if (item.comboMealItems != null && item.comboMealItems!.isNotEmpty)
                            ..._buildComboMealInvoiceRows(item.comboMealItems!),

                          /// will add free item here
                          if (item.selectedFreeProductName != null && item.selectedFreeProductName!.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            " (   ${item.selectedFreeProductQuantity?.toString() ?? ''}  ${translator(arText: "Qty", enText: "Qty")}",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            )),
                                        Text(" ${translator(arText: " مجاني", enText: "Free )")}  ",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.selectedFreeProductName ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Text(item.selectedFreeProductNameAr ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          // Second line: Quantity, Price, Tax, Total
                          Row(children: [
                            Expanded(
                              flex: 1,
                              child: Text(item.quantity,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(item.price,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(item.vatBeforeDiscount.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(item.total,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ]),
                          Container(
                            color: Colors.white,
                            child: const Center(
                              child: Text('---------------------------------------------',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                ],
              ),

              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اجمالي المبلغ الخاضع للضريبه',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('Total Without Tax',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    Text(double.parse(invoice.salesOrderModel.subTotal).toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              if ((totalDiscount) > 0)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الخصم',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          Text('Discount',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      // if (invoice.salesOrderModel.discountType ==
                      //     DiscountType.percentage.value)
                      //   Text(
                      //     ' (${invoice.salesOrderModel.discount}%) ',
                      //     style: const TextStyle(
                      //       color: Colors.black,
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      Text(totalDiscount.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ضريبة القيمة المضافة [15 %]',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('Tax [15 %]',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    Text(invoice.salesOrderModel.tax,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المجموع مع الضريبة [15 %]',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('Total With Tax [15 %]',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    Text(invoice.salesOrderModel.totalAmount,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              if (invoice.salesOrderModel.change != null && invoice.salesOrderModel.change! > 0)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("الباقي",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          Text("change",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      Text(invoice.salesOrderModel.change.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),

              // Payment Methods Section
              Container(
                color: Colors.white,
                child: const Center(
                  child: Text('---------------------------------------------',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('طرق الدفع',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(width: 10),
                    Text('Payment Methods',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: const Center(
                  child: Text('---------------------------------------------',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              // Payment Methods Details
              ...invoice.salesOrderPayMethods.map((paymentMethod) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(paymentMethod.nameAr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              )),
                          Text(paymentMethod.nameEn,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      Text(paymentMethod.amount.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                );
              }),

              Container(
                color: Colors.white,
                child: Center(
                  child: Text('<<<<<<<<${'  ${invoice.salesOrderModel.orderNumber}اغلاق الفاتورة   '}>>>>>>>>',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Container(
                color: Colors.white,
                child: Center(
                  child: Text('<<<<<<<< close invoice ${invoice.salesOrderModel.orderNumber} >>>>>>>>',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (widget.deviceConfigModel != null) invoiceQrCode(invoice),
              const SizedBox(
                height: 20,
              ),
              // Container(
              //   color: Colors.white,
              //   height: 150,
              //   width: 150,
              //   child: Center(
              //     child: QrImageView(
              //       data: invoice.salesOrderModel.qrData,
              //       version: QrVersions.auto,
              //       size: 200,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

invoiceQrCode(SalesInvoice invoice, {double size = 200}) {
  return Container(
    color: Colors.white,
    width: 200,
    height: 200,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BarcodeWidget(
          width: 195,
          height: 195,
          data: buildZatcaQrCodeContent(invoice),
          barcode: Barcode.qrCode(),
        ),
        // Expanded(
        //   child: Zatca2InvoiceQrGenerator(
        //     qrDataModel: qrDataModel,
        //     size: 120,
        //     backgroundColor: Colors.white,
        //   ),
        // ),
      ],
    ),
  );
}
