import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import '../models/slide_data.dart';

/// Constants and data for the entry widget
class EntryConstants {
  static const String startOrderText = 'Start Order';
  static const String startOrderArabicText = 'بدء الطلب';

  static const List<SlideData> slides = [
    SlideData(
      imagePath: AppAssets.entryWidgetVideo1,
      title: ' Taste + Details + Quality = Burgerizer ❤️',
      subtitle: '',
      description: '',
      isFirstSlide: true,
    ),
    SlideData(
      imagePath: AppAssets.entryWidgetVideo2,
      title: 'what’s the name of this delicious burger? 😋',
      subtitle: '',
      description: '',
      isFirstSlide: true,
    ),
    SlideData(
      imagePath: AppAssets.entryWidgetVideo3,
      title: 'Boukheera Hassawi Lime is our new flavor 🍋',
      subtitle: '',
      description: '',
      isFirstSlide: true,
    ),
 
  ];
}
