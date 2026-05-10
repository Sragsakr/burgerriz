import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/combo_meal/combo_meal_widget.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/customization/mobile_combo_meal_sheet.dart';

Future<void> showComboMealDialog({
  required BuildContext context,
  required SyncProduct product,
  required double basePrice,
  required int initialQuantity,
}) async {
  if (AppConfig.isMobile) {
    await MobileComboMealSheet.show(
      context,
      product: product,
      basePrice: basePrice,
      initialQuantity: initialQuantity,
    );
  } else {
    await showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ComboMealWidget(
        basePrice: basePrice,
        product: product,
        initialQuantity: initialQuantity,
      ),
    );
  }
}
