//app_language_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageState {
  final String language;
  final bool isEnglish;

  LanguageState({required this.language, required this.isEnglish});
}

final languageProvider = StateProvider<LanguageState>((ref) => LanguageState(language: 'en', isEnglish: true));

class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier() : super(LanguageState(language: 'en', isEnglish: true));

  void changeLanguage(String language) {
    state = LanguageState(language: language, isEnglish: language == 'en');
  }
}

final languageNotifierProvider = StateNotifierProvider<LanguageNotifier, LanguageState>((ref) => LanguageNotifier());
