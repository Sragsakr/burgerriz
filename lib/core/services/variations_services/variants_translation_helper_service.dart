import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_translation_element_entity.dart';

class VariantsTranslationHelperService {
  /// Finds the corresponding translation in the other language
  static VariantTranslationElementEntity? findOtherLanguageTranslation(
    List<VariantTranslationElementEntity> translations,
    VariantTranslationElementEntity? currentTranslation,
  ) {
    final otherLangId = currentTranslation?.languageId == 1 ? 2 : 1;
    return translations
        .where((t) => t.variantId == currentTranslation?.variantId && t.languageId == otherLangId)
        .firstOrNull;
  }

  /// Gets translations filtered by current language with fallback
  static List<VariantTranslationElementEntity> getDisplayTranslations(
    List<VariantTranslationElementEntity> translations,
    int currentLangId,
  ) {
    final currentTranslations = translations.where((t) => t.languageId == currentLangId).toList();
    final fallbackTranslations = translations.where((t) => t.languageId != currentLangId).toList();

    return currentTranslations.isNotEmpty ? currentTranslations : fallbackTranslations;
  }

  /// Creates a translation pair (Arabic and English) for a given translation
  static TranslationPair createTranslationPair(
    VariantTranslationElementEntity translation,
    VariantTranslationElementEntity? otherTranslation,
  ) {
    return TranslationPair(
      arabic: translation.languageId == 2 ? translation : otherTranslation,
      english: translation.languageId == 1 ? translation : otherTranslation,
    );
  }
}

/// Helper class to hold both Arabic and English translations
class TranslationPair {
  final VariantTranslationElementEntity? arabic;
  final VariantTranslationElementEntity? english;

  TranslationPair({this.arabic, this.english});
}
