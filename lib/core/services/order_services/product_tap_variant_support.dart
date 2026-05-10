/// Parses menu-item variant payloads from [MenuItemSyncRepository.fetchMenuItemVariants].
abstract final class ProductTapVariantSupport {
  ProductTapVariantSupport._();

  static bool hasConfigurableVariants(Map<String, dynamic> variants) {
    final raw = variants['variants'];
    return variants['status'] == 'Valid' && raw is List && raw.isNotEmpty;
  }

  static ({
    bool isVatExclusive,
    double taxRate,
    List<Map<String, dynamic>> variantList,
  }) parseForCustomization(Map<String, dynamic> variants) {
    final bool isVatExclusive = variants['isVatExclusive'] as bool? ?? false;
    final double taxRate = (variants['taxRate'] as num?)?.toDouble() ?? 0.0;
    final variantList =
        (variants['variants'] as List<dynamic>? ?? []).map((v) => v as Map<String, dynamic>).toList();
    return (isVatExclusive: isVatExclusive, taxRate: taxRate, variantList: variantList);
  }
}
