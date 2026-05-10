import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;

import 'image_model.dart';

export 'image_model.dart';

class MenuSliderImageWidget extends StatefulWidget {
  const MenuSliderImageWidget({super.key});

  @override
  State<MenuSliderImageWidget> createState() => _MenuSliderImageWidgetState();
}

class _MenuSliderImageWidgetState extends State<MenuSliderImageWidget> {
  late ImageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImageModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, -1.0),
      child: SizedBox(
        width: double.infinity,
        height: 500.0,
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _model.onUserInteraction();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _model.pageViewController ??=
                      PageController(initialPage: 0),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _model.pageViewController!,
                      builder: (context, child) {
                        return _buildSlideImage(index);
                      },
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 16.0),
                child: smooth_page_indicator.SmoothPageIndicator(
                  controller: _model.pageViewController ??=
                      PageController(initialPage: 0),
                  count: 2,
                  axisDirection: Axis.horizontal,
                  onDotClicked: (i) async {
                    _model.onUserInteraction();
                    await _model.pageViewController!.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                    );
                    safeSetState(() {});
                  },
                  effect: smooth_page_indicator.ExpandingDotsEffect(
                    expansionFactor: 3.0,
                    spacing: 8.0,
                    radius: 16.0,
                    dotWidth: 16.0,
                    dotHeight: 8.0,
                    dotColor: FlutterFlowTheme.of(context).alternate,
                    activeDotColor: const Color(0xFFAF2A26),
                    paintStyle: PaintingStyle.fill,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideImage(int index) {
    final images = [
      AppAssets.menuSliderImage1,
      AppAssets.menuSliderImage2,
      // AppAssets.menuSliderImage3,
    ];

    final borderRadius = index == 0 ? 0.0 : 8.0;
    final width = index == 0 ? double.infinity : 300.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        images[index],
        width: width,
        height: double.infinity,
        fit: BoxFit.fill,
        alignment: const Alignment(0.0, 0.0),
        cacheWidth: 800, // Optimize for performance
        cacheHeight: 500,
        isAntiAlias: true,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
