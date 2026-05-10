abstract class MenuItemApiInterface {
  Future<void> syncMenuItemsFB();
  Future<void> syncMenuItemTranslations();
  Future<void> syncMenuItemPriceLists();
  Future<void> syncMenuItemTaxes();
  Future<void> syncPriceListTranslations();
  Future<void> syncAllMenuItemData();
}
