import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

class MenuCategoryCardWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final bool isFeatured;
  final VoidCallback? onTap;
  final bool isSelected;

  const MenuCategoryCardWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.isFeatured,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDesktopCard(context);
  }

  Widget _buildDesktopCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
      child: Material(
        color: Colors.transparent,
        elevation: isFeatured ? 6.0 : 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            height: ResponsiveHelper.getResponsiveSize(context, 50.0),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16.0,
              vertical: 0.0,
            ),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFAF2A26) : backgroundColor,
              borderRadius: BorderRadius.circular(20.0),
              shape: BoxShape.rectangle,
              border: isFeatured
                  ? Border.all(color: FlutterFlowTheme.of(context).warning)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: AutoSizeText(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    minFontSize: 12,
                    stepGranularity: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontStyle,
                          ),
                          color: isSelected
                              ? FlutterFlowTheme.of(context).secondaryBackground
                              : textColor,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, isFeatured ? 20.0 : 18.0),
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelLarge
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelLarge.fontStyle,
                        ),
                  ),
                ),
                if (isFeatured || isSelected) ...[
                  const SizedBox(width: 6.0),
                  Icon(
                    Icons.local_fire_department,
                    size: ResponsiveHelper.getResponsiveSize(context, 18.0),
                    color: FlutterFlowTheme.of(context).warning,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
