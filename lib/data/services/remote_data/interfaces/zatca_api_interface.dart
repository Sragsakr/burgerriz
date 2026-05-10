import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/zatca_invoice_model.dart';

/// Interface for Zatca-related API operations
abstract class ZatcaApiInterface {
  /// Send an invoice to the customer's phone
  Future<void> sendInvoiceToPhone(SalesInvoice invoice);

  /// Send an invoice to Zatca and return the invoice model
  Future<ZatcaInvoiceModel?> sendInvoice(SalesInvoice invoice);

  /// Send a return (refund) invoice
  Future<String?> sendReturnInvoice(SalesInvoice invoice);

  /// Get Zatca authentication token
  Future<String> getToken();
}
