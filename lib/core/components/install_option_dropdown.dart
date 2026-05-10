import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_drop_down.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/form_field_controller.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_helper.dart';


class InstallOptionDropdown extends StatelessWidget {
  final FormFieldController<InstallOptionModel> controller;
  final List<InstallOptionModel> options;
  final String? hintText;
  final Function(InstallOptionModel?)? onChanged;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isSearchable;
  final bool isMultiSelect;
  final bool hidesUnderline;
  final Color? fillColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final double elevation;
  final TextStyle? textStyle;
  final Icon? icon;

  const InstallOptionDropdown({
    super.key,
    required this.controller,
    required this.options,
    this.hintText,
    this.onChanged,
    this.width,
    this.height = 50,
    this.padding,
    this.margin,
    this.isSearchable = false,
    this.isMultiSelect = false,
    this.hidesUnderline = true,
    this.fillColor,
    this.borderColor,
    this.borderWidth = 2,
    this.borderRadius = 8,
    this.elevation = 2,
    this.textStyle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
      child: FlutterFlowDropDown<InstallOptionModel>(
        controller: controller,
        optionLabels: _getOptionLabels(),
        options: options,
        onChanged: onChanged,
        width: width ?? double.infinity,
        height: height,
        textStyle: textStyle ?? _getDefaultTextStyle(context),
        hintText: hintText ?? _getDefaultHintText(context),
        icon: icon ?? _getDefaultIcon(context),
        fillColor: fillColor ?? _getDefaultFillColor(context),
        elevation: elevation,
        borderColor: borderColor ?? _getDefaultBorderColor(context),
        borderWidth: borderWidth,
        borderRadius: borderRadius,
        margin: margin ?? const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
        hidesUnderline: hidesUnderline,
        isSearchable: isSearchable,
        isMultiSelect: isMultiSelect,
      ),
    );
  }

  List<String> _getOptionLabels() {
    return options
        .map((e) => translator(
              arText: e.nameLoalized,
              enText: e.name,
            ))
        .toList();
  }

  TextStyle _getDefaultTextStyle(BuildContext context) {
    return FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'Readex Pro',
          letterSpacing: 0.0,
        );
  }

  String _getDefaultHintText(BuildContext context) {
    return 'Please select...';
  }

  Icon _getDefaultIcon(BuildContext context) {
    return Icon(
      Icons.keyboard_arrow_down_rounded,
      color: FlutterFlowTheme.of(context).secondaryText,
      size: 24,
    );
  }

  Color _getDefaultFillColor(BuildContext context) {
    return FlutterFlowTheme.of(context).secondaryBackground;
  }

  Color _getDefaultBorderColor(BuildContext context) {
    return FlutterFlowTheme.of(context).alternate;
  }
}

// Convenience factory methods for common use cases
class InstallOptionDropdownFactory {
  static InstallOptionDropdown language({
    required FormFieldController<InstallOptionModel> controller,
    required List<InstallOptionModel> options,
    Function(InstallOptionModel?)? onChanged,
    String? hintText,
  }) {
    return InstallOptionDropdown(
      controller: controller,
      options: options,
      onChanged: onChanged,
      hintText: hintText ?? translator(arText: 'اختر اللغة', enText: 'Select Language'),
    );
  }

  static InstallOptionDropdown version({
    required FormFieldController<InstallOptionModel> controller,
    required List<InstallOptionModel> options,
    Function(InstallOptionModel?)? onChanged,
    String? hintText,
  }) {
    return InstallOptionDropdown(
      controller: controller,
      options: options,
      onChanged: onChanged,
      hintText: hintText ?? translator(arText: 'اختر الإصدار', enText: 'Select Version'),
    );
  }

  static InstallOptionDropdown loginMethod({
    required FormFieldController<InstallOptionModel> controller,
    required List<InstallOptionModel> options,
    Function(InstallOptionModel?)? onChanged,
    String? hintText,
  }) {
    return InstallOptionDropdown(
      controller: controller,
      options: options,
      onChanged: onChanged,
      hintText: hintText ?? translator(arText: 'اختر طريقة الدخول', enText: 'Select Login Method'),
    );
  }

  static InstallOptionDropdown environment({
    required FormFieldController<InstallOptionModel> controller,
    required List<InstallOptionModel> options,
    Function(InstallOptionModel?)? onChanged,
    String? hintText,
  }) {
    return InstallOptionDropdown(
      controller: controller,
      options: options,
      onChanged: onChanged,
      hintText: hintText ?? translator(arText: 'اختر البيئة', enText: 'Select Environment'),
    );
  }

  static InstallOptionDropdown timeZone({
    required FormFieldController<InstallOptionModel> controller,
    required List<InstallOptionModel> options,
    Function(InstallOptionModel?)? onChanged,
    String? hintText,
  }) {
    return InstallOptionDropdown(
      controller: controller,
      options: options,
      onChanged: onChanged,
      hintText: hintText ?? translator(arText: 'اختر المنطقة الزمنية', enText: 'Select Time Zone'),
    );
  }
}
