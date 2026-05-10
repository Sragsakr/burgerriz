import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';

/// A single selectable option tile for a variant/modifier group.
///
/// When [showQtyControls] is true the tile uses a three-zone tap model:
/// - Left zone  → [onDecrement]
/// - Center zone → [onTap] (toggle selection)
/// - Right zone → [onIncrement]
class OptionTile extends StatelessWidget {
  final String name;
  final double price;
  final bool isSelected;
  final double quantity;
  final bool showQtyControls;
  final int maxQtyPerModifier;
  final double tileWidth;
  final double tileHeight;
  final VoidCallback onTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final bool isDefault;

  const OptionTile({
    super.key,
    required this.name,
    required this.price,
    required this.isSelected,
    required this.tileWidth,
    required this.tileHeight,
    required this.onTap,
    this.quantity = 1.0,
    this.showQtyControls = false,
    this.maxQtyPerModifier = 0,
    this.onIncrement,
    this.onDecrement,
    this.isDefault = false,
  });

  void _handleTapZone(TapDownDetails details, BuildContext context) {
    final x = details.localPosition.dx;
    if (x < tileWidth / 3) {
      onDecrement?.call();
    } else if (x > tileWidth * 2 / 3) {
      onIncrement?.call();
    } else {
      onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = isSelected && quantity > 1;
    final bool canIncrement =
        isSelected && (maxQtyPerModifier <= 0 || quantity < maxQtyPerModifier);

    return GestureDetector(
      onTapDown: showQtyControls ? (d) => _handleTapZone(d, context) : null,
      onTap: showQtyControls ? null : onTap,
      child: Container(
        width: tileWidth,
        height: tileHeight,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFAF2A26).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFAF2A26) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            if (showQtyControls && isSelected) ...[
              _buildZoneIndicator(
                side: Alignment.centerLeft,
                icon: Icons.remove,
                isActive: canDecrement,
              ),
              _buildZoneIndicator(
                side: Alignment.centerRight,
                icon: Icons.add,
                isActive: canIncrement,
              ),
            ],
            if (isDefault)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFFAF2A26)
                              : Colors.black87,
                        ),
                        children: showQtyControls && isSelected
                            ? [
                                TextSpan(
                                  text: ' (${quantity.toInt()})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFAF2A26),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ]
                            : [],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (price > 0) ...[
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CurrencyDisplayWidget(
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            price.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? const Color(0xFFAF2A26)
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneIndicator({
    required AlignmentGeometry side,
    required IconData icon,
    required bool isActive,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: side,
        child: Container(
          width: tileWidth / 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: side == Alignment.centerLeft
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              end: side == Alignment.centerLeft
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              colors: [
                const Color(0xFFAF2A26)
                    .withValues(alpha: isActive ? 0.15 : 0.04),
                Colors.transparent,
              ],
            ),
            borderRadius: side == Alignment.centerLeft
                ? const BorderRadius.horizontal(left: Radius.circular(9))
                : const BorderRadius.horizontal(right: Radius.circular(9)),
          ),
          child: Icon(
            icon,
            size: 14,
            color:
                const Color(0xFFAF2A26).withValues(alpha: isActive ? 0.8 : 0.2),
          ),
        ),
      ),
    );
  }
}
