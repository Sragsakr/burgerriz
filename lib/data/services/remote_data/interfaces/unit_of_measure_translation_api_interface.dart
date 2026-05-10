import 'package:kiosk_point_of_sale/data/models/unit_of_measure/unit_of_measure_translation_model.dart';

abstract class UnitOfMeasureTranslationApiInterface {
  Future<List<UnitOfMeasureTranslationModel>> fetchUnitOfMeasureTranslations();
}
