import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';

/// One variant / modifier group (same [variantId]) in cart display order.
class SelectedVariantGroup {
  final int variantId;
  final List<SelectedVariant> selections;

  const SelectedVariantGroup({
    required this.variantId,
    required this.selections,
  });
}

/// Preserves first-seen [variantId] order from [items].
List<SelectedVariantGroup> groupSelectedVariantsByVariantId(
  List<SelectedVariant> items,
) {
  final order = <int>[];
  final map = <int, List<SelectedVariant>>{};
  for (final sv in items) {
    if (!map.containsKey(sv.variantId)) {
      map[sv.variantId] = [];
      order.add(sv.variantId);
    }
    map[sv.variantId]!.add(sv);
  }
  return order.map((id) => SelectedVariantGroup(variantId: id, selections: map[id]!)).toList();
}

/// Header line: `Group (Nature)` for modifiers, else group name only.
String selectedVariantGroupHeader(SelectedVariant first, bool isEnglish) {
  final gn = (isEnglish ? first.groupNameEn : first.groupNameAr).trim();
  if (gn.isEmpty) return '';
  final nature = (isEnglish ? first.modifierNatureEn : first.modifierNatureAr).trim();
  if (first.isModifier && nature.isNotEmpty) {
    return '$gn ($nature)';
  }
  return gn;
}

// --- Persisted variation rows (maps on [SalesItemsModel.variations]) --------

int variationRowGroupKey(Map<String, dynamic> v) {
  final raw = v['variantId'];
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  final vv = v['variantValueId'];
  if (vv is int) return 1000000000 + vv;
  if (vv is num) return 1000000000 + vv.toInt();
  return v.hashCode & 0x7fffffff;
}

/// Preserves first-seen group key order.
List<List<Map<String, dynamic>>> groupVariationMaps(
  List<Map<String, dynamic>> variations,
) {
  final order = <int>[];
  final map = <int, List<Map<String, dynamic>>>{};
  for (final row in variations) {
    final key = variationRowGroupKey(row);
    if (!map.containsKey(key)) {
      map[key] = [];
      order.add(key);
    }
    map[key]!.add(row);
  }
  return order.map((k) => map[k]!).toList();
}

String variationMapGroupHeader(Map<String, dynamic> first, bool isEnglish) {
  final gn = (isEnglish ? (first['groupNameEn'] ?? '').toString() : (first['groupNameAr'] ?? '').toString()).trim();
  if (gn.isEmpty) return '';
  final nature =
      (isEnglish ? (first['modifierNatureEn'] ?? '').toString() : (first['modifierNatureAr'] ?? '').toString()).trim();
  final isMod = first['isModifier'] == true;
  if (isMod && nature.isNotEmpty) {
    return '$gn ($nature)';
  }
  return gn;
}

/// Bilingual group line for PDF (matches `variationNameAr - variationNameEn` rows).
String variationMapGroupHeaderBilingual(Map<String, dynamic> first) {
  final ar = (first['groupNameAr'] ?? '').toString().trim();
  final en = (first['groupNameEn'] ?? '').toString().trim();
  if (ar.isEmpty && en.isEmpty) return '';
  final groupLine = ar.isNotEmpty && en.isNotEmpty ? '$ar - $en' : (ar.isNotEmpty ? ar : en);
  final isMod = first['isModifier'] == true;
  final nar = (first['modifierNatureAr'] ?? '').toString().trim();
  final nen = (first['modifierNatureEn'] ?? '').toString().trim();
  if (isMod && (nar.isNotEmpty || nen.isNotEmpty)) {
    final natureLine = nar.isNotEmpty && nen.isNotEmpty ? '$nar - $nen' : (nar.isNotEmpty ? nar : nen);
    return '$groupLine ($natureLine)';
  }
  return groupLine;
}
