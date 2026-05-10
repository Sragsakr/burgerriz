import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

void customSnackbar(BuildContext context, String message, bool success) {
  // Remove redundant "Exception: Exception:" if present
  message = message.replaceAll("Exception: Exception:", "").trim();
  dPrint("message is $message");
  // Clear any existing SnackBars first
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Row(
        children: [
          Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: success ? Colors.green : const Color(0xFFAF2A26),
    ),
  );
}
