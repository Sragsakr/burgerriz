// Example usage of the refactored menu components
// This file demonstrates different ways to use the menu components

import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_category_sidebar_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_header_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_main_layout_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_products_grid_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_search_widget.dart';

// Example 1: Using the complete menu layout
class CompleteMenuExample extends ConsumerWidget {
  const CompleteMenuExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuMainLayoutWidget(
      onBackPressed: () {
        // Custom navigation logic
        Navigator.pushReplacementNamed(context, '/home');
      },
    );
  }
}

// Example 2: Using individual components
class IndividualComponentsExample extends ConsumerStatefulWidget {
  const IndividualComponentsExample({super.key});

  @override
  ConsumerState<IndividualComponentsExample> createState() =>
      _IndividualComponentsExampleState();
}

class _IndividualComponentsExampleState
    extends ConsumerState<IndividualComponentsExample> {
  String? selectedCategoryId;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuHeaderWidget(
        onBackPressed: () => Navigator.pop(context),
      ) as PreferredSizeWidget,
      body: Row(
        children: [
          // Left sidebar with categories
          SizedBox(
            width: 250,
            child: MenuCategorySidebarWidget(
              onCategorySelected: (categoryId) {
                setState(() {
                  selectedCategoryId = categoryId;
                });
              },
              selectedCategoryId: selectedCategoryId,
            ),
          ),
          // Right content area
          Expanded(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MenuSearchWidget(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    onChanged: (query) {
                      // Implement search logic
                      print('Searching for: $query');
                    },
                  ),
                ),
                // Products grid
                Expanded(
                  child: MenuProductsGridWidget(
                    selectedCategoryId: selectedCategoryId,
                    onProductSelected: (productId) {
                      // Handle product selection
                      print('Selected product: $productId');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example 3: Custom layout with specific requirements
class CustomMenuLayoutExample extends ConsumerWidget {
  const CustomMenuLayoutExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Menu Layout'),
        backgroundColor: const Color(0xFFDEC6A4),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F2E8), Colors.white],
          ),
        ),
        child: const MenuMainLayoutWidget(),
      ),
    );
  }
}

// Example 4: Integration with navigation
class MenuNavigationExample extends ConsumerWidget {
  const MenuNavigationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuMainLayoutWidget(
      onBackPressed: () {
        // Show confirmation dialog before navigating back
        showAppDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave Menu?'),
            content: const Text('Are you sure you want to leave the menu?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Navigate back
                },
                child: const Text('Leave'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Example 5: With custom search functionality
class CustomSearchMenuExample extends ConsumerStatefulWidget {
  const CustomSearchMenuExample({super.key});

  @override
  ConsumerState<CustomSearchMenuExample> createState() =>
      _CustomSearchMenuExampleState();
}

class _CustomSearchMenuExampleState
    extends ConsumerState<CustomSearchMenuExample> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return MenuMainLayoutWidget(
      onBackPressed: () => Navigator.pop(context),
    );
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });

    // Implement custom search logic here
    // You can filter products, update UI, etc.
    print('Custom search: $query');
  }
}
