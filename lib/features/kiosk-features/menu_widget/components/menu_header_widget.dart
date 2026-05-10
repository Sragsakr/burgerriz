import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_icon_button.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

class MenuHeaderWidget extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;

  const MenuHeaderWidget({
    super.key,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final header = context.widget as MenuHeaderWidget;
    final responsiveHeight = ResponsiveHelper.getResponsiveSize(context, 60.0);
    final sessionTheme = ref.watch(reportGroupThemeProvider);
    final backGround = sessionTheme.headerBackgroundAsset;

    return PreferredSize(
      preferredSize: Size.fromHeight(responsiveHeight),
      child: AppBar(
        flexibleSpace: ClipRRect(
          // borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            backGround,
            height: ResponsiveHelper.getResponsiveSize(context, 200.0),
            fit: BoxFit.cover,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: sessionTheme.accentColor),
        automaticallyImplyLeading: true,
        leading: FlutterFlowIconButton(
          borderRadius: 8.0,
          buttonSize: ResponsiveHelper.getResponsiveSize(context, 40.0),
          icon: Icon(
            Icons.chevron_left,
            color: AppColors.black,
            size: ResponsiveHelper.getResponsiveSize(context, 40.0),
          ),
          onPressed: header.onBackPressed ??
              () {
                Navigator.of(context).pop();
              },
        ),
        centerTitle: true,
        toolbarHeight: responsiveHeight,
        elevation: 3.0,
      ),
    );
  }
}
