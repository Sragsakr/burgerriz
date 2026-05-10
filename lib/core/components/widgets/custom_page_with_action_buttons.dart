// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_new, deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_navigation_button_with_icon.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';

import '../../../../../providers/app_language_provider.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class ButtonSettings {
  final Function() onTap;
  final Function()? onDoubleTap;
  final String title;
  final IconData icon;
  String? imageSVgPath;

  ButtonSettings({
    required this.onTap,
    this.onDoubleTap,
    required this.title,
    required this.icon,
    this.imageSVgPath,
  });
}

class CustomPageWithActionButtons extends ConsumerWidget {
  final List<ButtonSettings> buttons;
  final List<Widget>? actions;
  final Function()? onPressedLeading;
  final String pageTitle;

  const CustomPageWithActionButtons({
    super.key,
    required this.buttons,
    this.actions,
    this.onPressedLeading,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageNotifierProvider);
    ref.watch(languageProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.adsImage1),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 3.0,
          sigmaY: 3.0,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.primary,
                size: ResponsiveHelper.getResponsiveSize(context, 30.0),
              ),
              onPressed: onPressedLeading ??
                  () {
                    context.go('/login');
                  },
            ),
            actions: actions,
            flexibleSpace: FlexibleSpaceBar(
              title: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
                child: Text(
                  FFLocalizations.of(context).getText(pageTitle),
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Outfit',
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
              centerTitle: true,
              expandedTitleScale: 1.0,
            ),
          ),
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Center(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: (buttons.length / 2).ceil(),
                      itemBuilder: (context, index) {
                        final startIndex = index * 2;
                        final endIndex = startIndex + 2;
                        final rowButtons = buttons.sublist(
                          startIndex,
                          endIndex > buttons.length ? buttons.length : endIndex,
                        );

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: rowButtons
                                .map(
                                  (button) => CustomNavigationButtonWithIcon(
                                    onTap: button.onTap,
                                    onDoubleTap: button.onDoubleTap,
                                    title: button.title,
                                    icon: button.icon,
                                    imageSVgPath: button.imageSVgPath,
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
