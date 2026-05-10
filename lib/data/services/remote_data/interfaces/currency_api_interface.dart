import 'package:kiosk_point_of_sale/data/models/store/currency_model.dart';

/// Interface for Currency-related API operations
abstract class CurrencyApiInterface {
  /// Fetch currencies from the API and sync with local database
  Future<List<CurrencyModel>> fetchCurrencies();
}
