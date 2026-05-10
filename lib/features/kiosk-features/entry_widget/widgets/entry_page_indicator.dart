import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;

/// Widget for page indicator dots
class EntryPageIndicator extends StatelessWidget {
  final PageController pageController;
  final int pageCount;
  final Function(int) onDotClicked;

  const EntryPageIndicator({
    super.key,
    required this.pageController,
    required this.pageCount,
    required this.onDotClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.9),
      child: smooth_page_indicator.SmoothPageIndicator(
        controller: pageController,
        count: pageCount,
        axisDirection: Axis.horizontal,
        onDotClicked: onDotClicked,
        effect: smooth_page_indicator.SlideEffect(
          spacing: 8.0,
          radius: 8.0,
          dotWidth: 8.0,
          dotHeight: 8.0,
          dotColor: FlutterFlowTheme.of(context).primaryBackground,
          activeDotColor: Color(0xFFFFCD00),
          paintStyle: PaintingStyle.fill,
        ),
      ),
    );
  }
}
