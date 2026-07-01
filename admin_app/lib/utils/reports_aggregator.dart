import 'package:intl/intl.dart';

import '../models/order_model.dart';
import 'constants.dart';

/// Russian month abbreviations used for monthly bucket labels.
const List<String> ruMonths = [
  'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн',
  'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'
];

/// The period a report's income is bucketed by.
enum ReportPeriod { month, week, shift }

/// A single income bucket (month / week / shift).
class IncomeBucket {
  final String key;
  final String label;
  final DateTime sortDate;
  double total = 0;
  int count = 0;
  IncomeBucket(this.key, this.label, this.sortDate);
}

/// Lifetime aggregation for a single client's orders.
class ClientLifetime {
  final double spent;
  final DateTime? last;
  final int orderCount;
  const ClientLifetime({
    required this.spent,
    required this.last,
    required this.orderCount,
  });
}

/// Pure period-bucketing and aggregation for the reports screen.
///
/// No [BuildContext], no widgets — same inputs always yield the same outputs.
class ReportsAggregator {
  const ReportsAggregator._();

  /// Groups [orders] into income buckets for the given [period], newest first.
  ///
  /// - month: `yyyy-MM` keyed, labelled `<RuMonth> <year>`.
  /// - week: Monday–Sunday groups, keyed by the Monday's `yyyy-MM-dd`.
  /// - shift: keyed by shift id (`no-shift` when empty).
  static List<IncomeBucket> bucketize(
    List<OrderModel> orders,
    ReportPeriod period,
  ) {
    final map = <String, IncomeBucket>{};
    for (final o in orders) {
      final d = o.createdAt ?? o.shiftDate;
      late String key;
      late String label;
      late DateTime sortDate;
      switch (period) {
        case ReportPeriod.month:
          key = DateFormat('yyyy-MM').format(d);
          label = '${ruMonths[d.month - 1]} ${d.year}';
          sortDate = DateTime(d.year, d.month);
          break;
        case ReportPeriod.week:
          final monday = d.subtract(Duration(days: d.weekday - 1));
          final sunday = monday.add(const Duration(days: 6));
          key = DateFormat('yyyy-MM-dd').format(monday);
          label =
              '${DateFormat('dd.MM').format(monday)} – ${DateFormat('dd.MM').format(sunday)}';
          sortDate = monday;
          break;
        case ReportPeriod.shift:
          key = o.shiftId.isEmpty ? 'no-shift' : o.shiftId;
          final g = AppConstants.groupLabel(o.userGroup);
          label = o.shiftLabel.isEmpty
              ? 'Без смены'
              : '${o.shiftLabel} • $g';
          sortDate = o.shiftDate;
          break;
      }
      final b = map.putIfAbsent(key, () => IncomeBucket(key, label, sortDate));
      b.total += o.totalPrice;
      b.count += 1;
    }
    final list = map.values.toList()
      ..sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return list;
  }

  /// Sum of [OrderModel.totalPrice] across [orders].
  static double grandTotal(List<OrderModel> orders) =>
      orders.fold(0.0, (s, o) => s + o.totalPrice);

  /// Sum of [OrderModel.totalPrice] for delivered orders only.
  static double deliveredTotal(List<OrderModel> orders) => orders
      .where((o) => o.status == AppConstants.statusDelivered)
      .fold(0.0, (s, o) => s + o.totalPrice);

  /// Sum of [OrderModel.discount] across [orders].
  static double discountTotal(List<OrderModel> orders) =>
      orders.fold(0.0, (s, o) => s + o.discount);

  /// Average order value; 0 when there are no orders.
  static double averageCheck(List<OrderModel> orders) =>
      orders.isEmpty ? 0.0 : grandTotal(orders) / orders.length;

  /// [orders] sorted newest first by creation (falling back to shift date).
  static List<OrderModel> recentFirst(List<OrderModel> orders) => [...orders]
    ..sort((a, b) =>
        (b.createdAt ?? b.shiftDate).compareTo(a.createdAt ?? a.shiftDate));

  /// Groups [orders] by their `userId`.
  static Map<String, List<OrderModel>> ordersByUser(List<OrderModel> orders) {
    final byUser = <String, List<OrderModel>>{};
    for (final o in orders) {
      byUser.putIfAbsent(o.userId, () => []).add(o);
    }
    return byUser;
  }

  /// Most recent order date for [orders], or `1970` when there are none.
  static DateTime lastOrderDate(List<OrderModel> orders) {
    if (orders.isEmpty) return DateTime(1970);
    return orders
        .map((o) => o.createdAt ?? o.shiftDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Lifetime aggregation (spent excl. cancelled, last order, count) for a
  /// single client's [orders].
  static ClientLifetime clientLifetime(List<OrderModel> orders) {
    final spent = orders
        .where((o) => o.status != AppConstants.statusCancelled)
        .fold(0.0, (s, o) => s + o.totalPrice);
    DateTime? last;
    for (final o in orders) {
      final d = o.createdAt ?? o.shiftDate;
      if (last == null || d.isAfter(last)) last = d;
    }
    return ClientLifetime(
      spent: spent,
      last: last,
      orderCount: orders.length,
    );
  }
}
