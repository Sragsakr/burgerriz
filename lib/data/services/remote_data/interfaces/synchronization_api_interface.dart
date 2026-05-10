abstract class SynchronizationApiInterface {
  /// Fetches menu item variations from the API and stores them in the local database
  Future<void> getMenuItemVariations();

  /// Fetches variant table elements from the API and stores them in the local database
  Future<void> getVariantTableElements();

  /// Fetches variant translation elements from the API and stores them in the local database
  Future<void> getVariantTranslationElements();

  /// Fetches variation values from the API and stores them in the local database
  Future<void> getVariationValues();

  /// Fetches variation value translations from the API and stores them in the local database
  Future<void> getVariationValueTranslations();

  /// Fetches variation value translation pricing from the API and stores them in the local database
  Future<void> getVariationValueTranslationPricing();
  Future<void> syncAllComboMealData();

  /// Fetches report group translations from the API and stores them in the local database
  Future<void> getReportGroupTranslations();
}
