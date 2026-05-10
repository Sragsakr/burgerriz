import 'dart:convert';
import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/constants/zatca_constants.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zatca_2_invoice_generator/zatca_2_invoice_generator.dart';

pw.Widget buildZatcaQrCode(SalesInvoice invoice) {
  DateTime dateTime = DateTime.parse(invoice.salesOrderModel.createdAt);

  String formattedDate = intl.DateFormat('dd/MM/yyyy').format(dateTime);

  List<InvoiceLine> invoiceLines = [];
  for (var item in invoice.salesOrderItems) {
    invoiceLines.add(
      InvoiceLine(
        id: item.uniqueId.toString(),
        quantity: item.quantity.toString(),
        unitCode: item.productId.toString(),
        lineExtensionAmount: item.price.toString(),
        itemName: item.productNameEn.toString(),
        taxPercent: item.tax.toString(),
      ),
    );
  }

  final now = DateTime.now();
  final timeStr =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

  final qrDataModel = ZatcaManager.instance.generateZatcaQrInit(
    totalVat: invoice.salesOrderModel.tax.toString(),
    totalWithVat: invoice.salesOrderModel.totalAmount.toString(),
    issueDate: dateTime.toIso8601String(),
    invoiceUUid: invoice.salesOrderModel.uuid.toString(),
    invoiceNumber: invoice.salesOrderModel.receiptNumber.toString(),
    issueTime: timeStr,
    invoiceLines: invoiceLines,
    invoiceType: ZatcaConstants.invoiceType,
  );

  // Ensure QR code data is properly encoded
  final qrContent = utf8.encode(getQrCodeContent(qrDataModel));
  // dPrint("qrContent $qrContent");
  return pw.BarcodeWidget(
    width:AppConfig.isMobile?295: 150,
    height:AppConfig.isMobile?295:  150,
    backgroundColor: PdfColors.white,
    barcode: pw.Barcode.qrCode(
      errorCorrectLevel: pw.BarcodeQRCorrectionLevel.medium,
    ),
    data: String.fromCharCodes(qrContent),
  );
}

String buildZatcaQrCodeContent(SalesInvoice invoice) {
  DateTime dateTime = DateTime.parse(invoice.salesOrderModel.createdAt);

  List<InvoiceLine> invoiceLines = [];
  for (var item in invoice.salesOrderItems) {
    invoiceLines.add(
      InvoiceLine(
        id: item.uniqueId.toString(),
        quantity: item.quantity.toString(),
        unitCode: item.productId.toString(),
        lineExtensionAmount: item.price.toString(),
        itemName: item.productNameEn.toString(),
        taxPercent: item.tax.toString(),
      ),
    );
  }

  final now = DateTime.now();
  final timeStr =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

  final qrDataModel = ZatcaManager.instance.generateZatcaQrInit(
    totalVat: invoice.salesOrderModel.tax.toString(),
    totalWithVat: invoice.salesOrderModel.totalAmount.toString(),
    issueDate: dateTime.toIso8601String(),
    invoiceUUid: invoice.salesOrderModel.uuid.toString(),
    invoiceNumber: invoice.salesOrderModel.orderNumber.toString(),
    issueTime: timeStr,
    invoiceLines: invoiceLines,
    invoiceType: ZatcaConstants.invoiceType,
  );

  // Ensure QR code data is properly encoded
  final qrContent = utf8.encode(getQrCodeContent(qrDataModel));
  final data = String.fromCharCodes(qrContent);
  return data;
}

Widget buildZatcaQrCodeForScreen(SalesInvoice invoice) {
  DateTime dateTime = DateTime.parse(invoice.salesOrderModel.createdAt);

  final qrDataModel = ZatcaManager.instance.generateZatcaQrInit(
    totalVat: invoice.salesOrderModel.tax.toString(),
    totalWithVat: invoice.salesOrderModel.totalAmount.toString(),
    issueDate: dateTime.toIso8601String(),
    invoiceUUid: invoice.salesOrderModel.uuid.toString(),
    invoiceNumber: invoice.salesOrderModel.receiptNumber.toString(),
    issueTime: "${dateTime.hour}:${dateTime.minute}:${dateTime.second}",
    invoiceLines: [],
    // Provide invoice line data
    invoiceType: ZatcaConstants.invoiceType,
  );

  final qrContent = getQrCodeContent(qrDataModel);

  return BarcodeWidget(
    backgroundColor: Colors.white,
    barcode: Barcode.qrCode(
      errorCorrectLevel: BarcodeQRCorrectionLevel.low,
    ),
    data: qrContent,
    width: 120,
    height: 120,
  );
}

String getQrCodeContent(QrDataModel qrDataModel) {
  Map<int, String> invoiceData = {
    1: qrDataModel.sellerName,
    2: qrDataModel.sellerTRN,
    3: qrDataModel.issueDate,
    4: qrDataModel.invoiceData.totalAmount,
    5: qrDataModel.invoiceData.taxAmount,
    6: qrDataModel.invoiceHash,
    7: qrDataModel.digitalSignature,
    8: qrDataModel.publicKey,
  };

  String tlvString = generateTlv(invoiceData);
  return tlvToBase64(tlvString);
}

String stringToHex(String input) {
  return input.codeUnits
      .map((unit) => unit.toRadixString(16).padLeft(2, '0'))
      .join();
}

String generateTlv(Map<int, String> data) {
  StringBuffer tlv = StringBuffer();

  data.forEach((tag, value) {
    String tagHex = tag.toRadixString(16).padLeft(2, '0'); // Convert tag to hex
    String valueHex = stringToHex(value); // Convert value to hex
    String lengthHex =
        value.length.toRadixString(16).padLeft(2, '0'); // Length in hex

    // Concatenate tag, length, and value into the TLV structure
    tlv.write(tagHex);
    tlv.write(lengthHex);
    tlv.write(valueHex);
  });

  return tlv.toString();
}

String tlvToBase64(String tlv) {
  List<int> bytes = [];

  for (int i = 0; i < tlv.length; i += 2) {
    String hexStr = tlv.substring(i, i + 2); // Two hex characters at a time
    int byte = int.parse(hexStr, radix: 16); // Parse as a byte
    bytes.add(byte);
  }

  Uint8List byteArray = Uint8List.fromList(bytes);
  return base64Encode(byteArray); // Convert to Base64
}
