import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_count_controller.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/variations_services/variants_translation_helper_service.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_translation_element_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_pricing_entity.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';

class ProductSelectionWidget extends ConsumerStatefulWidget {
  final SyncProduct product;

  const ProductSelectionWidget({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductSelectionWidget> createState() => _ProductSelectionWidgetState();
}

class _ProductSelectionWidgetState extends ConsumerState<ProductSelectionWidget> {
  SyncUnitOfMeasure? selectedUnit;
  List<SingleVariationWithPrice> variations = [];

  late ValueNotifier<double> _countNotifier;

  // Flattened lists derived from SyncProduct.variants for rendering
  late List<VariantTranslationElementEntity> _variationsTranslations;
  late List<VariationWithPrice> _variationsWithPrice;

  @override
  void initState() {
    super.initState();
    _countNotifier = ValueNotifier<double>(1);

    if (widget.product.unitOfMeasures.isNotEmpty) {
      selectedUnit = widget.product.unitOfMeasures.first;
    }

    // Build flat lists from SyncVariant data
    _variationsTranslations = widget.product.variants.expand((v) => v.translations).toList();

    _variationsWithPrice = widget.product.variants
        .expand((v) => v.values.expand((sv) => sv.translations.map(
              (t) => VariationWithPrice(
                variation: t,
                variationValue: sv.value,
                pricingList: sv.pricing,
              ),
            )))
        .toList();
  }

  @override
  void dispose() {
    _countNotifier.dispose();
    super.dispose();
  }

  void _updateSelections() {
    setState(() {});
  }

  Widget buildUnitsSection(BuildContext context) {
    if (widget.product.unitOfMeasures.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          translator(
            arText: 'الاحجام المتاحة',
            enText: 'Available Sizes',
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 1),
        const SizedBox(height: 8),
        ...widget.product.unitOfMeasures.map((unit) {
          bool isSelected = selectedUnit?.unitOfMeasureId == unit.unitOfMeasureId;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? const Color(0xFFAF2A26) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              title: Text(
                unit.nameEn,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFAF2A26) : null,
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
                _updateSelections();
              },
            ),
          );
        }),
      ],
    );
  }

  Widget buildVariationsSection(BuildContext context) {
    if (_variationsTranslations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          translator(
            arText: 'التخصيصات',
            enText: 'Customizations',
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 1),
        const SizedBox(height: 8),
        ...buildVariationsGroups(context),
      ],
    );
  }

  List<Widget> buildVariationsGroups(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final currentLangId = isEnglish ? 1 : 2;

    final displayTranslations =
        VariantsTranslationHelperService.getDisplayTranslations(_variationsTranslations, currentLangId);

    List<Widget> groups = [];
    for (var translation in displayTranslations) {
      final otherTranslation =
          VariantsTranslationHelperService.findOtherLanguageTranslation(_variationsTranslations, translation);
      groups.add(buildVariationsList(context, translation, otherTranslation));
    }

    return groups;
  }

  Widget buildVariationsList(BuildContext context, VariantTranslationElementEntity translation,
      VariantTranslationElementEntity? otherTranslation) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    final variationsForThisTranslation =
        _variationsWithPrice.where((v) => v.variationValue.variantId == translation.variantId).toList();

    if (variationsForThisTranslation.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<int, VariationWithPrice> uniqueVariations = {};
    for (var variation in variationsForThisTranslation) {
      final variantValueId = variation.variation.variantValueId;
      if (!uniqueVariations.containsKey(variantValueId)) {
        uniqueVariations[variantValueId] = variation;
      } else {
        final currentLangId = isEnglish ? 1 : 2;
        if (variation.variation.languageId == currentLangId) {
          uniqueVariations[variantValueId] = variation;
        }
      }
    }

    final screenVariationsWithPrice = uniqueVariations.values.toList();

    if (screenVariationsWithPrice.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            translation.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 1),
        const SizedBox(height: 8),
        ...screenVariationsWithPrice.map((variation) {
          bool isSelected = variations.any((element) =>
              element.variationAr?.id == variation.variation.id || element.variationEn?.id == variation.variation.id);

          String variationName = variation.variation.name;

          VariationValueTranslationPricingEntity? pricing;
          if (variation.pricingList.isNotEmpty) {
            pricing = variation.pricingList.first;
          }

          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
                        final arabicVariations = _variationsWithPrice
                            .where((element) =>
                                element.variation.variantValueId == variation.variation.variantValueId &&
                                element.variation.languageId == 2)
                            .toList();
                        final englishVariations = _variationsWithPrice
                            .where((element) =>
                                element.variation.variantValueId == variation.variation.variantValueId &&
                                element.variation.languageId == 1)
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
                    } else {
                      variations.removeWhere((element) =>
                          element.variationAr?.id == variation.variation.id ||
                          element.variationEn?.id == variation.variation.id);
                    }
                  });
                  _updateSelections();
                },
              ),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    variations.removeWhere((element) =>
                        element.variationAr?.id == variation.variation.id ||
                        element.variationEn?.id == variation.variation.id);
                  } else {
                    final arabicVariations = _variationsWithPrice
                        .where((element) =>
                            element.variation.id == variation.variation.id && element.variation.languageId == 2)
                        .toList();
                    final englishVariations = _variationsWithPrice
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
                _updateSelections();
              },
            ),
          );
        }),
      ],
    );
  }

  void _addToCart() {
    if (selectedUnit == null) return;

    double totalPrice = getTotalPrice();

    final cartItem = CartItem(
      imageUrl: widget.product.imageUrl,
      categoryId: widget.product.category?.id.toString() ?? '',
      productId: widget.product.productId,
      nameEn: widget.product.nameEn,
      nameAr: widget.product.nameAr,
      quantity: _countNotifier.value,
      price: totalPrice,
      unitId: selectedUnit!.unitOfMeasureId,
      itemCode: widget.product.itemCode ?? '',
      inclusive: widget.product.isExclusive,
      variations: variations,
    );

    ref.read(cartProvider.notifier).addItem(cartItem);

    context.pop();
    customSnackbar(
      context,
      translator(
        arText: '${FFLocalizations.of(context).getText('w3e4rsd1')} ${widget.product.nameAr}',
        enText: '${FFLocalizations.of(context).getText('w3e4rsd1')} ${widget.product.nameEn}',
      ),
      true,
    );
  }

  double getTotalPrice() {
    if (selectedUnit == null) return 0.0;

    double totalPrice = selectedUnit!.price;

    if (variations.isNotEmpty) {
      totalPrice += variations.fold(
        0.0,
        (previousValue, element) => previousValue + (element.price?.price ?? 0.0),
      );
    }

    totalPrice *= _countNotifier.value;

    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 0.0),
          child: buildUnitsSection(context),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 0.0),
          child: buildVariationsSection(context),
        ),
        SizedBox(height: context.height * 0.08),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            elevation: 8.0,
            child: Container(
              width: double.infinity,
              height: 100.94,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                border: Border.all(
                  color: const Color(0xCCBCBCBC),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 150.0,
                          height: 55.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: const Color(0xCCDFDFDF),
                            ),
                          ),
                          child: FlutterFlowCountController(
                            minimum: 1,
                            decrementIconBuilder: (enabled) => Icon(
                              Icons.remove_rounded,
                              color: enabled
                                  ? FlutterFlowTheme.of(context).secondaryText
                                  : FlutterFlowTheme.of(context).alternate,
                              size: 30.0,
                            ),
                            incrementIconBuilder: (enabled) => Icon(
                              Icons.add_rounded,
                              color: enabled ? const Color(0xFF502314) : FlutterFlowTheme.of(context).alternate,
                              size: 30.0,
                            ),
                            countBuilder: (count) => Text(
                              count.toString(),
                              style: FlutterFlowTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                    ),
                                    fontSize: 30.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                  ),
                            ),
                            count: _countNotifier.value,
                            updateCount: (count) {
                              _countNotifier.value = count;
                              setState(() {});
                            },
                            stepSize: 1,
                            contentPadding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(50.0, 0.0, 0.0, 0.0),
                        child: ValueListenableBuilder<double>(
                          valueListenable: _countNotifier,
                          builder: (context, count, child) {
                            return ElevatedButton(
                              onPressed: () {
                                if (selectedUnit != null) {
                                  _addToCart();
                                } else {
                                  customSnackbar(
                                    context,
                                    translator(
                                      arText: 'الرجاء اختيار حجم',
                                      enText: 'Please select a size',
                                    ),
                                    false,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF877350),
                                foregroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                                elevation: 3.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                minimumSize: const Size(0, 55),
                              ),
                              child: Text(
                                '${translator(arText: 'أضف إلى السلة', enText: 'Add To Cart')} ( ${getTotalPrice().toStringAsFixed(2)} SR ) ',
                                style: const TextStyle(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
