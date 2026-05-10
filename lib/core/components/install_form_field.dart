import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

class InstallFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool autofocus;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final bool readOnly;
  const InstallFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.obscureText = false,
    this.autofocus = true,
    this.padding,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        obscureText: obscureText,
        enabled: enabled,
        readOnly: readOnly,
        decoration: _buildInputDecoration(context),
        style: _buildTextStyle(context),
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultBorderColor = colorScheme.outline.withValues(alpha: 0.35);
    final focusedColor = colorScheme.primary;
    final errorColor = colorScheme.error;
    return InputDecoration(
      labelText: labelText,
      labelStyle: _buildLabelStyle(context),
      hintText: hintText,
      hintStyle: _buildLabelStyle(context),
      enabledBorder: _buildEnabledBorder(defaultBorderColor),
      focusedBorder: _buildFocusedBorder(focusedColor),
      errorBorder: _buildErrorBorder(errorColor),
      focusedErrorBorder: _buildErrorBorder(errorColor),
    );
  }

  TextStyle _buildLabelStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FlutterFlowTheme.of(context).labelLarge.override(
          fontFamily: 'Plus Jakarta Sans',
          color: colorScheme.onSurfaceVariant,
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
          letterSpacing: 0.0,
          fontWeight: FontWeight.w500,
        );
  }

  TextStyle _buildTextStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FlutterFlowTheme.of(context).bodyLarge.override(
          fontFamily: 'Plus Jakarta Sans',
          color: colorScheme.onSurface,
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
          letterSpacing: 0.0,
          fontWeight: FontWeight.w500,
        );
  }

  OutlineInputBorder _buildEnabledBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 1.4,
      ),
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    );
  }

  OutlineInputBorder _buildFocusedBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    );
  }

  OutlineInputBorder _buildErrorBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    );
  }
}

// Factory methods for common form field types
class InstallFormFieldFactory {
  static InstallFormField deviceNumber({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
  }) {
    return InstallFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: '0',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
      ],
    );
  }

  static InstallFormField tenant({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
  }) {
    return InstallFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: translator(arText: 'العميل', enText: 'Tenant'),
      validator: validator,
    );
  }

  static InstallFormField store({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
  }) {
    return InstallFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: translator(arText: 'المتجر', enText: 'Store'),
      validator: validator,
    );
  }

  static InstallFormField tenderType({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
  }) {
    return InstallFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: '0',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
      ],
    );
  }

  static InstallFormField syncInterval({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
  }) {
    return InstallFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: translator(arText: 'المدة ', enText: 'Sync Interval'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
    );
  }

  static InstallFormField ipAddress({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return InstallFormField(
      readOnly: readOnly,
      controller: controller,
      focusNode: focusNode,
      hintText: translator(arText: 'عنوان IP', enText: 'IP Address'),
      keyboardType: TextInputType.url,
      validator: validator,
    );
  }

  static InstallFormField clusterId({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
  }) {
    return InstallFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: translator(arText: 'معرّف العنقود', enText: 'Cluster ID'),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      validator: validator,
    );
  }
}
