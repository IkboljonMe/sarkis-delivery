import 'package:flutter/material.dart';

import '../../models/product_model.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductModel product;
  final String language;
  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.language,
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameFor(language),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '€${product.price.toStringAsFixed(2)} / ${product.unit}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            _QtyControl(
              qty: qty,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 56,
        height: 56,
        color: const Color(0xFFF1E7D2),
        child: const Icon(Icons.bakery_dining, color: Color(0xFFC8860D)),
      );
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QtyControl({
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _circleButton(Icons.remove, qty > 0 ? onDecrement : null),
        SizedBox(
          width: 32,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _circleButton(Icons.add, onIncrement),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap == null
              ? Colors.grey.shade200
              : const Color(0xFFF1E7D2),
        ),
        child: Icon(icon,
            size: 20,
            color: onTap == null ? Colors.grey : const Color(0xFFC8860D)),
      ),
    );
  }
}
