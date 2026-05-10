import 'package:kiosk_point_of_sale/data/models/secondary_category/secondary_category_model.dart';
import 'package:kiosk_point_of_sale/data/models/secondary_category/secondary_category_translation_model.dart';

abstract class SecondaryCategoryApiInterface {
  Future<List<SecondaryCategoryModel>> fetchSecondaryCategories();
  Future<List<SecondaryCategoryTranslationModel>> fetchSecondaryCategoryTranslations();
}
