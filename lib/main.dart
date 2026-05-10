import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/helpers/find_first_path.dart';
import 'package:kiosk_point_of_sale/core/helpers/permission_helper.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/drago/drago_service.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/core/config/api_config.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/flutter_flow/flutter_flow_theme.dart';
import 'core/flutter_flow/internationalization.dart';
import 'my_app.dart';

GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
const bool _useMockThemeForTesting = false;

void main() async {
  await initializeApp();
  final firstPath = await checkValues();
  runApp(
    DevicePreview(
      enabled: false,
      tools: const [
        ...DevicePreview.defaultTools,
      ],
      builder: (context) => ProviderScope(
        child: MyApp(
          firstPath: firstPath,
        ),
      ),
    ),
  );
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  HttpOverrides.global = MyHttpOverrides();

  await requestAllAppPermissions();
  await AppDB.init();
  if (kDebugMode) {
    await AppDB.deleteAllSaleDb();
  }
  await AppPreferences().init();
  // if (_useMockThemeForTesting) {
  //   await _seedMockThemeSettings();
  // }
  final isMobileMode = await AppPreferences().getBool('isMobileMode', defaultValue: AppConfig.isKiosk);
  AppConfig.mode = isMobileMode ? AppMode.handheld : AppMode.kiosk;
  await ApiConfig.init();
  await Future.wait([
    FlutterFlowTheme.initialize(),
    FFLocalizations.initialize(),
  ]);
  await initFont();
}

Future<void> _seedMockThemeSettings() async {
  const mockThemeJson = '''
[
  {
    "id": 101,
    "pageName": "Global",
    "isActive": true,
    "deviceType": 8,
    "tenantId": 1,
    "clusterId": 1,
    "tenantDeviceId": 5,
    "terminalId": "TERM001",
    "backgoundColor": "#E3F2FD",
    "forgroundColor": "#1565C0",
    "fontColor": "#102027",
    "fontSize": 18,
    "fontSizeUnit": 1,
    "fontFamily": "Rubik",
    "backGroundType": 1,
    "slidingTimeInterval": 5000,
    "advertisementType": 0,
    "logoPath": "/uploads/logo.png",
    "orderSummaryView": true,
    "nearpayTerminalId": "NEP001",
    "translations": [
      { "languageId": 1, "name": "السمة العامة" },
      { "languageId": 2, "name": "Global Theme" }
    ],
    "themSettingImages": [],
    "advertisements": []
  },
  {
    "id": 102,
    "pageName": "Main Menu",
    "isActive": false,
    "deviceType": 8,
    "tenantId": 1,
    "clusterId": 1,
    "tenantDeviceId": 5,
    "terminalId": "TERM001",
    "backgoundColor": "#FFF3E0",
    "forgroundColor": "#E65100",
    "fontColor": "#3E2723",
    "fontSize": 14,
    "fontSizeUnit": 1,
    "fontFamily": "Rubik",
    "backGroundType": 1,
    "slidingTimeInterval": 5000,
    "advertisementType": 0,
    "logoPath": "/uploads/logo_menu.png",
    "orderSummaryView": true,
    "nearpayTerminalId": "NEP001",
    "translations": [
      { "languageId": 1, "name": "القائمة الرئيسية" },
      { "languageId": 2, "name": "Main Menu" }
    ],
    "themSettingImages": [],
    "advertisements": []
  }
]
''';
  await AppPreferences().setThemeSettingsCache(mockThemeJson);
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
