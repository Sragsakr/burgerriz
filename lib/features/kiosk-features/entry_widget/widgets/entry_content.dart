import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/entry_widget/models/slide_data.dart';

/// Widget for displaying slide text content
class EntryContent extends StatelessWidget {
  final SlideData slideData;

  const EntryContent({
    super.key,
    required this.slideData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main title
          Text(
            slideData.title,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).displaySmall.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle: FlutterFlowTheme.of(context).displaySmall.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).info,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 40.0),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FlutterFlowTheme.of(context).displaySmall.fontStyle,
                ),
          ),

          // // Subtitle
          // Padding(
          //   padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
          //   child: Text(
          //     slideData.subtitle,
          //     style: FlutterFlowTheme.of(context).headlineMedium.override(
          //           font: GoogleFonts.interTight(
          //             fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
          //             fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
          //           ),
          //           color: FlutterFlowTheme.of(context).info,
          //           fontSize: ResponsiveHelper.getResponsiveFontSize(context, 40.0),
          //           letterSpacing: 0.0,
          //           fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
          //           fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
          //         ),
          //   ),
          // ),

          // // Description
          // Padding(
          //   padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
          //   child: Text(
          //     slideData.description,
          //     style: FlutterFlowTheme.of(context).bodyLarge.override(
          //           font: GoogleFonts.inter(
          //             fontWeight: FontWeight.w500,
          //             fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
          //           ),
          //           color: FlutterFlowTheme.of(context).info,
          //           fontSize: ResponsiveHelper.getResponsiveFontSize(context, 30.0),
          //           letterSpacing: 0.0,
          //           fontWeight: FontWeight.w500,
          //           fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
          //         ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
