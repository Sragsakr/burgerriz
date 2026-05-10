import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/variations_services/variants_translation_helper_service.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_translation_element_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_pricing_entity.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';

import '../../../../data/models/cart_item.dart';
import '../../../../providers/cart_provider.dart';

class ProductUnitDialog extends ConsumerStatefulWidget {
  final SyncProduct product;
  final bool isEnglish;
  final bool fromSearch;

  const ProductUnitDialog({
    super.key,
    required this.product,
    required this.isEnglish,
    this.fromSearch = false,
  });

  @override
  ConsumerState<ProductUnitDialog> createState() => _ProductUnitDialogState();
}

class _ProductUnitDialogState extends ConsumerState<ProductUnitDialog> {
  SyncUnitOfMeasure? selectedUnit;
  List<SingleVariationWithPrice> variations = [];
  late final List<VariationWithPrice> _variationsWithPrice;

  @override
  void initState() {
    super.initState();
    if (widget.product.unitOfMeasures.isNotEmpty) {
      selectedUnit = widget.product.unitOfMeasures.first;
    }
    _variationsWithPrice = widget.product.variants
        .expand((v) => v.values.expand((sv) => sv.translations.map((t) => VariationWithPrice(
              variation: t,
              variationValue: sv.value,
              pricingList: sv.pricing,
            ))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      elevation: 8, // Add some shadow
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title section
            buildTitle(),

            // Scrollable content with Slivers
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Units section
                  buildUnitsSliver(context),
                  buildUnitsListSliver(context),

                  // Variations section - create groups for each translation
                  if (widget.product.hasVariants) ...[
                    ...buildVariationsGroups(context),
                  ],
                ],
              ),
            ),

            // Action buttons
            buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Column(
      children: [
        Text(
          widget.isEnglish ? widget.product.nameEn : widget.product.nameAr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 20),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget buildUnitsSliver(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEnglish ? "Available Sizes" : "الاحجام المتاحة",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  Widget buildUnitsListSliver(BuildContext context) {
    final list = widget.product.unitOfMeasures.toSet().toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final unit = list[index];
          bool isSelected = selectedUnit?.unitOfMeasureId == unit.unitOfMeasureId;

          return Card(
            elevation: 0,
            shape: isSelected
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                      color: Color(0xFFAF2A26),
                      width: 2,
                    ),
                  )
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                widget.isEnglish ? unit.nameEn : unit.nameAr,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                '${unit.price} ${FFLocalizations.of(context).getText('dprmfxrn')}',
                style: const TextStyle(
                  color: Color(0xFFAF2A26),
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.add_shopping_cart),
              onTap: () {
                setState(() {
                  selectedUnit = unit;
                });
              },
            ),
          );
        },
        childCount: list.length,
      ),
    );
  }

  Widget buildVariationsSliver(BuildContext context, VariantTranslationElementEntity translation) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            translation.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  List<Widget> buildVariationsGroups(BuildContext context) {
    final translations = widget.product.variants.expand((v) => v.translations).toList();
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final currentLangId = isEnglish ? 1 : 2;

    // Get display translations using the service
    final displayTranslations = VariantsTranslationHelperService.getDisplayTranslations(translations, currentLangId);

    List<Widget> groups = [];

    for (var translation in displayTranslations) {
      // Find the corresponding translation in the other language using the service
      final otherTranslation = VariantsTranslationHelperService.findOtherLanguageTranslation(translations, translation);

      // // Create translation pair
      // final translationPair = TranslationHelperService.createTranslationPair(
      //     translation, otherTranslation);

      // Add translation name
      groups.add(buildVariationsSliver(context, translation));
      // Add values for this translation
      groups.add(buildVariationsListSliver(context, translation, otherTranslation));
    }

    return groups;
  }

  Widget buildVariationsListSliver(BuildContext context, VariantTranslationElementEntity translation,
      VariantTranslationElementEntity? otherTranslation) {
    final variationsWithPrice = _variationsWithPrice;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    // Filter variations by this specific translation
    final variationsForThisTranslation =
        variationsWithPrice.where((v) => v.variationValue.variantId == translation.variantId).toList();

    if (variationsForThisTranslation.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    // Show only one variation per unique variantValueId to avoid duplicates
    // Prefer the current language, but fallback to any available
    final Map<int, VariationWithPrice> uniqueVariations = {};
    for (var variation in variationsForThisTranslation) {
      final variantValueId = variation.variation.variantValueId;
      if (!uniqueVariations.containsKey(variantValueId)) {
        uniqueVariations[variantValueId] = variation;
      } else {
        // If we already have one, prefer the current language
        final currentLangId = isEnglish ? 1 : 2;
        if (variation.variation.languageId == currentLangId) {
          uniqueVariations[variantValueId] = variation;
        }
      }
    }

    final screenVariationsWithPrice = uniqueVariations.values.toList();

    if (screenVariationsWithPrice.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final variation = screenVariationsWithPrice[index];

          // Check if this variation is selected
          bool isSelected = variations.any((element) =>
              element.variationAr?.id == variation.variation.id || element.variationEn?.id == variation.variation.id);

          // Get language-specific name
          String variationName = variation.variation.name;

          // Get pricing for this variation
          VariationValueTranslationPricingEntity? pricing;
          if (variation.pricingList.isNotEmpty) {
            pricing = variation.pricingList.first;
          }

          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                variationName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              subtitle: pricing != null
                  ? Text(
                      '${pricing.price} ${FFLocalizations.of(context).getText('dprmfxrn')}',
                      style: const TextStyle(
                        color: Color(0xFFAF2A26),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
              trailing: Checkbox(
                value: isSelected,
                activeColor: const Color(0xFFAF2A26),
                checkColor: Colors.white,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      if (!isSelected) {
                        // Find both Arabic and English variations for this ID
                        final arabicVariations = variationsWithPrice
                            .where((element) =>
                                element.variation.variantValueId == variation.variation.variantValueId &&
                                element.variation.languageId == 2)
                            .toList();
                        final englishVariations = variationsWithPrice
                            .where((element) =>
                                element.variation.variantValueId == variation.variation.variantValueId &&
                                element.variation.languageId == 1)
                            .toList();
                        dPrint("arabicVariations: ${arabicVariations.map((e) => e.toMap()).toList().toString()}");
                        dPrint("englishVariations: ${englishVariations.map((e) => e.toMap()).toList().toString()}");
                        final arabicVariation = arabicVariations.isNotEmpty ? arabicVariations.first : null;
                        final englishVariation = englishVariations.isNotEmpty ? englishVariations.first : null;

                        variations.add(SingleVariationWithPrice(
                          mainTranslationAr: translation.languageId == 2 ? translation : otherTranslation,
                          mainTranslationEn: translation.languageId == 1 ? translation : otherTranslation,
                          variationValue: variation.variationValue,
                          variationAr: arabicVariation?.variation,
                          variationEn: englishVariation?.variation,
                          price: pricing,
                        ));
                      }
                    } else {
                      variations.removeWhere((element) =>
                          element.variationAr?.id == variation.variation.id ||
                          element.variationEn?.id == variation.variation.id);
                    }
                  });
                },
              ),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    variations.removeWhere((element) =>
                        element.variationAr?.id == variation.variation.id ||
                        element.variationEn?.id == variation.variation.id);
                  } else {
                    // Find both Arabic and English variations for this ID
                    final arabicVariations = variationsWithPrice
                        .where((element) =>
                            element.variation.id == variation.variation.id && element.variation.languageId == 2)
                        .toList();
                    final englishVariations = variationsWithPrice
                        .where((element) =>
                            element.variation.id == variation.variation.id && element.variation.languageId == 1)
                        .toList();

                    final arabicVariation = arabicVariations.isNotEmpty ? arabicVariations.first : null;
                    final englishVariation = englishVariations.isNotEmpty ? englishVariations.first : null;

                    variations.add(SingleVariationWithPrice(
                      mainTranslationAr: translation.languageId == 2 ? translation : otherTranslation,
                      mainTranslationEn: translation.languageId == 1 ? translation : otherTranslation,
                      variationValue: variation.variationValue,
                      variationAr: arabicVariation?.variation,
                      variationEn: englishVariation?.variation,
                      price: pricing,
                    ));
                  }
                });
              },
            ),
          );
        },
        childCount: screenVariationsWithPrice.length,
      ),
    );
  }

  Widget buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            if (selectedUnit != null) {
              _addToCart();
            } else {
              // Show error if no unit is selected
              customSnackbar(
                context,
                widget.isEnglish ? 'Please select a size' : 'الرجاء اختيار حجم',
                false,
              );
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            widget.isEnglish ? 'Add to Cart' : 'أضف إلى السلة',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFAF2A26),
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            widget.isEnglish ? 'Cancel' : 'إلغاء',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  void _addToCart() {
    if (selectedUnit == null) return;

    // Calculate total price (unit price + all selected variation prices)
    double totalPrice = selectedUnit!.price;

    // Add variation prices to total using fold like in the other app
    if (variations.isNotEmpty) {
      dPrint(variations.map((e) => e.toMap()).toList().toString());
      totalPrice += variations.fold(
        0,
        (previousValue, element) => previousValue + (element.price?.price ?? 0.0),
      );
    }

    CartItem cartItem = CartItem(
      imageUrl: widget.product.imageUrl,
      itemCode: widget.product.itemCode ?? '',
      categoryId: widget.product.category?.id.toString() ?? '',
      inclusive: widget.product.isExclusive,
      productId: widget.product.productId,
      nameEn: widget.product.nameEn,
      nameAr: widget.product.nameAr,
      allowDecimal: widget.product.allowDecimal,
      numberOfCalories: widget.product.numberOfCalories?.toString(),
      numberOfSteps: widget.product.numberOfSteps?.toString(),
      quantity: 1,
      price: totalPrice,
      unitId: selectedUnit!.unitOfMeasureId,
      variations: variations,
    );

    ref.read(cartProvider.notifier).addItem(cartItem);

    Navigator.of(context).pop();

    if (widget.fromSearch) {
      context.go('/sell-page');
    }

    customSnackbar(
      context,
      '${FFLocalizations.of(context).getText('w3e4rsd1')} ${widget.isEnglish ? widget.product.nameEn : widget.product.nameAr}',
      true,
    );
  }
}
