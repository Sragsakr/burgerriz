import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';

import '../models/slide_data.dart';
import 'entry_buttons.dart';
import 'entry_content.dart';
import 'hero_vedio_player.dart';

/// Optimized widget for displaying individual entry slide
class EntrySlide extends StatelessWidget {
  final SlideData slideData;
  final VoidCallback? onButtonPressed;
  final bool show;

  const EntrySlide({
    super.key,
    required this.slideData,
    this.onButtonPressed,
    this.show = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Optimized background image with caching
          Positioned.fill(
            child: HeroVideoPlayer(
              videoUrl: slideData.imagePath,
            ),
          ),
          // Positioned.fill(
          //   child: Image.asset(slideData.imagePath),
          // ),

          // Optimized gradient overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x80000000), Colors.transparent],
                stops: [0.0, 0.5],
                begin: AlignmentDirectional(0.0, 1.0),
                end: AlignmentDirectional(0, -1.0),
              ),
            ),
          ),
          // Content overlay with conditional rendering
          Positioned.fill(
            child: Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 48.0, 24.0, 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (show) EntryContent(slideData: slideData),

                    // Action buttons
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EntryButtons(
                          onPressed: onButtonPressed,
                          isFirstSlide: slideData.isFirstSlide,
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
