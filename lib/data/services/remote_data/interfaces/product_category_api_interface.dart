import 'package:kiosk_point_of_sale/data/models/product_category/product_category_level_model.dart';
import 'package:kiosk_point_of_sale/data/models/product_category/product_category_model.dart';
import 'package:kiosk_point_of_sale/data/models/product_category/product_category_translation_model.dart';

abstract class ProductCategoryApiInterface {
  Future<List<ProductCategoryModel>> fetchProductCategories();
  Future<List<ProductCategoryTranslationModel>> fetchProductCategoryTranslations();
  Future<List<ProductCategoryLevelModel>> fetchProductCategoryLevels();
}
