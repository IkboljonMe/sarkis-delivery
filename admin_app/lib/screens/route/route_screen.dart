import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../models/shift_model.dart';
import '../../providers/group_provider.dart';
import '../../services/navigation_service.dart';
import '../../services/order_service.dart';
import '../../services/shift_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/route_optimizer.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/golden_button.dart';

/// A delivery stop = an order that has delivery coordinates.
class _Stop {
  final OrderModel order;
  final LatLng pos;
  _Stop(this.order) : pos = LatLng(order.userLat!, order.userLng!);
  String get id => order.id;
}

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  static const _finished = ['delivered', 'cancelled'];
  static const _berlin = LatLng(52.520008, 13.404954);

  GoogleMapController? _map;
  ShiftModel? _shift;
  StreamSubscription<List<OrderModel>>? _ordersSub;

  LatLng? _start; // null => use current location once fetched
  bool _customStart = false;
  String? _startName; // set when a saved address is chosen as start
  final Map<String, _Stop> _stops = {}; // id -> stop (with coords)
  List<String> _order = []; // visiting order of stop ids
  int _withoutCoords = 0;

  // Numbered marker icons (0 = start), generated once and cached by number.
  Set<Marker> _markerSet = {};
  final Map<int, BitmapDescriptor> _iconCache = {};

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _map?.dispose();
    super.dispose();
  }

  // ---- Location ------------------------------------------------------------
  Future<void> _fetchLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      if (!_customStart) {
        setState(() => _start = LatLng(pos.latitude, pos.longitude));
        _rebuildMarkers();
      }
    } catch (_) {/* best effort */}
  }

  // ---- Orders stream -------------------------------------------------------
  void _selectShift(ShiftModel shift) {
    setState(() {
      _shift = shift;
      _stops.clear();
      _order = [];
      _withoutCoords = 0;
    });
    _ordersSub?.cancel();
    _ordersSub =
        OrderService.instance.ordersByShiftStream(shift.id).listen(_onOrders);
  }

  void _onOrders(List<OrderModel> orders) {
    final active =
        orders.where((o) => !_finished.contains(o.status)).toList();
    _withoutCoords =
        active.where((o) => o.userLat == null || o.userLng == null).length;

    final next = <String, _Stop>{};
    for (final o in active) {
      if (o.userLat != null && o.userLng != null) next[o.id] = _Stop(o);
    }
    // Keep current visiting order for stops still present; append new ones.
    final order = [
      ..._order.where(next.containsKey),
      ...next.keys.where((id) => !_order.contains(id)),
    ];
    if (!mounted) return;
    setState(() {
      _stops
        ..clear()
        ..addAll(next);
      _order = order;
    });
    _rebuildMarkers();
    _fitToStops();
  }

  // ---- Ordering ------------------------------------------------------------
  List<_Stop> get _orderedStops =>
      _order.map((id) => _stops[id]).whereType<_Stop>().toList();

  LatLng get _effectiveStart =>
      _start ?? (_orderedStops.isNotEmpty ? _orderedStops.first.pos : _berlin);

  void _optimize() {
    final stops = _orderedStops;
    if (stops.length < 2) return;
    final order = RouteOptimizer.nearestNeighborOrder(
        _effectiveStart, stops.map((s) => s.pos).toList());
    setState(() => _order = order.map((i) => stops[i].id).toList());
    _rebuildMarkers();
    _fitToStops();
    final km = RouteOptimizer.totalDistanceKm(
        _effectiveStart, _orderedStops.map((s) => s.pos).toList());
    Fluttertoast.showToast(msg: 'Маршрут оптимизирован • ~${km.toStringAsFixed(1)} км');
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final id = _order.removeAt(oldIndex);
      _order.insert(newIndex, id);
    });
    _rebuildMarkers();
  }

  // ---- Map markers ---------------------------------------------------------
  String get _startTitle => _startName != null
      ? 'Старт: $_startName'
      : (_customStart ? 'Старт: выбрано на карте' : 'Старт: моя локация');

  /// Builds (and caches) a circular pin bitmap with the number drawn on it.
  /// Number 0 is the start (blue); others are gold delivery stops.
  Future<BitmapDescriptor> _numberedIcon(int n) async {
    final cached = _iconCache[n];
    if (cached != null) return cached;
    const size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(size / 2, size / 2);
    const radius = size / 2 - 6;
    final bg = n == 0 ? const Color(0xFF2E7DFF) : AppColors.primary;
    canvas.drawCircle(center, radius, Paint()..color = bg);
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6);
    final tp = TextPainter(
      text: TextSpan(
        text: '$n',
        style: const TextStyle(
            color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
    final img =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = data!.buffer.asUint8List();
    final desc = BitmapDescriptor.fromBytes(bytes);
    _iconCache[n] = desc;
    return desc;
  }

  Future<void> _rebuildMarkers() async {
    final stops = _orderedStops;
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('start'),
        position: _effectiveStart,
        icon: await _numberedIcon(0),
        anchor: const Offset(0.5, 0.5),
        infoWindow: InfoWindow(title: _startTitle),
        zIndex: 1000,
      ),
    };
    for (var i = 0; i < stops.length; i++) {
      markers.add(Marker(
        markerId: MarkerId(stops[i].id),
        position: stops[i].pos,
        icon: await _numberedIcon(i + 1),
        anchor: const Offset(0.5, 0.5),
        infoWindow: InfoWindow(
            title: '${i + 1}. ${stops[i].order.userName}',
            snippet: stops[i].order.userAddress),
      ));
    }
    if (!mounted) return;
    setState(() => _markerSet = markers);
  }

  Set<Polyline> _polylines() {
    final pts = [_effectiveStart, ..._orderedStops.map((s) => s.pos)];
    if (pts.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: pts,
        color: AppColors.primary,
        width: 4,
      ),
    };
  }

  Future<void> _fitToStops() async {
    final map = _map;
    final stops = _orderedStops;
    if (map == null || stops.isEmpty) return;
    final pts = [_effectiveStart, ...stops.map((s) => s.pos)];
    var swLat = pts.first.latitude, swLng = pts.first.longitude;
    var neLat = pts.first.latitude, neLng = pts.first.longitude;
    for (final p in pts) {
      swLat = p.latitude < swLat ? p.latitude : swLat;
      swLng = p.longitude < swLng ? p.longitude : swLng;
      neLat = p.latitude > neLat ? p.latitude : neLat;
      neLng = p.longitude > neLng ? p.longitude : neLng;
    }
    try {
      await map.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(swLat, swLng),
          northeast: LatLng(neLat, neLng),
        ),
        56,
      ));
    } catch (_) {}
  }

  Future<void> _setCurrentAsStart() async {
    setState(() {
      _customStart = false;
      _startName = null;
    });
    await _fetchLocation();
    _rebuildMarkers();
    _fitToStops();
  }

  /// Lets the admin choose the start: GPS, or any seeded address ("from app").
  void _chooseStart() {
    final stops = _orderedStops;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(16),
          children: [
            Text('Откуда старт?', style: AppTextStyles.headingM),
            const SizedBox(height: 4),
            Text('или нажмите на карту, чтобы поставить точку',
                style: AppTextStyles.caption),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.my_location, color: AppColors.primary),
              title: Text('Моя локация (GPS)', style: AppTextStyles.body),
              onTap: () {
                Navigator.pop(ctx);
                _setCurrentAsStart();
              },
            ),
            const Divider(color: AppColors.border),
            Text('Выбрать адрес как старт:', style: AppTextStyles.caption),
            ...stops.map((s) => ListTile(
                  leading: const Icon(Icons.location_on_outlined,
                      color: AppColors.textSecondary),
                  title: Text(s.order.userName, style: AppTextStyles.body),
                  subtitle: Text(s.order.userAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _start = s.pos;
                      _customStart = true;
                      _startName = s.order.userName;
                    });
                    _rebuildMarkers();
                    _fitToStops();
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _openFullRoute() {
    final stops = _orderedStops;
    if (stops.isEmpty) return;
    NavigationService.instance.openMultiStopRoute(
      origin: '${_effectiveStart.latitude},${_effectiveStart.longitude}',
      stops: stops.map((s) => '${s.pos.latitude},${s.pos.longitude}').toList(),
    );
  }

  // ---- UI ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>().group;

    return Scaffold(
      body: Column(
        children: [
          _shiftPicker(group),
          if (_shift == null)
            const Expanded(
              child: EmptyState(
                  icon: Icons.alt_route, title: 'Выберите смену для маршрута'),
            )
          else
            Expanded(child: _mapAndStops()),
        ],
      ),
    );
  }

  Widget _shiftPicker(String group) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: DarkCard(
        child: Row(
          children: [
            const Icon(Icons.event, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: StreamBuilder<List<ShiftModel>>(
                stream: ShiftService.instance.allShiftsStream(group),
                builder: (context, snap) {
                  final shifts = snap.data ?? [];
                  return DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: AppColors.surfaceElevated,
                    value: _shift?.id,
                    hint: Text('Смена...', style: AppTextStyles.body),
                    items: shifts
                        .map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(
                                  '${DateFormat('d MMM').format(s.date)} • ${s.label}',
                                  style: AppTextStyles.body),
                            ))
                        .toList(),
                    onChanged: (id) {
                      final s = shifts.where((e) => e.id == id);
                      if (s.isNotEmpty) _selectShift(s.first);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapAndStops() {
    final stops = _orderedStops;
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: _effectiveStart, zoom: 11),
                onMapCreated: (c) {
                  _map = c;
                  _rebuildMarkers();
                  _fitToStops();
                },
                onTap: (pos) {
                  setState(() {
                    _start = pos;
                    _customStart = true;
                    _startName = null;
                  });
                  _rebuildMarkers();
                  Fluttertoast.showToast(msg: 'Старт установлен на карте');
                },
                markers: _markerSet,
                polylines: _polylines(),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton.small(
                  heroTag: 'myloc',
                  backgroundColor: AppColors.surfaceElevated,
                  onPressed: _setCurrentAsStart,
                  child: const Icon(Icons.my_location, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        _startBar(),
        _toolbar(stops.length),
        if (_withoutCoords > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$_withoutCoords заказ(ов) без координат (старые) — не на карте',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
        Expanded(
          child: stops.isEmpty
              ? const EmptyState(
                  icon: Icons.location_off, title: 'Нет адресов с координатами')
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: stops.length,
                  onReorder: _reorder,
                  itemBuilder: (context, i) => _stopTile(i, stops[i]),
                ),
        ),
      ],
    );
  }

  Widget _startBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Color(0xFF2E7DFF), shape: BoxShape.circle),
            child: const Text('0',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_startTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body),
          ),
          TextButton.icon(
            onPressed: _chooseStart,
            icon: const Icon(Icons.edit_location_alt, size: 18),
            label: const Text('Изменить'),
          ),
        ],
      ),
    );
  }

  Widget _toolbar(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Text('$count точек', style: AppTextStyles.headingM),
          const Spacer(),
          TextButton.icon(
            onPressed: count >= 2 ? _optimize : null,
            icon: const Icon(Icons.auto_fix_high, size: 18),
            label: const Text('Оптимизировать'),
          ),
          const SizedBox(width: 4),
          GoldenButton(
            label: 'В Google Maps',
            icon: Icons.navigation,
            height: 42,
            onPressed: count >= 1 ? _openFullRoute : null,
          ),
        ],
      ),
    );
  }

  Widget _stopTile(int i, _Stop stop) {
    final o = stop.order;
    return Container(
      key: ValueKey(stop.id),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Text('${i + 1}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.userName, style: AppTextStyles.bodyBold),
                Text(o.userAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.navigation, color: AppColors.primary),
            tooltip: 'Навигация',
            onPressed: () => NavigationService.instance
                .navigateToPoint(stop.pos.latitude, stop.pos.longitude),
          ),
          const Icon(Icons.drag_handle, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
