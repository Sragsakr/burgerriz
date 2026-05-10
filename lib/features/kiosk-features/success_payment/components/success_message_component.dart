import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_animations.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

class SuccessMessageComponent extends StatefulWidget {
  final String orderNumber;

  const SuccessMessageComponent({
    super.key,
    required this.orderNumber,
  });

  @override
  State<SuccessMessageComponent> createState() => _SuccessMessageComponentState();
}

class _SuccessMessageComponentState extends State<SuccessMessageComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Checkmark Circle
        Container(
          width: 120.0,
          height: 120.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4ECDC4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                blurRadius: 20.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 60.0,
          ),
        ).animateOnPageLoad(
          AnimationInfo(
            trigger: AnimationTrigger.onPageLoad,
            effects: [
              VisibilityEffect(duration: 50.ms),
              FadeEffect(
                curve: Curves.easeInOut,
                delay: 50.0.ms,
                duration: 400.0.ms,
                begin: 0.0,
                end: 1.0,
              ),
              ScaleEffect(
                curve: Curves.elasticOut,
                delay: 50.0.ms,
                duration: 600.0.ms,
                begin: const Offset(0.3, 0.3),
                end: const Offset(1.0, 1.0),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24.0),

        // Congrats! Text
        Text(
          translator(
            arText: 'تهانينا!',
            enText: 'Congrats!',
          ),
          style: FlutterFlowTheme.of(context).displaySmall.override(
                font: GoogleFonts.interTight(
                  fontWeight: FontWeight.bold,
                ),
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 36.0),
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
        ).animateOnPageLoad(
          AnimationInfo(
            trigger: AnimationTrigger.onPageLoad,
            effects: [
              VisibilityEffect(duration: 200.ms),
              FadeEffect(
                curve: Curves.easeInOut,
                delay: 200.0.ms,
                duration: 300.0.ms,
                begin: 0.0,
                end: 1.0,
              ),
              MoveEffect(
                curve: Curves.easeInOut,
                delay: 200.0.ms,
                duration: 300.0.ms,
                begin: const Offset(0.0, 20.0),
                end: const Offset(0.0, 0.0),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4.0),

        // Order complete Text
        Text(
          translator(
            arText: 'تم الطلب',
            enText: 'Order complete',
          ),
          style: TextStyle(
            color: AppColors.gray500,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20.0),
            fontWeight: FontWeight.w500,
          ),
        ).animateOnPageLoad(
          AnimationInfo(
            trigger: AnimationTrigger.onPageLoad,
            effects: [
              VisibilityEffect(duration: 300.ms),
              FadeEffect(
                curve: Curves.easeInOut,
                delay: 300.0.ms,
                duration: 300.0.ms,
                begin: 0.0,
                end: 1.0,
              ),
              MoveEffect(
                curve: Curves.easeInOut,
                delay: 300.0.ms,
                duration: 300.0.ms,
                begin: const Offset(0.0, 20.0),
                end: const Offset(0.0, 0.0),
              ),
            ],
          ),
        ),

        const SizedBox(height: 2.0),

        // Thank You Text
        Text(
          translator(
            arText: 'شكراً لك',
            enText: 'Thank You',
          ),
          style: TextStyle(
            color: AppColors.gray500,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20.0),
            fontWeight: FontWeight.w500,
          ),
        ).animateOnPageLoad(
          AnimationInfo(
            trigger: AnimationTrigger.onPageLoad,
            effects: [
              VisibilityEffect(duration: 350.ms),
              FadeEffect(
                curve: Curves.easeInOut,
                delay: 350.0.ms,
                duration: 300.0.ms,
                begin: 0.0,
                end: 1.0,
              ),
              MoveEffect(
                curve: Curves.easeInOut,
                delay: 350.0.ms,
                duration: 300.0.ms,
                begin: const Offset(0.0, 20.0),
                end: const Offset(0.0, 0.0),
              ),
            ],
          ),
        ),

        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: const Divider(
            thickness: 1.0,
            color: Color(0xFFDDDDDD),
          ),
        ).animateOnPageLoad(
          AnimationInfo(
            trigger: AnimationTrigger.onPageLoad,
            effects: [
              VisibilityEffect(duration: 400.ms),
              FadeEffect(
                curve: Curves.easeInOut,
                delay: 400.0.ms,
                duration: 300.0.ms,
                begin: 0.0,
                end: 1.0,
              ),
            ],
          ),
        ),

        // Please wait for your order number
        Align(
          alignment: AlignmentDirectional.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              translator(
                arText: 'يرجى انتظار رقم طلبك',
                enText: 'Please wait for your order number',
              ),
              style: TextStyle(
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18.0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ).animateOnPageLoad(
          AnimationInfo(
            trigger: AnimationTrigger.onPageLoad,
            effects: [
              VisibilityEffect(duration: 450.ms),
              FadeEffect(
                curve: Curves.easeInOut,
                delay: 450.0.ms,
                duration: 300.0.ms,
                begin: 0.0,
                end: 1.0,
              ),
              MoveEffect(
                curve: Curves.easeInOut,
                delay: 450.0.ms,
                duration: 300.0.ms,
                begin: const Offset(0.0, 20.0),
                end: const Offset(0.0, 0.0),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16.0),

        // Order Number
        Align(
          alignment: AlignmentDirectional.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              widget.orderNumber,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                    ),
                    color: const Color(0xFFC54238),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 36.0),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ).animateOnPageLoad(
          AnimationInfo(
            trigger: AnimationTrigger.onPageLoad,
            effects: [
              VisibilityEffect(duration: 500.ms),
              FadeEffect(
                curve: Curves.easeInOut,
                delay: 500.0.ms,
                duration: 300.0.ms,
                begin: 0.0,
                end: 1.0,
              ),
              ScaleEffect(
                curve: Curves.easeInOut,
                delay: 500.0.ms,
                duration: 300.0.ms,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
