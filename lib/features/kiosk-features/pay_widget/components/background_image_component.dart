import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';

class BackgroundImageComponent extends StatelessWidget {
  final Widget child;

  const BackgroundImageComponent({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .98,
      decoration: const BoxDecoration(
        // image: DecorationImage(
        //   fit: BoxFit.contain,
        //   image: AssetImage(AppAssets.payBackgroundImage),
        // ),
      ),
      child: child,
    );
  }
}
