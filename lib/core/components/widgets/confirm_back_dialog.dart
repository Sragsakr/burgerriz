import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

class ConfirmBackDialog extends ConsumerWidget {
  String? arMsg;
  String? enMsg;
  VoidCallback? onAccept;
  Widget? footer;
  ConfirmBackDialog({
    super.key,
    this.arMsg,
    this.enMsg,
    this.onAccept,
    this.footer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final isLandscape = ResponsiveHelper.isTablet(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        width: isLandscape ? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEnglish
                  ? enMsg ?? 'You have products in your cart. Are you sure you can cancel the order?'
                  : arMsg ?? 'يوجد لديك منتجات في السلة. هل أنت متاكد من إلغاء الطلب؟',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            if (isLandscape)
              const SizedBox(
                height: 20,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                  color: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    isEnglish ? 'Cancel' : 'إلغاء',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                MaterialButton(
                  color: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onPressed: onAccept ?? () => context.go('/cashier-page'),
                  child: Text(
                    isEnglish ? 'confirm' : 'تاكيد',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (footer != null) footer!
              ],
            ),
          ],
        ),
      ),
    );
  }
}
