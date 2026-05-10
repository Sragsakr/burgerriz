// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_new, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../flutter_flow/flutter_flow_theme.dart';

class CustomNavigationButtonWithIcon extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final String title;
  final IconData icon;
  String? imageSVgPath;

  CustomNavigationButtonWithIcon({
    required this.onTap,
    this.onDoubleTap,
    required this.title,
    required this.icon,
    this.imageSVgPath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2.3,
        height: MediaQuery.of(context).size.height * (isLandscape ? 0.35 : 0.18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.125, // 25% of half the screen width
                height: MediaQuery.of(context).size.width * 0.125,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: imageSVgPath != null
                      ? SvgPicture.asset(
                          imageSVgPath!,
                          colorFilter: ColorFilter.mode(
                            colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        )
                      : Icon(
                          icon,
                          color: colorScheme.primary,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      color: colorScheme.primary,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
