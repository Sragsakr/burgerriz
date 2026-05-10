import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/providers/category_navigation_provider.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';
import 'package:kiosk_point_of_sale/core/sdks/sdk_logic/led_status_manager.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_category_and_sale_type_bar.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_header_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_prime_category_sidebar.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_products_grid_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_search_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_subcategory_bar.dart';

class MenuMainLayoutWidget extends ConsumerStatefulWidget {
  final VoidCallback? onBackPressed;

  const MenuMainLayoutWidget({
    super.key,
    this.onBackPressed,
  });

  @override
  ConsumerState<MenuMainLayoutWidget> createState() =>
      _MenuMainLayoutWidgetState();
}

class _MenuMainLayoutWidgetState extends ConsumerState<MenuMainLayoutWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  late final AnimationController _bodySlideController;
  late final Animation<Offset> _bodySlideAnimation;
  late final Animation<double> _bodyFadeAnimation;

  void _setRgb() async {
    final rgbLedEnabled = await AppPreferences().getBool('rgb_led_enabled');
    if (rgbLedEnabled) {
      dPrint(
          "MenuMainLayoutWidget: RGB LED is enabled, updating show status to true");
      try {
        LEDStatusManager.instance.updateShowStatus(true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoSizeText(
                "Failed to update show status: $e",
                maxLines: 2,
                minFontSize: 10,
              ),
            ),
          );
        }
        dPrint("MenuMainLayoutWidget: Failed to update show status: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _bodySlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bodySlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _bodySlideController, curve: Curves.easeOut),
    );
    _bodyFadeAnimation = CurvedAnimation(
      parent: _bodySlideController,
      curve: Curves.easeOut,
    );
    _setRgb();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bodySlideController.forward();
      ref.read(categoryNavigationProvider.notifier).loadParentCategories();
    });
  }

  @override
  void dispose() {
    _bodySlideController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(categoryNavigationProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: MenuHeaderWidget(
          onBackPressed: widget.onBackPressed,
        ),
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
            ),
            child: Row(
              children: [
                // Left sidebar — Prime categories
                const MenuPrimeCategorySidebar(),

                // Right content area
                Expanded(
                  child: SlideTransition(
                    position: _bodySlideAnimation,
                    child: FadeTransition(
                      opacity: _bodyFadeAnimation,
                      child: Column(
                        children: [
                          // 1. Search bar (top)
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  15.0, 15.0, 15.0, 15.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: MenuSearchWidget(
                                      controller: searchController,
                                      focusNode: searchFocusNode,
                                      onChanged: _onSearchChanged,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 2. Category title + Order type dropdown
                          const MenuCategoryAndSaleTypeBar(),

                          // 3. Subcategory chips
                          const MenuSubcategoryBar(),

                          // 4. Product grid
                          Expanded(
                            child: navState.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFAF2A26),
                                    ),
                                  )
                                : const MenuProductsGridWidget(),
                          ),
                        ],
                      ),
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
