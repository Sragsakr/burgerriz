import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';

class CategoryNavigationState {
  final List<SyncCategory> parentCategories;
  final List<SyncCategory> currentChildCategories;
  final SyncCategory? selectedParentCategory;
  final SyncCategory? selectedChildCategory;
  final bool isShowingChildren;
  final bool isLoading;
  final String? error;

  const CategoryNavigationState({
    this.parentCategories = const [],
    this.currentChildCategories = const [],
    this.selectedParentCategory,
    this.selectedChildCategory,
    this.isShowingChildren = false,
    this.isLoading = false,
    this.error,
  });

  /// Resolves which category's products should be shown in the grid.
  SyncCategory? get activeCategoryForMenuItems {
    if (isShowingChildren && selectedChildCategory != null) {
      return selectedChildCategory;
    }
    // Show products for the parent if it's a leaf, or if no children are loaded
    // (fallback: a category with no children is treated as leaf).
    if (selectedParentCategory != null && !isShowingChildren) {
      return selectedParentCategory;
    }
    return null;
  }

  CategoryNavigationState copyWith({
    List<SyncCategory>? parentCategories,
    List<SyncCategory>? currentChildCategories,
    SyncCategory? selectedParentCategory,
    SyncCategory? selectedChildCategory,
    bool? isShowingChildren,
    bool? isLoading,
    String? error,
    bool clearSelectedChild = false,
    bool clearSelectedParent = false,
    bool clearError = false,
  }) {
    return CategoryNavigationState(
      parentCategories: parentCategories ?? this.parentCategories,
      currentChildCategories:
          currentChildCategories ?? this.currentChildCategories,
      selectedParentCategory: clearSelectedParent
          ? null
          : (selectedParentCategory ?? this.selectedParentCategory),
      selectedChildCategory: clearSelectedChild
          ? null
          : (selectedChildCategory ?? this.selectedChildCategory),
      isShowingChildren: isShowingChildren ?? this.isShowingChildren,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CategoryNavigationNotifier
    extends StateNotifier<CategoryNavigationState> {
  final Ref ref;

  CategoryNavigationNotifier(this.ref)
      : super(const CategoryNavigationState());

  Future<void> loadParentCategories() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final allCategories = ref.read(categoriesProvider);
      dPrint('[CategoryNav] Total categories: ${allCategories.length}');
      for (final c in allCategories) {
        dPrint('[CategoryNav] id=${c.id} parentId=${c.parentId} '
            'isLastLevel=${c.isLastLevel} isShowInPlugIn=${c.isShowInPlugIn} '
            'name=${c.nameEn}');
      }

      final parents = allCategories
          .where((c) => c.parentId == 0)
          .toList()
        ..sort((a, b) => a.code.compareTo(b.code));

      dPrint('[CategoryNav] Parent categories found: ${parents.length}');

      state = state.copyWith(
        parentCategories: parents,
        isLoading: false,
      );

      if (parents.isNotEmpty) {
        await selectParentCategory(parents.first);
      }
    } catch (e) {
      dPrint('loadParentCategories error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectParentCategory(SyncCategory category) async {
    state = state.copyWith(
      selectedParentCategory: category,
      clearSelectedChild: true,
      currentChildCategories: [],
      isShowingChildren: false,
      isLoading: true,
      clearError: true,
    );

    try {
      final allCategories = ref.read(categoriesProvider);
      final children = allCategories
          .where((c) => c.parentId == category.id)
          .toList()
        ..sort((a, b) => a.code.compareTo(b.code));

      // If the category is a leaf OR has no actual children, show products directly.
      // This handles both the isLastLevel flag and the fallback case.
      if (category.isLastLevel || children.isEmpty) {
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(
          currentChildCategories: children,
          isShowingChildren: true,
          isLoading: false,
        );
        selectChildCategory(children.first);
      }
    } catch (e) {
      dPrint('selectParentCategory error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectChildCategory(SyncCategory child) {
    state = state.copyWith(selectedChildCategory: child);
  }

  void goBackToParentCategories() {
    state = state.copyWith(
      isShowingChildren: false,
      clearSelectedChild: true,
      currentChildCategories: [],
    );
  }
}

final categoryNavigationProvider = StateNotifierProvider<
    CategoryNavigationNotifier, CategoryNavigationState>(
  (ref) => CategoryNavigationNotifier(ref),
);

final parentCategoriesProvider = Provider<List<SyncCategory>>((ref) {
  return ref.watch(categoryNavigationProvider).parentCategories;
});

final currentChildCategoriesProvider = Provider<List<SyncCategory>>((ref) {
  return ref.watch(categoryNavigationProvider).currentChildCategories;
});

final selectedParentCategoryProvider = Provider<SyncCategory?>((ref) {
  return ref.watch(categoryNavigationProvider).selectedParentCategory;
});

final selectedChildCategoryProvider = Provider<SyncCategory?>((ref) {
  return ref.watch(categoryNavigationProvider).selectedChildCategory;
});

final isShowingChildrenProvider = Provider<bool>((ref) {
  return ref.watch(categoryNavigationProvider).isShowingChildren;
});

final activeCategoryProvider = Provider<SyncCategory?>((ref) {
  return ref.watch(categoryNavigationProvider).activeCategoryForMenuItems;
});

/// Products for the currently active leaf category.
final activeCategoryProductsProvider = Provider<List<SyncProduct>>((ref) {
  final activeCategory = ref.watch(activeCategoryProvider);
  if (activeCategory == null) return [];

  final categoryId = activeCategory.id.toString();
  return ref.watch(productsProvider(categoryId));
});
