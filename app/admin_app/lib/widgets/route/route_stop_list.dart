import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/order_model.dart';
import '../../utils/route_optimizer.dart';
import 'route_stop_tile.dart';

/// A delivery stop = an order that has delivery coordinates.
class RouteStop {
  final OrderModel order;
  final LatLng pos;
  RouteStop(this.order) : pos = LatLng(order.userLat!, order.userLng!);
  String get id => order.id;
}

/// The reorderable list of delivery stops.
class RouteStopList extends StatelessWidget {
  const RouteStopList({
    super.key,
    required this.stops,
    required this.etaFor,
    required this.onReorder,
    required this.onChat,
    required this.onDelivered,
    required this.onNavigate,
  });

  final List<RouteStop> stops;
  final Eta? Function(RouteStop stop) etaFor;
  final ReorderCallback onReorder;
  final void Function(RouteStop stop) onChat;
  final void Function(OrderModel order) onDelivered;
  final void Function(RouteStop stop) onNavigate;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: stops.length,
      onReorder: onReorder,
      itemBuilder: (context, i) => RouteStopTile(
        key: ValueKey(stops[i].id),
        index: i,
        stop: stops[i],
        eta: etaFor(stops[i]),
        onChat: onChat,
        onDelivered: onDelivered,
        onNavigate: onNavigate,
      ),
    );
  }
}
