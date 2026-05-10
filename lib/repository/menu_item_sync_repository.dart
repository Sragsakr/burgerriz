import 'package:collection/collection.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/menu_item_fb_entity.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/menu_item_price_list_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/menu_item_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/price_list_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_definitions_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_fb_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_price_list_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_tax_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_translation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_variation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/price_list_translation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variant_table_element_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variant_translation_element_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variation_value_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variation_value_translation_pricing_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variation_value_translation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_table_element_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_translation_element_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_pricing_entity.dart';
import 'package:kiosk_point_of_sale/data/models/product_category/product_category_model.dart';
import 'package:kiosk_point_of_sale/data/models/product_category/product_category_translation_model.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/data/models/unit_of_measure/unit_of_measure_translation_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/product_category/product_category_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/product_category/product_category_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/unit_of_measure/unit_of_measure_translation_table.dart';

// ---------------------------------------------------------------------------
// Internal cache -- bulk-loaded once per public call
// ---------------------------------------------------------------------------

class _MenuDataCache {
  final List<MenuItemFBEntity> menuItems;
  final Map<int, List<MenuItemTranslationEntity>> translationsByMenuItemId;

  /// price list rows filtered to the requested priceListId
  final Map<int, List<MenuItemPriceListEntity>> pricesByMenuItemId;

  /// first taxId per menuItemId
  final Map<int, int> taxIdByMenuItemId;

  final Map<int, ProductCategoryModel> categoriesById;
  final Map<int, List<ProductCategoryTranslationModel>> categoryTranslationsByCategoryId;
  final Map<int, List<UnitOfMeasureTranslationModel>> uomTranslationsByUomId;
  final Map<int, List<PriceListTranslationEntity>> plTranslationsByPriceListId;
  final Map<int, List<int>> variantIdsByMenuItemId;
  final Map<int, VariantTableElementEntity> variantElementByVariantId;
  final Map<int, List<VariantTranslationElementEntity>> variantTranslationsByVariantId;
  final Map<int, List<VariationValueEntity>> variationValuesByVariantId;
  final Map<int, List<VariationValueTranslationEntity>> variationValueTranslationsByValueId;

  /// value pricing filtered to the requested priceListId
  final Map<int, List<VariationValueTranslationPricingEntity>> variationValuePricingByValueId;
  final Map<int, List<int>> comboPackageIdsByMenuItemId;

  _MenuDataCache({
    required this.menuItems,
    required this.translationsByMenuItemId,
    required this.pricesByMenuItemId,
    required this.taxIdByMenuItemId,
    required this.categoriesById,
    required this.categoryTranslationsByCategoryId,
    required this.uomTranslationsByUomId,
    required this.plTranslationsByPriceListId,
    required this.variantIdsByMenuItemId,
    required this.variantElementByVariantId,
    required this.variantTranslationsByVariantId,
    required this.variationValuesByVariantId,
    required this.variationValueTranslationsByValueId,
    required this.variationValuePricingByValueId,
    required this.comboPackageIdsByMenuItemId,
  });
}

// ---------------------------------------------------------------------------
// MenuItemSyncRepository
// ---------------------------------------------------------------------------

class MenuItemSyncRepository {
  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Returns all categories built from ProductCategoryTable + translations.
  /// Mirrors old: MenuItemsRepository.getAllCategories()
  Future<List<SyncCategory>> getAllCategories() async {
    try {
      final results = await Future.wait([
        ProductCategoryTable.getAll(),
        ProductCategoryTranslationTable.getAll(),
      ]);
      final categories = results[0] as List<ProductCategoryModel>;
      final translations = results[1] as List<ProductCategoryTranslationModel>;

      final Map<int, List<ProductCategoryTranslationModel>> byId = {};
      for (final t in translations) {
        byId.putIfAbsent(t.productCategoryId, () => []).add(t);
      }

      return categories.map((c) => _buildSyncCategory(c, byId[c.id] ?? [])).toList();
    } catch (e) {
      dPrint('MenuItemSyncRepository.getAllCategories error: $e');
      return [];
    }
  }

  /// Returns prime (root) categories: ParentId == 0, visible, not deleted.
  Future<List<SyncCategory>> getParentCategories() async {
    final all = await getAllCategories();
    return all.where((c) => c.parentId == 0 && c.isShowInPlugIn && !(c.id == 0)).toList()
      ..sort((a, b) => a.code.compareTo(b.code));
  }

  /// Returns child categories for [parentId]: visible, not deleted.
  Future<List<SyncCategory>> getChildCategories(int parentId) async {
    final all = await getAllCategories();
    return all.where((c) => c.parentId == parentId && c.isShowInPlugIn).toList()
      ..sort((a, b) => a.code.compareTo(b.code));
  }

  /// Returns products for all leaf-level descendants of a prime category.
  /// If the category is a leaf (isLastLevel), returns its products directly.
  /// If the category is a branch, collects products from all visible children.
  Future<List<SyncProduct>> getProductsForPrimeCategory(int primeCategoryId, int priceListId) async {
    final all = await getAllCategories();
    final prime = all.where((c) => c.id == primeCategoryId).firstOrNull;
    if (prime == null) return [];

    if (prime.isLastLevel) {
      return getProductsByCategory(primeCategoryId, priceListId);
    }

    final childIds = all.where((c) => c.parentId == primeCategoryId && c.isShowInPlugIn).map((c) => c.id).toList();

    final cache = await _loadAllData(priceListId);
    return cache.menuItems
        .where((item) => childIds.contains(item.productCategoryId))
        .map((item) => _mapMenuItemToSyncProduct(item, cache, priceListId))
        .toList();
  }

  /// Returns all products for the given priceListId.
  Future<List<SyncProduct>> getAllProducts(int priceListId) async {
    try {
      final cache = await _loadAllData(priceListId);
      return cache.menuItems.map((item) => _mapMenuItemToSyncProduct(item, cache, priceListId)).toList();
    } catch (e) {
      dPrint('MenuItemSyncRepository.getAllProducts error: $e');
      return [];
    }
  }

  /// Returns products belonging to the given category.
  /// Mirrors old: MenuItemsRepository.getProductsByCategory()
  Future<List<SyncProduct>> getProductsByCategory(int productCategoryId, int priceListId) async {
    try {
      final cache = await _loadAllData(priceListId);
      return cache.menuItems
          .where((item) => item.productCategoryId == productCategoryId)
          .map((item) => _mapMenuItemToSyncProduct(item, cache, priceListId))
          .toList();
    } catch (e) {
      dPrint('MenuItemSyncRepository.getProductsByCategory error: $e');
      return [];
    }
  }

  /// Returns products for the given category filtered to only the allowed menu item IDs.
  /// Used for per-store filtered menus where only items matching a reportGroupId are shown.
  Future<List<SyncProduct>> getProductsByCategoryFilteredByItems(
    int productCategoryId,
    int priceListId,
    Set<int> allowedMenuItemIds,
  ) async {
    try {
      final cache = await _loadAllData(priceListId);
      return cache.menuItems
          .where((item) => item.productCategoryId == productCategoryId && allowedMenuItemIds.contains(item.id))
          .map((item) => _mapMenuItemToSyncProduct(item, cache, priceListId))
          .toList();
    } catch (e) {
      dPrint('MenuItemSyncRepository.getProductsByCategoryFilteredByItems error: $e');
      return [];
    }
  }

  /// Returns a single product by its menu item entity id.
  Future<SyncProduct?> getProductById(int menuItemId, int priceListId) async {
    try {
      final entity = await MenuItemFBTable.getByEntityId(menuItemId);
      if (entity == null) return null;
      final cache = await _loadAllData(priceListId);
      return _mapMenuItemToSyncProduct(entity, cache, priceListId);
    } catch (e) {
      dPrint('MenuItemSyncRepository.getProductById error: $e');
      return null;
    }
  }

  /// Returns the first product matching any of itemCode / barcode1 / barcode2.
  /// Mirrors old: MenuItemsRepository.getProductByBarcode()
  Future<SyncProduct?> getProductByBarcode(String barcode, int priceListId) async {
    try {
      final items = await _getMenuItemsByIdentifier(barcode);
      if (items.isEmpty) return null;
      final cache = await _loadAllData(priceListId);
      return _mapMenuItemToSyncProduct(items.first, cache, priceListId);
    } catch (e) {
      dPrint('MenuItemSyncRepository.getProductByBarcode error: $e');
      return null;
    }
  }

  /// Returns ALL products matching any of itemCode / barcode1 / barcode2.
  /// Mirrors old: MenuItemsRepository.getAllProductsByAnyIdentifier()
  Future<List<SyncProduct>> getAllProductsByAnyIdentifier(String identifier, int priceListId) async {
    try {
      final items = await _getMenuItemsByIdentifier(identifier);
      if (items.isEmpty) return [];
      final cache = await _loadAllData(priceListId);
      return items.map((item) => _mapMenuItemToSyncProduct(item, cache, priceListId)).toList();
    } catch (e) {
      dPrint('MenuItemSyncRepository.getAllProductsByAnyIdentifier error: $e');
      return [];
    }
  }

  // -------------------------------------------------------------------------
  // Bulk data load
  // -------------------------------------------------------------------------

  Future<_MenuDataCache> _loadAllData(int priceListId) async {
    // Kick off all independent table reads in parallel.
    final menuItemsFuture = MenuItemFBTable.getAll();
    final translationsFuture = MenuItemTranslationTable.getAll();
    final pricesFuture = MenuItemPriceListTable.getAll();
    final taxesFuture = MenuItemTaxTable.getAll();
    final categoriesFuture = ProductCategoryTable.getAll();
    final catTranslationsFuture = ProductCategoryTranslationTable.getAll();
    final uomTranslationsFuture = UnitOfMeasureTranslationTable.getAll();
    final plTranslationsFuture = PriceListTranslationTable.getAll();
    final variationsFuture = MenuItemVariationTable.getAll();
    final variantElementsFuture = VariantTableElementTable.getAll();
    final variantTranslationsFuture = VariantTranslationElementTable.getAll();
    final variationValuesFuture = VariationValueTable.getAll();
    final vvTranslationsFuture = VariationValueTranslationTable.getAll();
    final vvPricingFuture = VariationValueTranslationPricingTable.getAll();
    final comboDefsFuture = ComboMealDefinitionsTable.getAll();

    final menuItems = await menuItemsFuture;
    final rawTranslations = await translationsFuture;
    final rawPrices = await pricesFuture;
    final rawTaxes = await taxesFuture;
    final rawCategories = await categoriesFuture;
    final rawCatTranslations = await catTranslationsFuture;
    final rawUomTranslations = await uomTranslationsFuture;
    final rawPlTranslations = await plTranslationsFuture;
    final rawVariations = await variationsFuture;
    final rawVariantElements = await variantElementsFuture;
    final rawVariantTranslations = await variantTranslationsFuture;
    final rawVariationValues = await variationValuesFuture;
    final rawVvTranslations = await vvTranslationsFuture;
    final rawVvPricing = await vvPricingFuture;
    final rawComboDefs = await comboDefsFuture;

    // -- translationsByMenuItemId --
    final Map<int, List<MenuItemTranslationEntity>> translationsByMenuItemId = {};
    for (final t in rawTranslations) {
      translationsByMenuItemId.putIfAbsent(t.menuItemId, () => []).add(t);
    }

    // -- pricesByMenuItemId (filter to requested priceListId) --
    final Map<int, List<MenuItemPriceListEntity>> pricesByMenuItemId = {};
    for (final p in rawPrices) {
      if (p.priceListId != priceListId) continue;
      pricesByMenuItemId.putIfAbsent(p.menuItemId, () => []).add(p);
    }

    // -- taxIdByMenuItemId (first entry per item) --
    final Map<int, int> taxIdByMenuItemId = {};
    for (final t in rawTaxes) {
      taxIdByMenuItemId.putIfAbsent(t.menuItemId, () => t.taxId);
    }

    // -- categoriesById --
    final Map<int, ProductCategoryModel> categoriesById = {
      for (final c in rawCategories) c.id: c,
    };

    // -- categoryTranslationsByCategoryId --
    final Map<int, List<ProductCategoryTranslationModel>> categoryTranslationsByCategoryId = {};
    for (final t in rawCatTranslations) {
      categoryTranslationsByCategoryId.putIfAbsent(t.productCategoryId, () => []).add(t);
    }

    // -- uomTranslationsByUomId --
    final Map<int, List<UnitOfMeasureTranslationModel>> uomTranslationsByUomId = {};
    for (final t in rawUomTranslations) {
      uomTranslationsByUomId.putIfAbsent(t.unitOfMeasureId, () => []).add(t);
    }

    // -- plTranslationsByPriceListId --
    final Map<int, List<PriceListTranslationEntity>> plTranslationsByPriceListId = {};
    for (final t in rawPlTranslations) {
      plTranslationsByPriceListId.putIfAbsent(t.priceListId, () => []).add(t);
    }

    // -- variantIdsByMenuItemId --
    final Map<int, List<int>> variantIdsByMenuItemId = {};
    for (final v in rawVariations) {
      variantIdsByMenuItemId.putIfAbsent(v.menuItemId, () => []).add(v.variantId);
    }

    // -- variantElementByVariantId (entity id = variant id in variation context) --
    final Map<int, VariantTableElementEntity> variantElementByVariantId = {
      for (final e in rawVariantElements) e.id: e,
    };

    // -- variantTranslationsByVariantId --
    final Map<int, List<VariantTranslationElementEntity>> variantTranslationsByVariantId = {};
    for (final t in rawVariantTranslations) {
      variantTranslationsByVariantId.putIfAbsent(t.variantId, () => []).add(t);
    }

    // -- variationValuesByVariantId --
    final Map<int, List<VariationValueEntity>> variationValuesByVariantId = {};
    for (final v in rawVariationValues) {
      variationValuesByVariantId.putIfAbsent(v.variantId, () => []).add(v);
    }

    // -- variationValueTranslationsByValueId --
    final Map<int, List<VariationValueTranslationEntity>> variationValueTranslationsByValueId = {};
    for (final t in rawVvTranslations) {
      variationValueTranslationsByValueId.putIfAbsent(t.variantValueId, () => []).add(t);
    }

    // -- variationValuePricingByValueId (filter to requested priceListId) --
    final Map<int, List<VariationValueTranslationPricingEntity>> variationValuePricingByValueId = {};
    for (final p in rawVvPricing) {
      if (p.priceListId != priceListId) continue;
      variationValuePricingByValueId.putIfAbsent(p.variantValueId, () => []).add(p);
    }

    // -- comboPackageIdsByMenuItemId --
    final Map<int, List<int>> comboPackageIdsByMenuItemId = {};
    for (final d in rawComboDefs) {
      if (d.isDeleted) continue;
      comboPackageIdsByMenuItemId.putIfAbsent(d.menuItemId, () => []).add(d.comboMealPackageId);
    }

    return _MenuDataCache(
      menuItems: menuItems,
      translationsByMenuItemId: translationsByMenuItemId,
      pricesByMenuItemId: pricesByMenuItemId,
      taxIdByMenuItemId: taxIdByMenuItemId,
      categoriesById: categoriesById,
      categoryTranslationsByCategoryId: categoryTranslationsByCategoryId,
      uomTranslationsByUomId: uomTranslationsByUomId,
      plTranslationsByPriceListId: plTranslationsByPriceListId,
      variantIdsByMenuItemId: variantIdsByMenuItemId,
      variantElementByVariantId: variantElementByVariantId,
      variantTranslationsByVariantId: variantTranslationsByVariantId,
      variationValuesByVariantId: variationValuesByVariantId,
      variationValueTranslationsByValueId: variationValueTranslationsByValueId,
      variationValuePricingByValueId: variationValuePricingByValueId,
      comboPackageIdsByMenuItemId: comboPackageIdsByMenuItemId,
    );
  }

  // -------------------------------------------------------------------------
  // Core mapping: MenuItemFBEntity -> SyncProduct
  // -------------------------------------------------------------------------

  SyncProduct _mapMenuItemToSyncProduct(
    MenuItemFBEntity item,
    _MenuDataCache cache,
    int priceListId,
  ) {
    // -- Names --
    final itemTranslations = cache.translationsByMenuItemId[item.id] ?? [];
    final nameEn = itemTranslations.firstWhereOrNull((t) => t.languageId == 1)?.name ?? '';
    final nameAr = itemTranslations.firstWhereOrNull((t) => t.languageId == 2)?.name ?? '';

    // -- Category --
    final categoryModel = cache.categoriesById[item.productCategoryId];
    final SyncCategory? syncCategory = categoryModel != null
        ? _buildSyncCategory(
            categoryModel,
            cache.categoryTranslationsByCategoryId[categoryModel.id] ?? [],
          )
        : null;

    // -- Tax --
    final taxId = cache.taxIdByMenuItemId[item.id];

    // -- Units of measure --
    final itemPrices = cache.pricesByMenuItemId[item.id] ?? [];
    final List<SyncUnitOfMeasure> units = [];
    final Set<int> addedUomIds = {};
    for (final price in itemPrices) {
      if (!addedUomIds.add(price.unitOfMeasureId)) continue;

      final uomTranslations = cache.uomTranslationsByUomId[price.unitOfMeasureId] ?? [];
      final uomNameEn = uomTranslations.firstWhereOrNull((t) => t.languageId == 1)?.name ?? '';
      final uomNameAr = uomTranslations.firstWhereOrNull((t) => t.languageId == 2)?.name ?? '';

      final plTranslations = cache.plTranslationsByPriceListId[price.priceListId] ?? [];
      final plNameEn = plTranslations.firstWhereOrNull((t) => t.languageId == 1)?.name;
      final plNameAr = plTranslations.firstWhereOrNull((t) => t.languageId == 2)?.name;

      units.add(SyncUnitOfMeasure(
        unitOfMeasureId: price.unitOfMeasureId,
        nameEn: uomNameEn,
        nameAr: uomNameAr,
        price: price.price,
        factor: price.factor,
        priceListId: price.priceListId,
        priceListNameEn: plNameEn,
        priceListNameAr: plNameAr,
      ));
    }

    // -- Variants --
    final variantIds = cache.variantIdsByMenuItemId[item.id] ?? [];
    final List<SyncVariant> variants = [];
    for (final variantId in variantIds) {
      final variantTranslations = cache.variantTranslationsByVariantId[variantId] ?? [];
      final variantConfig = cache.variantElementByVariantId[variantId];

      final variationValues = cache.variationValuesByVariantId[variantId] ?? [];
      final List<SyncVariationValue> syncValues = [];
      for (final vv in variationValues) {
        final vvTranslations = cache.variationValueTranslationsByValueId[vv.id] ?? [];
        final vvPricing = cache.variationValuePricingByValueId[vv.id] ?? [];
        if (vvPricing.isEmpty) continue;
        syncValues.add(SyncVariationValue(
          value: vv,
          translations: vvTranslations,
          pricing: vvPricing,
        ));
      }

      if (syncValues.isEmpty && variantTranslations.isEmpty) continue;
      variants.add(SyncVariant(
        variantId: variantId,
        variantConfig: variantConfig,
        translations: variantTranslations,
        values: syncValues,
      ));
    }

    // -- Combo meal info --
    final comboPackageIds = cache.comboPackageIdsByMenuItemId[item.id] ?? [];
    final comboMealInfo = SyncComboMealInfo(
      isComboMeal: comboPackageIds.isNotEmpty,
      comboMealPackageIds: comboPackageIds,
    );

    return SyncProduct(
      id: item.id,
      tenantId: item.tenantId,
      mainGroupId: item.mainGroupId,
      materialGroupId: item.materialGroupId,
      productCategoryId: item.productCategoryId,
      itemCode: item.itemCode,
      nameEn: nameEn,
      nameAr: nameAr,
      category: syncCategory,
      imageId: item.imageId ?? '',
      openPrice: item.openPrice,
      hasTobaccoTax: item.hasTobaccoTax,
      menuItemConfigId: item.menuItemConfigId,
      isComboMealDefinitionItem: item.isComboMealDefinitionItem,
      isShowInPlugIn: item.isShowInPlugIn,
      isHoteSaleing: item.isHoteSaleing,
      levelId: item.levelId,
      barcode1: item.barcode1,
      barcode2: item.barcode2,
      numberOfCalories: item.numberOfCalories,
      numberOfSteps: item.numberOfSteps,
      allowDecimal: item.allowDecimal,
      startUsageDate: item.startUsageDate,
      endUsageDate: item.endUsageDate,
      taxId: taxId,
      taxValue: 0.0,
      isExclusive: false,
      unitOfMeasures: units,
      variants: variants,
      comboMealInfo: comboMealInfo,
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  SyncCategory _buildSyncCategory(
    ProductCategoryModel category,
    List<ProductCategoryTranslationModel> translations,
  ) {
    final nameEn = translations.firstWhereOrNull((t) => t.languageId == 1)?.name ?? '';
    final nameAr = translations.firstWhereOrNull((t) => t.languageId == 2)?.name ?? '';
    return SyncCategory(
      id: category.id,
      code: category.code,
      nameEn: nameEn,
      nameAr: nameAr,
      imageId: category.imageId,
      parentId: category.parentId,
      secondaryCategoryId: category.secondaryCategoryId,
      isLastLevel: category.isLastLevel == 1,
      isShowInPlugIn: category.isShowInPlugIn == 1,
    );
  }

  /// Raw query against menu_item_fb for itemCode / barcode1 / barcode2 match.
  Future<List<MenuItemFBEntity>> _getMenuItemsByIdentifier(String identifier) async {
    final db = AppDB.db;
    final rows = await db.rawQuery(
      '''
      SELECT * FROM ${MenuItemFBTable.name}
      WHERE itemCode = ? OR barcode1 = ? OR barcode2 = ?
      ''',
      [identifier, identifier, identifier],
    );
    return rows.map((r) => MenuItemFBEntity.fromJson(r)).toList();
  }

  // ---------------------------------------------------------------------------
  // Variant fetch for ItemCustomizationDialog
  // ---------------------------------------------------------------------------

  /// Returns variant/modifier metadata for [menuItemId] filtered to [priceListId].
  ///
  /// Result map keys:
  /// - `status`        : `'Valid'` when variants exist, `'Empty'` otherwise
  /// - `variants`      : `List<Map<String, dynamic>>` — raw variant rows
  /// - `isVatExclusive`: `bool` — from the item's tax settings
  /// - `taxRate`       : `double`
  Future<Map<String, dynamic>> fetchMenuItemVariants(
    int menuItemId,
    int priceListId,
  ) async {
    try {
      final menuItemVariations = await MenuItemVariationTable.getByMenuItemId(menuItemId);

      if (menuItemVariations.isEmpty) {
        return {
          'status': 'Empty',
          'variants': <Map<String, dynamic>>[],
          'isVatExclusive': false,
          'taxRate': 0.0,
        };
      }

      final List<Map<String, dynamic>> variantRows = [];

      for (final variation in menuItemVariations) {
        final variantId = variation.variantId;
        final config = await VariantTableElementTable.getByEntityId(variantId);
        final translations = await VariantTranslationElementTable.getByVariantId(variantId);
        final values = await VariationValueTable.getByVariantId(variantId);

        final List<Map<String, dynamic>> valueRows = [];
        for (final value in values) {
          final valueTranslations = await VariationValueTranslationTable.getByVariantValueId(value.id);
          final pricing = await VariationValueTranslationPricingTable.getByVariantValueId(value.id, priceListId);

          if (pricing.isEmpty) continue;

          valueRows.add({
            'variantValueId': value.id,
            'variantId': variantId,
            'isDefault': value.isDefault,
            'translations': valueTranslations.map((t) => t.toJson()).toList(),
            'pricing': pricing.map((p) => p.toJson()).toList(),
          });
        }

        dPrint(
          '[fetchMenuItemVariants] variantId=$variantId '
          'pricingRule=${config?.pricingRule} '
          'freeCount=${config?.pricingRuleFreeItemsCount} '
          'isModifier=${config?.isModifier} '
          'isRequired=${config?.isRequired}',
        );

        variantRows.add({
          'variantId': variantId,
          'config': config?.toJson(),
          'translations': translations.map((t) => t.toJson()).toList(),
          'values': valueRows,
          'isModifier': config?.isModifier ?? false,
          'isAdd': config?.isAdd ?? false,
          'isRequired': config?.isRequired ?? false,
          'minSelections': config?.minSelections ?? 0,
          'maxSelections': config?.maxSelections ?? 0,
          'pricingRule': config?.pricingRule ?? 0,
          'pricingRuleFreeItemsCount': config?.pricingRuleFreeItemsCount ?? 0,
          'allowMultipleQuantitiesPerModifier': config?.allowMultipleQuantitiesPerModifier ?? false,
          'maxQtyPerModifier': config?.maxQtyPerModifier ?? 0,
          'periorty': config?.periorty ?? 0,
        });
      }

      return {
        'status': variantRows.isNotEmpty ? 'Valid' : 'Empty',
        'variants': variantRows,
        'isVatExclusive': false,
        'taxRate': 0.0,
      };
    } catch (e) {
      dPrint('fetchMenuItemVariants error: $e');
      return {
        'status': 'Empty',
        'variants': <Map<String, dynamic>>[],
        'isVatExclusive': false,
        'taxRate': 0.0,
      };
    }
  }

  /// Returns [MenuItemDetails] list for [menuItemId] in [priceListId].
  /// One entry per distinct UOM in the active price list.
  Future<List<MenuItemDetails>> getMenuItemDetails(
    int menuItemId,
    int priceListId,
  ) async {
    try {
      final allPriceRows = await MenuItemPriceListTable.getByMenuItemId(menuItemId);
      final priceRows = allPriceRows.where((r) => r.priceListId == priceListId).toList();

      if (priceRows.isEmpty) return [];

      final List<MenuItemDetails> results = [];
      final Set<int> seen = {};

      for (final row in priceRows) {
        if (seen.contains(row.unitOfMeasureId)) continue;
        seen.add(row.unitOfMeasureId);

        final uomTranslations = await UnitOfMeasureTranslationTable.getByUnitOfMeasureId(row.unitOfMeasureId);
        final nameEn = uomTranslations.firstWhereOrNull((t) => t.languageId == 1)?.name ?? '';
        final nameAr = uomTranslations.firstWhereOrNull((t) => t.languageId == 2)?.name ?? '';

        results.add(MenuItemDetails(
          menuItemId: menuItemId,
          unitOfMeasureId: row.unitOfMeasureId,
          unitNameEn: nameEn,
          unitNameAr: nameAr,
          price: row.price,
          taxValue: 0.0,
          isVAT: false,
        ));
      }

      return results;
    } catch (e) {
      dPrint('getMenuItemDetails error: $e');
      return [];
    }
  }
}
