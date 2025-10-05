import 'package:flutter/material.dart';
import '../../features/conversation/domain/product_types.dart';
import '../theme/app_theme.dart';

/// Product type selector component
/// Displays a grid of product type cards for user selection
class ProductTypeSelector extends StatelessWidget {
  final String? selectedProductType;
  final void Function(String productTypeId) onProductTypeSelected;

  const ProductTypeSelector({
    super.key,
    this.selectedProductType,
    required this.onProductTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = Theme.of(context).colorScheme;

    // Split products into 3 rows (2 items per row)
    final rows = <List<dynamic>>[];
    for (var i = 0; i < ProductTypes.all.length; i += 2) {
      rows.add(ProductTypes.all.skip(i).take(2).toList());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: spacing.x4,
            right: spacing.x4,
            bottom: spacing.x2,
          ),
          child: Text(
            '상품 선택',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Render each row
        ...rows.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final rowProducts = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              left: spacing.x4,
              right: spacing.x4,
              top: rowIndex > 0 ? spacing.x2 : 0,
            ),
            child: Wrap(
              spacing: spacing.x2,
              children: rowProducts.map((product) {
                final isSelected = selectedProductType == product.id;
                return FilterChip(
                  selected: isSelected,
                  label: Text(product.label),
                  onSelected: (_) => onProductTypeSelected(product.id),
                  backgroundColor: colors.surfaceContainerHighest,
                  selectedColor: colors.primaryContainer,
                  checkmarkColor: colors.onPrimaryContainer,
                  labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? colors.onPrimaryContainer
                        : colors.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? colors.primary
                          : colors.outline.withValues(alpha: 0.2),
                      width: isSelected ? 1 : 0.5,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.x3,
                    vertical: spacing.x1,
                  ),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          );
        }).toList(),
      ],
    );
  }
}
