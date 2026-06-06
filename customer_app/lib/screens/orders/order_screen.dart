import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/delivery_date_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import 'cart_summary_widget.dart';
import 'order_success_dialog.dart';
import 'product_card_widget.dart';

class OrderScreen extends StatefulWidget {
  final DeliveryDateModel deliveryDate;
  const OrderScreen({super.key, required this.deliveryDate});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    final order = context.read<OrderProvider>();
    order.clearCart();
    order.loadSettings();
  }

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final order = context.read<OrderProvider>();
    final user = auth.user;
    if (user == null) return;

    final id = await order.placeOrder(
      user: user,
      deliveryDate: widget.deliveryDate,
      products: _products,
    );

    if (!mounted) return;
    if (id != null) {
      await OrderSuccessDialog.show(context);
      if (!mounted) return;
      Navigator.of(context).pop(); // back to home
    } else {
      Fluttertoast.showToast(msg: AppLocalizations.of(context).error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final order = context.watch<OrderProvider>();
    final user = context.watch<AuthProvider>().user;
    final language = user?.language ?? 'en';
    final locale = Localizations.localeOf(context).languageCode;
    final dateLabel =
        DateFormat('EEE, d MMM yyyy', locale).format(widget.deliveryDate.date);

    return Scaffold(
      appBar: AppBar(title: Text(t.placeOrder)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFF1E7D2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.event, size: 18, color: Color(0xFF9A6500)),
                const SizedBox(width: 8),
                Text('${t.deliveryDate}: $dateLabel',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: order.productsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _ProductShimmer();
                }
                if (snapshot.hasError) {
                  return Center(child: Text(t.error));
                }
                _products = snapshot.data ?? [];
                if (_products.isEmpty) {
                  return Center(child: Text(t.noOrders));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _products.length,
                  itemBuilder: (context, i) {
                    final p = _products[i];
                    return ProductCardWidget(
                      product: p,
                      language: language,
                      qty: order.qtyOf(p.id),
                      onIncrement: () => order.increment(p),
                      onDecrement: () => order.decrement(p),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CartSummaryWidget(
        itemCount: order.totalItems,
        total: order.totalPrice(_products),
        placing: order.placing,
        onPlaceOrder: _placeOrder,
      ),
    );
  }
}

class _ProductShimmer extends StatelessWidget {
  const _ProductShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
