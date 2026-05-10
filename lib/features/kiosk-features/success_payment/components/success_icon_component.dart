import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_animations.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

class SuccessIconComponent extends StatelessWidget {
  const SuccessIconComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
            0.0, ResponsiveHelper.getResponsiveSize(context, 94.0), 0.0, 0.0),
        child: Container(
          width: ResponsiveHelper.getResponsiveSize(context, 200.0),
          height: ResponsiveHelper.getResponsiveSize(context, 200.0),
          decoration: const BoxDecoration(
            color: Color(0xFFBBDCE5),
            shape: BoxShape.circle,
            border: Border(
              top: BorderSide(color: Color(0xFFBBDCE5), width: 4.0),
              bottom: BorderSide(color: Color(0xFFBBDCE5), width: 4.0),
              left: BorderSide(color: Color(0xFFBBDCE5), width: 4.0),
              right: BorderSide(color: Color(0xFFBBDCE5), width: 4.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsiveSize(context, 8.0)),
            child: Container(
              width: ResponsiveHelper.getResponsiveSize(context, 140.0),
              height: ResponsiveHelper.getResponsiveSize(context, 140.0),
              decoration: BoxDecoration(
                color: const Color(0xFF4FABCE),
                shape: BoxShape.circle,
                border: Border.all(
                  color: FlutterFlowTheme.of(context).accent2,
                  width: 4.0,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                color: FlutterFlowTheme.of(context).info,
                size: ResponsiveHelper.getResponsiveSize(context, 64.0),
              ),
            ),
          ),
        ).animateOnPageLoad(
          AnimationInfo(
            trigger: AnimationTrigger.onPageLoad,
            effects: [
              VisibilityEffect(duration: 1.ms),
              FadeEffect(
                curve: Curves.easeInOut,
                delay: 0.0.ms,
                duration: 300.0.ms,
                begin: 0.0,
                end: 1.0,
              ),
              ScaleEffect(
                curve: Curves.easeInOut,
                delay: 0.0.ms,
                duration: 300.0.ms,
                begin: Offset(0.8, 0.8),
                end: Offset(1.0, 1.0),
              ),
              TiltEffect(
                curve: Curves.easeInOut,
                delay: 0.0.ms,
                duration: 300.0.ms,
                begin: Offset(0, 1.396),
                end: Offset(0, 0),
              ),
              MoveEffect(
                curve: Curves.easeInOut,
                delay: 0.0.ms,
                duration: 300.0.ms,
                begin: Offset(0.0, 40.0),
                end: Offset(0.0, 0.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
