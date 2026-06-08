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
import '../chats/chat_detail_screen.dart';

/// A delivery stop = an order that has delivery coordinates.
class _Stop {
  final OrderModel order;
  final LatLng pos;
  _Stop(this.order) : pos = LatLng(order.userLat!, order.userLng!);
  String get id => order.id;
}

/// Estimated arrival/departure window for a stop.
class _Eta {
  final DateTime arrival;
  final DateTime departure;
  const _Eta(this.arrival, this.departure);
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
  String? _lastGroup; // detects city switches to reset the route
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

  double _mapHeight = 280; // draggable: pull the divider to resize the map

  // ETA estimate (computed on demand to avoid any API cost).
  DateTime? _routeStart; // null => "now" when computed
  int _serviceMin = 5; // minutes spent handing over each order
  double _avgSpeedKmh = 28; // assumed average city driving speed
  static const double _detour = 1.3; // straight-line -> road distance factor
  final Map<String, _Eta> _eta = {}; // stop id -> arrival/departure

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

  void _onGroupChanged() {
    _ordersSub?.cancel();
    if (!mounted) return;
    setState(() {
      _shift = null;
      _stops.clear();
      _order = [];
      _eta.clear();
      _markerSet = {};
      _withoutCoords = 0;
    });
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
      _eta.clear(); // route changed -> times are stale
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
    setState(() {
      _order = order.map((i) => stops[i].id).toList();
      _eta.clear();
    });
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
      _eta.clear();
    });
    _rebuildMarkers();
  }

  // ---- ETA, chat, status actions -----------------------------------------
  void _computeEta() {
    final stops = _orderedStops;
    if (stops.isEmpty) return;
    final eta = <String, _Eta>{};
    var t = _routeStart ?? DateTime.now();
    var prev = _effectiveStart;
    for (final s in stops) {
      final km = RouteOptimizer.distanceKm(prev, s.pos) * _detour;
      final travelMin = _avgSpeedKmh > 0 ? (km / _avgSpeedKmh * 60) : 0.0;
      final arrival = t.add(Duration(minutes: travelMin.round()));
      final departure = arrival.add(Duration(minutes: _serviceMin));
      eta[s.id] = _Eta(arrival, departure);
      t = departure;
      prev = s.pos;
    }
    setState(() => _eta
      ..clear()
      ..addAll(eta));
    Fluttertoast.showToast(
        msg: 'Расчёт готов • финиш ~${DateFormat('HH:mm').format(t)}');
  }

  void _openChat(_Stop stop) {
    final o = stop.order;
    // Make sure an ETA exists, then pre-fill an arrival message (±15 min).
    if (!_eta.containsKey(stop.id)) _computeEta();
    final eta = _eta[stop.id];
    String? draft;
    if (eta != null) {
      final t = DateFormat('HH:mm').format(eta.arrival);
      final first = o.userName.split(' ').first;
      draft = 'Hallo $first! Ihre Sarkis-Bread-Bestellung kommt '
          'voraussichtlich gegen $t Uhr (±15 Min.). Bis gleich!';
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
            topicId: o.userId, userName: o.userName, initialText: draft),
      ),
    );
  }

  Future<void> _markDelivered(OrderModel o) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Отметить доставленным?'),
        content: Text(
            '${o.userName} — ${o.userAddress}\n\nЗаказ будет убран из маршрута.',
            style: AppTextStyles.body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Доставлен',
                  style: TextStyle(color: AppColors.success))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await OrderService.instance.updateStatus(o.id, 'delivered');
      // The stream removes it from the route; clear stale ETAs.
      Fluttertoast.showToast(msg: 'Отмечено доставленным');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Ошибка: $e');
    }
  }

  void _openEtaSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Настройки времени', style: AppTextStyles.headingM),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule, color: AppColors.primary),
                title: Text('Время старта', style: AppTextStyles.body),
                trailing: Text(
                  _routeStart == null
                      ? 'Сейчас'
                      : DateFormat('HH:mm').format(_routeStart!),
                  style: AppTextStyles.bodyBold
                      .copyWith(color: AppColors.primary),
                ),
                onTap: () async {
                  final now = TimeOfDay.now();
                  final picked = await showTimePicker(
                      context: ctx,
                      initialTime: _routeStart != null
                          ? TimeOfDay.fromDateTime(_routeStart!)
                          : now);
                  if (picked != null) {
                    final d = DateTime.now();
                    setSheet(() {});
                    setState(() => _routeStart = DateTime(
                        d.year, d.month, d.day, picked.hour, picked.minute));
                    setSheet(() {});
                  }
                },
              ),
              _stepperRow('Минут на остановку', _serviceMin.toString(), (d) {
                setState(() => _serviceMin = (_serviceMin + d).clamp(0, 60));
                setSheet(() {});
              }),
              _stepperRow('Скорость, км/ч', _avgSpeedKmh.toStringAsFixed(0),
                  (d) {
                setState(() =>
                    _avgSpeedKmh = (_avgSpeedKmh + d * 2).clamp(10, 90));
                setSheet(() {});
              }),
              const SizedBox(height: 8),
              Text(
                  'Время рассчитывается по прямому расстоянию × 1.3 и средней '
                  'скорости — без обращения к платному API.',
                  style: AppTextStyles.caption),
              const SizedBox(height: 12),
              GoldenButton(
                label: 'Пересчитать время',
                onPressed: () {
                  Navigator.pop(ctx);
                  _computeEta();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepperRow(String label, String value, void Function(int) onStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          IconButton(
              onPressed: () => onStep(-1),
              icon: const Icon(Icons.remove_circle_outline)),
          SizedBox(
              width: 36,
              child: Text(value,
                  textAlign: TextAlign.center, style: AppTextStyles.bodyBold)),
          IconButton(
              onPressed: () => onStep(1),
              icon: const Icon(Icons.add_circle, color: AppColors.primary)),
        ],
      ),
    );
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
    // Render the crisp 96px bitmap at a sane on-screen size (~42 logical px)
    // so pins don't dominate the map.
    final desc = BitmapDescriptor.fromBytes(bytes, size: const Size(42, 42));
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
    // When the admin switches city, the previously selected shift belongs to
    // the old group and would crash the dropdown — reset the route.
    if (_lastGroup == null) {
      _lastGroup = group;
    } else if (_lastGroup != group) {
      _lastGroup = group;
      WidgetsBinding.instance.addPostFrameCallback((_) => _onGroupChanged());
    }

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
                stream: ShiftService.instance.shiftsStream(group),
                builder: (context, snap) {
                  final shifts = snap.data ?? [];
                  // Only use the selected value if it's in the current list,
                  // otherwise the dropdown asserts (group just changed).
                  final value =
                      shifts.any((s) => s.id == _shift?.id) ? _shift?.id : null;
                  return DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: AppColors.surfaceElevated,
                    value: value,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Clamp so a tall map still leaves room for the divider + toolbar,
        // and the list keeps a minimum visible height.
        const minMap = 160.0;
        final maxMap = (constraints.maxHeight - 160).clamp(minMap, 900.0);
        final mapH = _mapHeight.clamp(minMap, maxMap).toDouble();
        return Column(
          children: [
            SizedBox(
              height: mapH,
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
                      child: const Icon(Icons.my_location,
                          color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            _resizeHandle(minMap, maxMap),
            _startBar(),
            _toolbar(stops.length),
            if (_withoutCoords > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_withoutCoords заказ(ов) без координат (старые) — не на карте',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
              ),
            Expanded(
              child: stops.isEmpty
                  ? const EmptyState(
                      icon: Icons.location_off,
                      title: 'Нет адресов с координатами')
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      itemCount: stops.length,
                      onReorder: _reorder,
                      itemBuilder: (context, i) => _stopTile(i, stops[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Draggable bar between the map and the list — drag down to enlarge the map.
  Widget _resizeHandle(double minMap, double maxMap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (d) {
        setState(() {
          _mapHeight =
              (_mapHeight + d.delta.dy).clamp(minMap, maxMap).toDouble();
        });
      },
      onDoubleTap: () => setState(() => _mapHeight = 280),
      child: Container(
        height: 22,
        width: double.infinity,
        color: AppColors.surface,
        alignment: Alignment.center,
        child: Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.textMuted,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$count точек', style: AppTextStyles.headingM),
              const Spacer(),
              if (_eta.isNotEmpty)
                Row(children: [
                  const Icon(Icons.flag_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('финиш ~${_finishLabel()}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary)),
                ]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _outlineBtn(Icons.schedule, 'Время',
                    count >= 1 ? _computeEta : null),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _outlineBtn(Icons.auto_fix_high, 'Оптимизировать',
                    count >= 2 ? _optimize : null),
              ),
              const SizedBox(width: 8),
              _squareIconBtn(Icons.tune, _openEtaSettings),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: GoldenButton(
              label: 'В Google Maps',
              icon: Icons.navigation,
              height: 44,
              onPressed: count >= 1 ? _openFullRoute : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlineBtn(IconData icon, String label, VoidCallback? onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textMuted,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _squareIconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  String _finishLabel() {
    DateTime? last;
    for (final e in _eta.values) {
      if (last == null || e.departure.isAfter(last)) last = e.departure;
    }
    return last == null ? '' : DateFormat('HH:mm').format(last);
  }

  Widget _stopTile(int i, _Stop stop) {
    final o = stop.order;
    final eta = _eta[stop.id];
    return Container(
      key: ValueKey(stop.id),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
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
          // Arrival / departure clocks (after the number).
          if (eta != null) ...[
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _clock(Icons.login, DateFormat('HH:mm').format(eta.arrival),
                    AppColors.primary),
                const SizedBox(height: 2),
                _clock(Icons.logout, DateFormat('HH:mm').format(eta.departure),
                    AppColors.textMuted),
              ],
            ),
          ],
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyBold),
                Text(o.userAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          _miniBtn(Icons.chat_bubble_outline, AppColors.textSecondary,
              'Сообщение (время прибытия)', () => _openChat(stop)),
          _miniBtn(Icons.check_circle_outline, AppColors.success, 'Доставлен',
              () => _markDelivered(o)),
          _miniBtn(Icons.navigation, AppColors.primary, 'Навигация',
              () => NavigationService.instance
                  .navigateToPoint(stop.pos.latitude, stop.pos.longitude)),
          ReorderableDragStartListener(
            index: i,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Icon(Icons.drag_handle, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clock(IconData icon, String time, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(time,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _miniBtn(
      IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
      onPressed: onTap,
    );
  }
}
