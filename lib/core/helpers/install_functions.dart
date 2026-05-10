// ignore_for_file: prefer_const_constructors

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/enums/environment_enums.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/app_config_api_service.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_helper.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_model.dart';

import 'package:kiosk_point_of_sale/features/shared-features/Login/login_widget.dart';

import '../flutter_flow/flutter_flow_animations.dart';
import '../flutter_flow/flutter_flow_util.dart';

class InstallFunctions {
  // To save the values in shared preferences
  Future<void> saveInstallValues({
    required String tenant,
    required String deviceName,
    required String deviceNumber,
    required String store,
    required String tenderType,
    required String timeZone,
    required String environmentType,
    required String syncInterval,
    required String loginMethod,
    required String setSecLanguage,
    required String ip,
    required String version,
  }) async {
    await AppPreferences().setTenant(tenant);
    await AppPreferences().setVersion(version);
    await AppPreferences().setDeviceName(deviceName);
    await AppPreferences().setDeviceNumber(deviceNumber);
    await AppPreferences().setStore(store);
    await AppPreferences().setTenderType(tenderType);
    await AppPreferences().setTimeZone(timeZone);
    await AppPreferences().setNatural(environmentType);
    await AppPreferences().setEnvironmentType(environmentType);
    await AppPreferences().setSyncInterval(syncInterval);
    await AppPreferences().setLoginMethod(loginMethod);
    await AppPreferences().setSecLanguage(setSecLanguage);
    await AppPreferences().setIp(ip);
  }

  Future<void> handleSaveAndNavigate(BuildContext context, InstallModel model, WidgetRef ref) async {
    final String tenant = model.tenantTextController?.text ?? '';
    final String version = model.versionValue ?? '';
    final String deviceName = model.deviceNameTextController?.text ?? '';
    final String deviceNumber = model.deviceNumberTextController?.text ?? '';
    final String store = model.storeTextController?.text ?? '';
    final String tenderType = model.tenderTypeTextController1?.text ?? '';
    final String natural = model.naturalValue1 ?? '';
    final String timeZone = model.timeZoneValue2 ?? '';
    final String loginMethod = model.loginMethodValue3 ?? '';
    final String syncInterval = model.syncIntrenController?.text ?? '';
    final String secLanguage = model.languageSecValue ?? '';
    final String ip = model.ipTextController?.text ?? '';

    dPrint(
        "Values saved: Tenant: $tenant, DeviceName: $deviceName, deviceNumber: $deviceNumber, Store: $store, Tender Type: $tenderType, Natural: $natural, TimeZone: $timeZone, LoginMethod: $loginMethod, Sync Interval: $syncInterval");

    if (tenant.isEmpty ||
        (deviceName.isEmpty && AppConfig.isKiosk) ||
        store.isEmpty ||
        tenderType.isEmpty ||
        natural.isEmpty ||
        version.isEmpty ||
        timeZone.isEmpty ||
        deviceNumber.isEmpty ||
        loginMethod.isEmpty ||
        syncInterval.isEmpty) {
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: AwesomeSnackbarContent(
          title: FFLocalizations.of(context).getText('o1ps2y3h1' /* Error encountered */),
          message: FFLocalizations.of(context).getText('fillAllData' /* Error encountered */),
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return;
    }
    if (AppConfig.useNewInstallLoginFlow) {
      await AppPreferences().setInstallCompleted(false);
    }
    await AppPreferences().clear();
    await saveInstallValues(
      tenant: tenant,
      version: version,
      deviceName: deviceName,
      store: store,
      deviceNumber: deviceNumber,
      tenderType: tenderType,
      timeZone: timeZone,
      environmentType: natural,
      syncInterval: syncInterval,
      loginMethod: loginMethod,
      setSecLanguage: secLanguage,
      ip: ip,
    );
    // await saveValues(tenant, store, tenderType, natural, timeZone, loginMethod, syncInterval);

    dPrint(
        "Values saved: Tenant: $tenant,deviceNumber: $deviceNumber, Store: $store, Tender Type: $tenderType, Natural: $natural, TimeZone: $timeZone, LoginMethod: $loginMethod, Sync Interval: $syncInterval");
    try {
      final appConfigService = AppConfigApiService();
      await appConfigService.initialize();
      await appConfigService.getDeviceById();
      var deviceInfo = await DeviceConfigTable.getDeviceInfo();
      dPrint("""device info: ${deviceInfo?.toJson()}""");
      if (deviceInfo != null || natural == Environment.Testing.name.toString()) {
        if (AppConfig.useNewInstallLoginFlow) {
          await AppPreferences().setInstallCompleted(true);
        }
        if (!context.mounted) return;
        context.pushReplacementNamed(LoginWidget.routeName);
      }

      if (deviceInfo == null) {
        final snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: AwesomeSnackbarContent(
            title: FFLocalizations.of(context).getText('o1ps2y3h1' /* Error encountered */),
            message: FFLocalizations.of(context).getText('erroOcureWithgettingConfigorations' /* Error encountered */),
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: AwesomeSnackbarContent(
          title:
              translator(arText: "${e.toString()} لم يتم تحميل بيانات Zatca", enText: "Zatca Info Not ${e.toString()}"),
          message: FFLocalizations.of(context).getText('erroOcureWithgettingConfigorations' /* Error encountered */),
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // To load the values from shared preferences
  Future<void> loadValues(InstallModel model) async {
    final String tenant = await AppPreferences().getTenant();
    final String deviceName = await AppPreferences().getDeviceName();
    final String deviceNumber = await AppPreferences().getDeviceNumber();
    final String store = await AppPreferences().getStore();
    final String tenderType = await AppPreferences().getTenderType();
    final String natural = await AppPreferences().getNatural(); // Added
    final String timeZone = await AppPreferences().geTimeZone(); // Added
    final String loginMethod = await AppPreferences().getLoginMethod(); // Added
    final String syncInterval = await AppPreferences().getSyncInterval();
    final String language = await AppPreferences().getLanguage();
    final String seclanguage = await AppPreferences().getSecLanguage();
    final String ip = await AppPreferences().getIp();
    final String version = await AppPreferences().getVersion();

    // Assuming you have set up text controllers correctly
    model.tenantTextController?.text = tenant;
    model.deviceNameTextController?.text = deviceName;
    model.deviceNumberTextController?.text = deviceNumber;
    model.storeTextController?.text = store;
    model.tenderTypeTextController1?.text = tenderType;
    model.syncIntrenController?.text = syncInterval;
    model.ipTextController?.text = ip;
    model.versionValueController?.value = versionOptions.firstWhere((element) => element.value == version);

    try {
      // Applying the loaded values to the respective FormFieldControllers in the model
      model.naturalValueController1?.value = naturalOptions.firstWhere((element) => element.value == natural);
      model.timeZoneValueController2?.value = timeZoneOptions.firstWhere((element) => element.value == timeZone);
      model.loginMethodValueController3?.value =
          loginMethodOptions.firstWhere((element) => element.value == loginMethod);
      model.languageValueController?.value = languageOptions.firstWhere((element) => element.value == language);
      model.languageSecValueController?.value = languageOptions.firstWhere((element) => element.value == seclanguage);
      model.initalizing = true;
    } catch (e) {
      dPrint("Error loading values from shared preferences: $e");
    }
  }

  // Here we define the animations map
  final animationsMap = {
    'containerOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 200.ms),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 200.ms,
          duration: 600.ms,
          begin: 0.0,
          end: 1.0,
        ),
      ],
    ),
    'containerOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 250.ms),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 250.ms,
          duration: 600.ms,
          begin: Offset(0.0, 70.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
  };
}
