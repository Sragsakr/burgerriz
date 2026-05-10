import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';

import 'product_grid.dart';

class CustomTabBar extends ConsumerStatefulWidget {
  const CustomTabBar({super.key});

  @override
  ConsumerState<CustomTabBar> createState() => CustomTabBarState();
}

class CustomTabBarState extends ConsumerState<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return DefaultTabController(
      length: categories.length,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.4,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              labelColor: const Color(0xFFAF2A26),
              indicatorColor: const Color(0xFFAF2A26),
              tabs: categories.map((category) {
                return Tab(
                  child: Text(
                    isEnglish
                        ? category.nameEn
                        : category.nameAr,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: categories.map((category) {
                  final products =
                      ref.watch(productsProvider(category.id.toString()));

                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        FFLocalizations.of(context).getText('qwer0004'),
                        style: TextStyle(
                          fontSize:
                              ResponsiveHelper.isMobile(context) ? 20 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return ProductGrid(
                    products: products,
                    isEnglish: isEnglish,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TabBar(
//   isScrollable: true,
//   labelColor: Colors.blue,
//   unselectedLabelColor: Colors.grey,
//   indicatorColor: Colors.blue, // Simpler way to just change the indicator line color
//   indicatorWeight: 3, // Thickness of the indicator line
//   indicatorSize: TabBarIndicatorSize.tab, // or TabBarIndicatorSize.label
//   labelStyle: TextStyle(fontWeight: FontWeight.bold), // Style for selected tab
//   unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal), // Style for unselected tabs
//   // ... rest of your code
// )
