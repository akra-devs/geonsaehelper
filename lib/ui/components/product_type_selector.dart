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
    final corners = context.corners;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.x4,
            vertical: spacing.x3,
          ),
          child: Text(
            '어떤 대출 상품에 대해 궁금하신가요?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: spacing.x4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: spacing.x3,
            mainAxisSpacing: spacing.x3,
            childAspectRatio: 2.2,
          ),
          itemCount: ProductTypes.all.length,
          itemBuilder: (context, index) {
            final product = ProductTypes.all[index];
            final isSelected = selectedProductType == product.id;

            return InkWell(
              onTap: () => onProductTypeSelected(product.id),
              borderRadius: BorderRadius.circular(corners.md),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  border: Border.all(
                    color: isSelected
                        ? colors.primary
                        : colors.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(corners.md),
                ),
                padding: EdgeInsets.all(spacing.x3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? colors.onPrimaryContainer
                            : colors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.x1),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colors.onPrimaryContainer.withValues(alpha: 0.8)
                            : colors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
