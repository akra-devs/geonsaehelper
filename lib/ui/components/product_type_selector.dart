import 'package:flutter/material.dart';
import '../../features/conversation/domain/product_types.dart';
import '../theme/app_theme.dart';

/// 슬라이버 헤더에서 사용하는 상품 선택 컴포넌트.
/// 수평 캐러셀 형태로 구성해 빠르게 스와이프하며 고를 수 있다.
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
    final products = ProductTypes.all;

    final columnCount = 3;
    final rows = <List<dynamic>>[];
    for (var i = 0; i < products.length; i += columnCount) {
      rows.add(products.skip(i).take(columnCount).toList());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: spacing.x2),
          child: Text(
            '상품 선택',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Column(
          children: rows.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final rowProducts = entry.value;
            return Padding(
              padding: EdgeInsets.only(top: rowIndex == 0 ? 0 : spacing.x2),
              child: Row(
                children: rowProducts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  final isSelected = product.id == selectedProductType;
                  final gradient = LinearGradient(
                    colors: isSelected
                        ? [colors.primary, colors.secondary]
                        : [
                            colors.surfaceVariant.withOpacity(0.92),
                            colors.surfaceVariant.withOpacity(0.78),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  );
                  final borderColor =
                      isSelected ? colors.primary : colors.outlineVariant;

                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : spacing.x2,
                      ),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(corners.md),
                        border: Border.all(
                          color: borderColor,
                          width: isSelected ? 1.6 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colors.primary.withOpacity(0.24),
                                  blurRadius: 16,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            : const [],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(corners.md),
                        onTap: () => onProductTypeSelected(product.id),
                        child: Padding(
                          padding: EdgeInsets.all(spacing.x3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    size: 18,
                                    color: isSelected
                                        ? colors.onPrimary
                                        : colors.onSurfaceVariant,
                                  ),
                                  SizedBox(width: spacing.x2),
                                  Flexible(
                                    child: Text(
                                      product.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: isSelected
                                                ? colors.onPrimary
                                                : colors.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing.x2),
                              Text(
                                product.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? colors.onPrimary.withOpacity(0.9)
                                          : colors.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
