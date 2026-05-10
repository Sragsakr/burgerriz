# Menu Widget Components

This directory contains the refactored components for the MenuPage2desCopyWidget, making the UI more maintainable and scalable.

## Components Overview

### 1. MenuHeaderWidget (`menu_header_widget.dart`)
- **Purpose**: Displays the app bar with logo and back button
- **Features**: 
  - Customizable back button action
  - Brand logo display
  - Consistent styling with the original design

### 2. MenuSearchWidget (`menu_search_widget.dart`)
- **Purpose**: Handles product search functionality
- **Features**:
  - Search input field with icon
  - Customizable hint text
  - Search callback for filtering products

### 3. MenuCategorySidebarWidget (`menu_category_sidebar_widget.dart`)
- **Purpose**: Displays categories in a vertical sidebar (desktop only)
- **Features**:
  - Uses `categoriesProvider` for data
  - Featured category highlighting
  - Category selection with visual feedback
  - Responsive design (desktop only)

### 4. MenuMobileCategorySelector (`menu_mobile_category_selector.dart`)
- **Purpose**: Horizontal category selector for mobile/tablet devices
- **Features**:
  - Horizontal scrollable list
  - "All" category option
  - Chip-style design
  - Responsive design (mobile/tablet only)

### 5. MenuProductsGridWidget (`menu_products_grid_widget.dart`)
- **Purpose**: Displays products in a grid layout
- **Features**:
  - Uses `productsProvider` for data
  - Category-based filtering
  - Uses `MenuProductCardWidget` for individual product cards
  - Responsive grid layout

### 6. MenuProductCardWidget (`menu_product_card_widget.dart`)
- **Purpose**: Individual product card component
- **Features**:
  - Product image, name, price display
  - Add to cart button with `handleProductTap` integration
  - New badge for featured products
  - Calories and description display
  - Error handling for missing images

### 7. MenuCategoryCardWidget (`menu_category_card_widget.dart`)
- **Purpose**: Individual category card component
- **Features**:
  - Desktop card layout with images
  - Mobile chip layout for horizontal scrolling
  - Selection state management
  - Featured category highlighting
  - Error handling for missing images

### 8. MenuProductTapHandler (`menu_product_tap_handler.dart`)
- **Purpose**: Handles product tap interactions
- **Features**:
  - Integrates with existing `handleProductTap` from `product_grid_helper.dart`
  - Modal and direct tap options
  - Cart integration functionality

### 9. MenuMainLayoutWidget (`menu_main_layout_widget.dart`)
- **Purpose**: Main orchestrator component that combines all other widgets
- **Features**:
  - Responsive layout (desktop vs mobile)
  - State management for category selection
  - Search functionality integration
  - Proper widget lifecycle management

## Data Flow

The components use Riverpod providers for state management:

1. **categoriesProvider**: Provides list of categories
2. **productsProvider**: Provides products filtered by category ID
3. **allProductsProvider**: Provides all products

## Usage

### Basic Usage
```dart
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_main_layout_widget.dart';

class MyMenuPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuMainLayoutWidget(
      onBackPressed: () => Navigator.pop(context),
    );
  }
}
```

### Custom Back Action
```dart
MenuMainLayoutWidget(
  onBackPressed: () {
    // Custom navigation logic
    Navigator.pushReplacementNamed(context, '/home');
  },
)
```

## Responsive Design

- **Desktop**: Shows category sidebar on the left, products grid on the right
- **Mobile/Tablet**: Shows horizontal category selector above products grid
- **All devices**: Header and search bar remain consistent

## Key Benefits

1. **Modularity**: Each component has a single responsibility
2. **Reusability**: Components can be used independently
3. **Maintainability**: Easy to modify individual components
4. **Scalability**: Easy to add new features or modify existing ones
5. **State Management**: Uses Riverpod for efficient state management
6. **Responsive**: Works across different screen sizes

## Dependencies

- `flutter_riverpod`: State management
- `google_fonts`: Typography
- `flutter_flow_theme`: Theme management
- `flutter_flow_util`: Utility functions

## Future Enhancements

1. Add product filtering by price range
2. Implement advanced search with filters
3. Add product sorting options
4. Implement favorites/wishlist functionality
5. Add product comparison feature
6. Implement infinite scroll for large product lists
