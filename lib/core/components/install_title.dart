import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

class InstallTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final TextAlign? textAlign;

  const InstallTitle({
    super.key,
    required this.title,
    this.padding,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.fromSTEB(4, 5, 0, 0),
      child: Text(
        title,
        style: style ?? _getDefaultStyle(context),
        textAlign: textAlign,
      ),
    );
  }

  TextStyle _getDefaultStyle(BuildContext context) {
    return FlutterFlowTheme.of(context).labelMedium.override(
          fontFamily: 'Readex Pro',
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
          letterSpacing: 0.0,
          fontWeight: FontWeight.w500,
        );
  }
}

// Factory methods for common title types
class InstallTitleFactory {
  static InstallTitle deviceNumber() {
    return InstallTitle(
        title: translator(arText: 'رقم الجهاز', enText: 'Device Number'));
  }

  static InstallTitle tenant() {
    return InstallTitle(
        title: translator(arText: 'رقم العميل', enText: 'Tenant'));
  }

  static InstallTitle store() {
    return InstallTitle(
        title: translator(arText: 'رقم المتجر', enText: 'Store'));
  }

  static InstallTitle tenderType() {
    return InstallTitle(
        title: translator(arText: 'نوع التسوية', enText: 'Tender Type'));
  }

  static InstallTitle version() {
    return InstallTitle(
        title: translator(arText: 'الإصدار', enText: 'Version'));
  }

  static InstallTitle firstLanguage() {
    return InstallTitle(
        title: translator(arText: 'اللغة الأولى', enText: 'First Language'));
  }

  static InstallTitle secondLanguage() {
    return InstallTitle(
        title: translator(arText: 'اللغة الثانية', enText: 'Second Language'));
  }

  static InstallTitle natural() {
    return InstallTitle(title: translator(arText: 'البيئة', enText: 'Natural'));
  }

  static InstallTitle timeZone() {
    return InstallTitle(
        title: translator(arText: 'المنطقة الزمنية', enText: 'Time Zone'));
  }

  static InstallTitle loginMethod() {
    return InstallTitle(
        title: translator(arText: 'طريقة الدخول', enText: 'Login Method'));
  }

  static InstallTitle connectionString() {
    return InstallTitle(
        title:
            translator(arText: 'سلاسلة الإتصال', enText: 'Connection String'));
  }

  static InstallTitle syncInterval() {
    return InstallTitle(
        title: translator(arText: 'المدة  ', enText: 'Sync Interval'));
  }

  static InstallTitle ipAddress() {
    return InstallTitle(
        title: translator(arText: 'عنوان IP', enText: 'IP Address'));
  }

  // For localized titles
  static InstallTitle localized({
    required String arText,
    required String enText,
  }) {
    return InstallTitle(
      title: translator(arText: arText, enText: enText),
    );
  }
}
