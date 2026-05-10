abstract class SaleTypesApiInterface {
  /// Fetches sale tender types from the API and stores them in the local database
  Future<void> getSaleTenderTypes();

  /// Fetches sale types from the API and stores them in the local database
  Future<void> getSaleTypes();

  /// Fetches sale type translations from the API and stores them in the local database
  Future<void> getSaleTypeTranslations();

  /// Fetches sale type stores from the API and stores them in the local database
  Future<void> getSaleTypeStores();

  /// Fetches sale type price lists from the API and stores them in the local database
  Future<void> getSaleTypePriceLists();
}
