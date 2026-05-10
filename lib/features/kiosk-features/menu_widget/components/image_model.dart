import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_model.dart';

import 'image_widget.dart';

class ImageModel extends FlutterFlowModel<MenuSliderImageWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  // Auto-play timer
  Timer? _autoPlayTimer;
  bool _isUserInteracting = false;

  // Auto-play configuration
  final Duration autoPlayDuration = const Duration(seconds: 4);
  final int totalPages = 3;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  void startAutoPlay() {
    if (_isUserInteracting) return;

    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(autoPlayDuration, (timer) {
      if (pageViewController != null &&
          pageViewController!.hasClients &&
          !_isUserInteracting) {
        final currentPage = pageViewCurrentIndex;
        final nextPage = (currentPage + 1) % totalPages;

        pageViewController!.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void restartAutoPlay() {
    stopAutoPlay();
    _isUserInteracting = false;
    startAutoPlay();
  }

  void onUserInteraction() {
    _isUserInteracting = true;
    stopAutoPlay();

    // Resume auto-play after user stops interacting
    Timer(const Duration(seconds: 4), () {
      _isUserInteracting = false;
      startAutoPlay();
    });
  }

  @override
  void initState(BuildContext context) {
    // Start auto-play when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAutoPlay();
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
  }
}
