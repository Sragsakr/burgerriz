import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/theme/app_theme.dart';
import 'package:kiosk_point_of_sale/providers/ads_provider.dart';

class AdsScreen extends ConsumerStatefulWidget {
  const AdsScreen({super.key});

  @override
  ConsumerState<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends ConsumerState<AdsScreen> {
  @override
  void initState() {
    super.initState();
    // Start auto-play when widget initializes

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adsPageViewProvider.notifier).startAutoPlay(3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final adsState = ref.watch(adsPageViewProvider);
    final adsNotifier = ref.read(adsPageViewProvider.notifier);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppThemeModeData.getTextStyleForCurrentTheme(
              styleType: TextStyleType.bodyMedium,
              fontSize: 16.0,
            ).color ??
            AppThemeColors.lightScaffoldBackground,
        body: SafeArea(
          top: true,
          child: SizedBox(
            height: 100.h,
            child: PageView(
              controller: adsState.pageController,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              onPageChanged: (index) => adsNotifier.updatePageIndex(index),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: Image.asset(
                    AppAssets.adsImage1,
                    width: 90.w,
                    fit: BoxFit.cover,
                    height: 90.h,
                  ),
                ),
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(0.0),
                //   child: Image.asset(
                //     AppAssets.adsImage2,
                //     width: 90.w,
                //     height: 90.h,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(0.0),
                //   child: Image.asset(
                //     AppAssets.adsImage3,
                //     width: 90.w,
                //     height: 90.h,
                //     fit: BoxFit.cover,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
