import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

import '../../../core/flutter_flow/flutter_flow_theme.dart';
import '../../../core/flutter_flow/flutter_flow_util.dart';
import '../../../core/flutter_flow/flutter_flow_widgets.dart';

class LoginButtonRow extends StatelessWidget {
  final bool isLoginButtonEnabled;
  final VoidCallback onLoginPressed;
  final VoidCallback onExitPressed;

  const LoginButtonRow({
    super.key,
    required this.isLoginButtonEnabled,
    required this.onLoginPressed,
    required this.onExitPressed,
  });

  Widget _buildButton({
    required BuildContext context,
    required String textKey,
    required VoidCallback? onPressed,
    required Color color,
    required TextStyle textStyle,
    required BorderSide borderSide,
    Color? hoverColor,
    BorderSide? hoverBorderSide,
    Color? hoverTextColor,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      child: FFButtonWidget(
        onPressed: onPressed,
        text: FFLocalizations.of(context).getText(textKey),
        showLoadingIndicator: false,
        options: FFButtonOptions(
          width: MediaQuery.of(context).size.width * 0.8,
          height: ResponsiveHelper.getResponsiveSize(context, 44.0),
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          color: color,
          textStyle: textStyle,
          elevation: 3.0,
          borderSide: borderSide,
          borderRadius: BorderRadius.circular(12.0),
          hoverColor: hoverColor ?? color,
          hoverBorderSide: hoverBorderSide,
          hoverTextColor: hoverTextColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          context: context,
          textKey: 'fyss8fwz', // LOGIN
          onPressed: isLoginButtonEnabled ? onLoginPressed : null,
          color: isLoginButtonEnabled
              ? colorScheme.primary
              : colorScheme.primary.withValues(alpha: 0.2),
          textStyle: FlutterFlowTheme.of(context).titleMedium,
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 1.0,
          ),
          hoverColor: colorScheme.primary.withValues(alpha: 0.85),
        ),
        _buildButton(
          context: context,
          textKey: '3z445p83', // EXIT
          onPressed: onExitPressed,
          color: colorScheme.surface,
          textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Readex Pro',
                color: colorScheme.primary,
              ),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.0,
          ),
          hoverColor: colorScheme.primary.withValues(alpha: 0.85),
          hoverBorderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.85),
            width: 1.0,
          ),
          hoverTextColor: colorScheme.onPrimary,
        ),
      ],
    );
  }
}
