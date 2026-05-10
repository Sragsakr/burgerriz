import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'responsive_helper.dart'; // Make sure this path is correct

class OrientationWrapper extends StatefulWidget {
  final Widget child;

  const OrientationWrapper({super.key, required this.child});

  @override
  State<OrientationWrapper> createState() => _OrientationWrapperState();
}

class _OrientationWrapperState extends State<OrientationWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setOrientation();
  }

  Future<void> _setOrientation() async {
    bool isMobile = ResponsiveHelper.isMobile(context);
    if (isMobile) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else if (ResponsiveHelper.isTablet(context)) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
