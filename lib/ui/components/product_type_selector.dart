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
            vertical: spacing.x2,
          ),
          child: Text(
            '어떤 대출 상품에 대해 궁금하신가요?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: spacing.x4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: spacing.x2,
            mainAxisSpacing: spacing.x2,
            childAspectRatio: 2.5,
          ),
          itemCount: ProductTypes.all.length,
          itemBuilder: (context, index) {
            final product = ProductTypes.all[index];
            final isSelected = selectedProductType == product.id;

            return InkWell(
              onTap: () => onProductTypeSelected(product.id),
              borderRadius: BorderRadius.circular(corners.sm),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  border: Border.all(
                    color: isSelected
                        ? colors.primary
                        : colors.outline.withValues(alpha: 0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(corners.sm),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.x2,
                  vertical: spacing.x1,
                ),
                child: Center(
                  child: Text(
                    product.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? colors.onPrimaryContainer
                          : colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
