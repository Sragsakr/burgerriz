import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/combo_meal/combo_meal_model.dart';
import 'package:kiosk_point_of_sale/data/models/combo_meal/combo_meal_package_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/combo_meal/combo_meal_package_model.dart';
import 'package:kiosk_point_of_sale/repository/combo_meal_repository.dart';

/// State class for combo meal selection
class ComboMealState {
  final ComboMeal? comboMeal;
  final List<ComboMealPackageItem> selectedItems;
  final bool isLoading;
  final String? error;

  const ComboMealState({
    this.comboMeal,
    this.selectedItems = const [],
    this.isLoading = false,
    this.error,
  });

  /// Get the current package being selected (first incomplete package)
  ComboMealPackage? get currentPackage => comboMeal?.currentPackage;

  /// Get the total price of the combo meal
  double get totalPrice => comboMeal?.totalPrice ?? 0.0;

  /// Check if all packages are complete
  bool get isComplete => comboMeal?.isComplete ?? false;

  /// Get all selected items across all packages
  List<ComboMealPackageItem> get allSelectedItems =>
      comboMeal?.allSelectedItems ?? [];

  ComboMealState copyWith({
    ComboMeal? comboMeal,
    List<ComboMealPackageItem>? selectedItems,
    bool? isLoading,
    String? error,
  }) {
    return ComboMealState(
      comboMeal: comboMeal ?? this.comboMeal,
      selectedItems: selectedItems ?? this.selectedItems,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// StateNotifier for combo meal selection logic
class ComboMealNotifier extends StateNotifier<ComboMealState> {
  final ComboMealRepository _repository;
  final int _priceListId;
  final int _languageId;

  ComboMealNotifier({
    required ComboMealRepository repository,
    required int priceListId,
    int languageId = 1,
  })  : _repository = repository,
        _priceListId = priceListId,
        _languageId = languageId,
        super(const ComboMealState());

  /// Load combo meal details for a menu item
  Future<void> loadComboMeal(int menuItemId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final comboMeal = await _repository.getComboMealDetails(
        menuItemId,
        _priceListId,
        languageId: _languageId,
      );

      if (comboMeal == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Combo meal not found',
        );
        return;
      }

      state = state.copyWith(
        comboMeal: comboMeal,
        selectedItems: [],
        isLoading: false,
        error: null,
      );

      dPrint('Loaded combo meal: ${comboMeal.name} with ${comboMeal.packages.length} packages');
    } catch (e) {
      dPrint('Error loading combo meal: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load combo meal: $e',
      );
    }
  }

  /// Select an item from the current package
  bool selectItem(ComboMealPackageItem item) {
    if (state.currentPackage == null) {
      dPrint('No current package to select from');
      return false;
    }

    if (!item.canSelect) {
      dPrint('Item ${item.name} has reached max quantity');
      return false;
    }

    if (state.currentPackage!.remainingSelections <= 0) {
      dPrint('Package ${state.currentPackage!.name} has no remaining selections');
      return false;
    }

    // Find and update the item in the package
    final packageIndex = state.comboMeal!.packages
        .indexWhere((p) => p.id == state.currentPackage!.id);

    if (packageIndex == -1) return false;

    final itemIndex = state.comboMeal!.packages[packageIndex].items
        .indexWhere((i) => i.id == item.id);

    if (itemIndex == -1) return false;

    // Update item selected count
    state.comboMeal!.packages[packageIndex].items[itemIndex].selectedCount++;
    
    // Update remaining selections
    state.comboMeal!.packages[packageIndex].remainingSelections--;

    // Add to selected items list
    final newSelectedItems = [...state.selectedItems, item.copyWith(selectedCount: 1)];

    state = state.copyWith(
      comboMeal: state.comboMeal,
      selectedItems: newSelectedItems,
    );

    dPrint('Selected item: ${item.name}');
    dPrint('Remaining selections in package: ${state.currentPackage?.remainingSelections}');
    dPrint('Is complete: ${state.isComplete}');

    return true;
  }

  /// Remove an item from selections
  void removeItem(ComboMealPackageItem item) {
    if (state.comboMeal == null) return;

    // Find the package containing this item
    ComboMealPackage? package;
    int packageIndex = -1;

    for (int i = 0; i < state.comboMeal!.packages.length; i++) {
      final p = state.comboMeal!.packages[i];
      if (p.items.any((pItem) => pItem.id == item.id)) {
        package = p;
        packageIndex = i;
        break;
      }
    }

    if (package == null || packageIndex == -1) return;

    // Find the item in the package
    final itemIndex = package.items.indexWhere((i) => i.id == item.id);
    if (itemIndex == -1) return;

    // Get the item and check if it has selections
    final packageItem = package.items[itemIndex];
    if (packageItem.selectedCount <= 0) return;

    // Decrement the item's selected count
    state.comboMeal!.packages[packageIndex].items[itemIndex].selectedCount--;

    // Increment remaining selections for the package
    state.comboMeal!.packages[packageIndex].remainingSelections++;

    // Remove one instance from selected items list
    final newSelectedItems = [...state.selectedItems];
    final selectedItemIndex =
        newSelectedItems.indexWhere((i) => i.id == item.id);
    if (selectedItemIndex != -1) {
      newSelectedItems.removeAt(selectedItemIndex);
    }

    state = state.copyWith(
      comboMeal: state.comboMeal,
      selectedItems: newSelectedItems,
    );

    dPrint('Removed item: ${item.name}');
  }

  /// Reset all selections
  void reset() {
    if (state.comboMeal != null) {
      state.comboMeal!.resetAllSelections();
    }
    state = const ComboMealState();
    dPrint('Combo meal state reset');
  }

  /// Check if an item is currently selected
  bool isItemSelected(ComboMealPackageItem item) {
    return state.selectedItems.any((i) => i.id == item.id);
  }

  /// Get the selection count for a specific item
  int getItemSelectionCount(ComboMealPackageItem item) {
    return state.selectedItems.where((i) => i.id == item.id).length;
  }
}

/// Provider for combo meal state management
final comboMealProvider =
    StateNotifierProvider<ComboMealNotifier, ComboMealState>((ref) {
  // Default values - these should be overridden when the provider is used
  return ComboMealNotifier(
    repository: ComboMealRepository(),
    priceListId: 1,
    languageId: 1,
  );
});

/// Provider family for creating combo meal notifiers with specific price list and language
final comboMealProviderFamily = StateNotifierProvider.family<ComboMealNotifier,
    ComboMealState, ComboMealProviderParams>((ref, params) {
  return ComboMealNotifier(
    repository: ComboMealRepository(),
    priceListId: params.priceListId,
    languageId: params.languageId,
  );
});

/// Parameters for combo meal provider family
class ComboMealProviderParams {
  final int priceListId;
  final int languageId;

  const ComboMealProviderParams({
    required this.priceListId,
    this.languageId = 1,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComboMealProviderParams &&
        other.priceListId == priceListId &&
        other.languageId == languageId;
  }

  @override
  int get hashCode => priceListId.hashCode ^ languageId.hashCode;
}

