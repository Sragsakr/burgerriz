// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/my_app.dart';
import 'package:kiosk_point_of_sale/providers/app_language_provider.dart';

Future<void> switchAppLanguage(WidgetRef ref, BuildContext context,
    {String? newLang}) async {
  try {
    final currentLanguage = ref.read(languageNotifierProvider).language;
    final newLanguage = newLang ?? (currentLanguage == 'en' ? 'ar' : 'en');

    dPrint('----------------------------------------------');
    dPrint('Current language: $currentLanguage');
    dPrint('New language: $newLanguage');

    // Don't switch if it's the same language
    if (currentLanguage == newLanguage) {
      dPrint('Language is already set to $newLanguage');
      return;
    }

    // Update preferences first (persistence) - this is the key for local storage
    await AppPreferences().setLanguage(newLanguage);
    dPrint('Language saved to preferences: $newLanguage');

    // Update provider state
    ref.read(languageNotifierProvider.notifier).changeLanguage(newLanguage);
    dPrint('Provider state updated: $newLanguage');

    // Update app locale (triggers rebuild)
    if (context.mounted) {
      MyApp.of(context).setLocale(newLanguage);
      dPrint('App locale updated: $newLanguage');
    }

    dPrint('Language switch completed successfully');

    // Debug: Verify the language was saved
    final savedLanguage = await AppPreferences().getLanguage();
    dPrint('Verification - Saved language: $savedLanguage');
  } catch (e) {
    dPrint('Error switching language: $e');
    // Show error to user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to switch language: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

String translator({required arText, required enText}) {
  final isEnglish =
      Localizations.localeOf(navKey.currentState!.context).languageCode == 'en';
  return isEnglish ? enText : arText;
}

bool isAr() {
  return Localizations.localeOf(navKey.currentState!.context).languageCode ==
      'ar';
}

// Debug utility to check language persistence
Future<void> debugLanguagePersistence() async {
  try {
    final storedLanguage = await AppPreferences().getLanguage();
    final currentLocale = Localizations.localeOf(navKey.currentState!.context);

    dPrint('=== Language Persistence Debug ===');
    dPrint('Stored in preferences: $storedLanguage');
    dPrint('Current app locale: ${currentLocale.languageCode}');
    dPrint('Current app locale full: $currentLocale');
    dPrint('================================');
  } catch (e) {
    dPrint('Error in debugLanguagePersistence: $e');
  }
}
