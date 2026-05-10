import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/currency_display_helper.dart';

export 'package:kiosk_point_of_sale/core/helpers/currency_display_helper.dart'
    show CurrencyVisualVariant;

class CurrencyDisplayWidget extends StatelessWidget {
  final CurrencyVisualVariant variant;
  final double width;
  final double height;
  final BoxFit fit;
  final TextStyle? textStyle;

  const CurrencyDisplayWidget({
    super.key,
    this.variant = CurrencyVisualVariant.regular,
    required this.width,
    required this.height,
    this.fit = BoxFit.contain,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final languageId = languageCode == 'ar' ? 2 : 1;
    final cachedCurrencies = CurrencyDisplayHelper.cachedCurrencies;

    if (cachedCurrencies != null) {
      final config = CurrencyDisplayHelper.resolveFromCurrencies(
        currencies: cachedCurrencies,
        languageId: languageId,
        variant: variant,
      );
      return _buildFromConfig(context, config);
    }

    return FutureBuilder<CurrencyDisplayConfig>(
      future: CurrencyDisplayHelper.resolve(
        languageId: languageId,
        variant: variant,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(width: width, height: height);
        }

        return _buildFromConfig(context, snapshot.data!);
      },
    );
  }

  Widget _buildFromConfig(BuildContext context, CurrencyDisplayConfig config) {
    if (config.useImage && config.assetPath != null) {
      return Image.asset(
        config.assetPath!,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 2.0),
      child: Text(
        config.displayValue,
        maxLines: 1,
        overflow: TextOverflow.visible,
         style: textStyle ?? TextStyle(
      color: const Color(0xFFAF2A26),
      fontWeight: FontWeight.bold,
    ),
      ),
    );
  }
}
