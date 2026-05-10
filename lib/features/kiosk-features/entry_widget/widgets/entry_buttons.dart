import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

import '../constants/entry_constants.dart';

/// Reusable widget for entry action buttons
class EntryButtons extends ConsumerWidget {
  final VoidCallback? onPressed;
  final bool isFirstSlide;

  const EntryButtons({
    super.key,
    this.onPressed,
    this.isFirstSlide = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _startOrderButton(context),
          SizedBox(height: ResponsiveHelper.getResponsiveSize(context, 16.0)),
          _languageToggle(context, ref),
        ],
      ),
    );
  }

  Widget _startOrderButton(BuildContext context) {
    final size = ResponsiveHelper.getResponsiveSize(context, 150.0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFC42E2C),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                EntryConstants.startOrderText,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20.0),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSize(context, 4.0)),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveSize(context, 28.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageToggle(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        await switchAppLanguage(ref, context);
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: ResponsiveHelper.getResponsiveSize(context, 30),
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              translator(arText: 'English', enText: 'العربية'),
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18.0),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
