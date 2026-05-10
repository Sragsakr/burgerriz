import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/routers/router.dart';
import 'package:kiosk_point_of_sale/providers/theme_provider.dart';

import 'core/config/app_config.dart';
import 'core/flutter_flow/internationalization.dart';
import 'core/services/sync_services/global_sync_service.dart';

class MyApp extends ConsumerStatefulWidget {
  String? firstPath;
  static late BuildContext appContext;
  MyApp({this.firstPath, super.key});

  @override
  MyAppState createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  GoRouter _router = createRouterKiosk();
  Locale? _locale;
  DateTime? _backgroundTime;

  @override
  void initState() {
    super.initState();
    setState(() {
      _router = createRouterKiosk(path: widget.firstPath);
    });
    WidgetsBinding.instance.addObserver(this); // Add observer

    _initializeLocale();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGlobalSync();
      _initializeTheme();
    });
  }

  Future<void> _initializeGlobalSync() async {
    try {
      dPrint("Attempting to initialize global sync service...");

      // Check if user is logged in before starting sync
      final token = await AppPreferences().getAccessToken();
      dPrint(
          "Token check result: ${token.isNotEmpty ? 'Logged in' : 'Not logged in'}");

      if (token.isNotEmpty) {
        final globalSyncService = ref.read(globalSyncServiceProvider);
        globalSyncService.initialize(ref);
        dPrint("Global sync service initialized in main app");

        // Initialize kiosk mode if user is logged in
        // await _initializeKioskMode();
      } else {
        dPrint("User not logged in, skipping global sync initialization");
      }
    } catch (e, t) {
      dPrint("Error initializing global sync: $e");
      dPrint("Stack trace: $t");
    }
  }

  /// Method to start sync after successful login
  Future<void> startSyncAfterLogin() async {
    try {
      dPrint("Starting sync after login...");
      final globalSyncService = ref.read(globalSyncServiceProvider);
      globalSyncService.initialize(ref);
      await ref.read(appThemeProvider.notifier).loadTheme();
      dPrint("Global sync service started after login");
    } catch (e, t) {
      dPrint("Error starting sync after login: $e");
      dPrint("Stack trace: $t");
    }
  }

  @override
  void dispose() {
    // Stop global sync service when app is disposed
    final globalSyncService = ref.read(globalSyncServiceProvider);
    globalSyncService.stop();
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  Future<void> _initializeLocale() async {
    try {
      // Get the stored locale after FFLocalizations has been initialized
      final storedLocale = await FFLocalizations.getStoredLocale();
      setState(() {
        _locale = storedLocale;
      });
      dPrint('Locale initialized: ${storedLocale?.languageCode}');

      // Ensure default language is saved to preferences on first launch
      await _ensureDefaultLanguageSaved();
    } catch (e) {
      dPrint('Error initializing locale: $e');
      // Set default locale if there's an error
      setState(() {
        _locale = const Locale('en'); // Default: English
      });
    }
  }

  Future<void> _initializeTheme() async {
    await ref.read(appThemeProvider.notifier).loadTheme();
  }

  Future<void> _ensureDefaultLanguageSaved() async {
    try {
      final currentStoredLanguage = await AppPreferences().getLanguage();
      dPrint('Current stored language: $currentStoredLanguage');

      // If no language is stored (first launch), save the default
      if (currentStoredLanguage.isEmpty) {
        await AppPreferences().setLanguage('en');
        dPrint('Default language (en) saved to preferences on first launch');
      }
    } catch (e) {
      dPrint('Error ensuring default language is saved: $e');
    }
  }

  Future<void> setLocale(String languageCode) async {
    await FFLocalizations.storeLocale(languageCode);
    setState(() => _locale = Locale(languageCode));
  }

  void _doSomethingAfter5Minutes() {
    dPrint('_backgroundTime is $_backgroundTime');
    _backgroundTime = null;
    _router.pushReplacement('/login');
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(appThemeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appTitle,
      locale: _locale,
      routerConfig: _router,
      onGenerateTitle: (context) {
        MyApp.appContext = context;
        return AppConfig.appTitle;
      },
      themeMode: ThemeMode.light,
      theme: appTheme,
      supportedLocales: AppConfig.supportedLocales,
      localizationsDelegates: AppConfig.localizationsDelegates,
      builder: (context, child) => ScaffoldMessenger(child: child!),
    );
  }
}
