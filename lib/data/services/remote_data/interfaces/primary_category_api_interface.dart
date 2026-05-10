import 'package:kiosk_point_of_sale/data/models/primary_category/primary_category_model.dart';
import 'package:kiosk_point_of_sale/data/models/primary_category/primary_category_translation_model.dart';

abstract class PrimaryCategoryApiInterface {
  Future<List<PrimaryCategoryModel>> fetchPrimaryCategories();
  Future<List<PrimaryCategoryTranslationModel>> fetchPrimaryCategoryTranslations();
}
