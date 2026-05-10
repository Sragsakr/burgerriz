import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/data/models/store/currency_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/currency/currency_table.dart';

enum CurrencyVisualVariant {
  regular,
  green,
  white,
}

class CurrencyDisplayConfig {
  final bool useImage;
  final String displayValue;
  final String? assetPath;

  const CurrencyDisplayConfig({
    required this.useImage,
    required this.displayValue,
    this.assetPath,
  });
}

class CurrencyDisplayHelper {
  CurrencyDisplayHelper._();

  static List<CurrencyModel>? _cachedCurrencies;
  static Future<List<CurrencyModel>>? _loadingCurrencies;

  static List<CurrencyModel>? get cachedCurrencies => _cachedCurrencies;

  static void clearCache() {
    _cachedCurrencies = null;
    _loadingCurrencies = null;
  }

  static Future<List<CurrencyModel>> getCurrencies() {
    if (_cachedCurrencies != null) {
      return Future.value(_cachedCurrencies!);
    }

    _loadingCurrencies ??= CurrencyTable.getAll().then((currencies) {
      _cachedCurrencies = currencies;
      _loadingCurrencies = null;
      return currencies;
    });

    return _loadingCurrencies!;
  }

  static Future<CurrencyDisplayConfig> resolve({
    required int languageId,
    CurrencyVisualVariant variant = CurrencyVisualVariant.regular,
  }) async {
    final currencies = await getCurrencies();
    return resolveFromCurrencies(
      currencies: currencies,
      languageId: languageId,
      variant: variant,
    );
  }

  static CurrencyDisplayConfig resolveFromCurrencies({
    required List<CurrencyModel> currencies,
    required int languageId,
    CurrencyVisualVariant variant = CurrencyVisualVariant.regular,
  }) {
    final activeCurrencies = currencies
        .where((currency) => currency.isDeleted != 1)
        .toList()
      ..sort((a, b) => a.currencyId.compareTo(b.currencyId));

    if (activeCurrencies.isEmpty) {
      return CurrencyDisplayConfig(
        useImage: false,
        displayValue: languageId == 2 ? "ريال سعودي" : 'SAR',
      );
    }

    final effectiveCurrencyId = activeCurrencies.first.currencyId;

    CurrencyModel? localizedCurrency;
    CurrencyModel? englishFallback;
    CurrencyModel? firstCurrencyEntry;

    for (final currency in activeCurrencies) {
      if (currency.currencyId != effectiveCurrencyId) continue;
      firstCurrencyEntry ??= currency;
      if (currency.languageId == languageId) {
        localizedCurrency = currency;
      }
      if (currency.languageId == 1) {
        englishFallback = currency;
      }
    }

    final selectedCurrency = localizedCurrency ??
        englishFallback ??
        firstCurrencyEntry ??
        activeCurrencies.first;
    final isSarCurrency = _isSarCurrency(activeCurrencies, effectiveCurrencyId);

    if (isSarCurrency) {
      return CurrencyDisplayConfig(
        useImage: true,
        displayValue: selectedCurrency.name,
        assetPath: _assetForVariant(variant),
      );
    }

    return CurrencyDisplayConfig(
      useImage: false,
      displayValue: selectedCurrency.name,
    );
  }

  static bool _isSarCurrency(List<CurrencyModel> currencies, int currencyId) {
    for (final currency in currencies) {
      if (currency.currencyId != currencyId) continue;
      if (currency.name.trim().toUpperCase() == 'SAR' ||currency.name.trim().toUpperCase() == 'ريال' ) {
        return true;
      }
    }
    return false;
  }

  static String _assetForVariant(CurrencyVisualVariant variant) {
    switch (variant) {
      case CurrencyVisualVariant.green:
        return AppAssets.saudiRiyalSymbolGreen;
      case CurrencyVisualVariant.white:
        return AppAssets.saudiRiyalSymbolWhite;
      case CurrencyVisualVariant.regular:
        return AppAssets.saudiRiyalSymbol;
    }
  }
}
