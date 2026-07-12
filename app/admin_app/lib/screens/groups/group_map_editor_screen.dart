import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../l10n/admin_localizations.dart';
import '../../models/region_group_model.dart';
import '../../services/region_group_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/golden_button.dart';

/// Free-draw editor: the admin taps the map to drop polygon vertices, building
/// one or more colored regions that together define a delivery group.
class GroupMapEditorScreen extends StatefulWidget {
  final RegionGroupModel? existing;
  const GroupMapEditorScreen({super.key, this.existing});

  @override
  State<GroupMapEditorScreen> createState() => _GroupMapEditorScreenState();
}

class _GroupMapEditorScreenState extends State<GroupMapEditorScreen> {
  static const _initial = LatLng(52.520008, 13.404954); // Berlin

  /// Palette the admin can tint a group with.
  static const _palette = <int>[
    0xFFC8972A, // gold
    0xFFFF6B35, // orange
    0xFF42A5F5, // blue
    0xFF4CAF50, // green
    0xFFAB47BC, // purple
    0xFFEF5350, // red
    0xFF26C6DA, // cyan
    0xFFFFCA28, // amber
  ];

  final _nameController = TextEditingController();

  // Completed shapes plus the one currently being drawn.
  final List<List<LatLng>> _shapes = [];
  List<LatLng> _current = [];
  int _color = _palette.first;
  bool _saving = false;

  // Numbered marker bitmaps, cached by "number_argb" so a color change or a
  // new vertex count regenerates only what it needs.
  Set<Marker> _markers = {};
  final Map<String, BitmapDescriptor> _iconCache = {};

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameController.text = e.name;
      _color = e.colorValue;
      for (final ring in e.polygons) {
        if (ring.length >= 3) _shapes.add(List.of(ring));
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildMarkers());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color get _fill => Color(_color);

  void _onTap(LatLng pos) {
    setState(() => _current = [..._current, pos]);
    _rebuildMarkers();
  }

  void _undoPoint() {
    if (_current.isNotEmpty) {
      setState(() => _current = _current.sublist(0, _current.length - 1));
    } else if (_shapes.isNotEmpty) {
      // Re-open the last completed shape for further editing.
      setState(() {
        _current = _shapes.removeLast();
        if (_current.isNotEmpty) {
          _current = _current.sublist(0, _current.length - 1);
        }
      });
    }
    _rebuildMarkers();
  }

  void _finishShape() {
    if (_current.length < 3) return;
    setState(() {
      _shapes.add(_current);
      _current = [];
    });
    _rebuildMarkers();
  }

  void _clearAll() {
    setState(() {
      _shapes.clear();
      _current = [];
    });
    _rebuildMarkers();
  }

  /// Moves a single vertex after the admin drags its numbered pin.
  void _movePoint({int? shape, required int index, required LatLng pos}) {
    setState(() {
      if (shape == null) {
        _current[index] = pos;
      } else {
        _shapes[shape][index] = pos;
      }
    });
    _rebuildMarkers();
  }

  Set<Polygon> _buildPolygons() {
    final polys = <Polygon>{};
    for (var i = 0; i < _shapes.length; i++) {
      polys.add(Polygon(
        polygonId: PolygonId('shape_$i'),
        points: _shapes[i],
        fillColor: _fill.withOpacity(0.28),
        strokeColor: _fill,
        strokeWidth: 3,
      ));
    }
    if (_current.length >= 2) {
      polys.add(Polygon(
        polygonId: const PolygonId('current'),
        points: _current,
        fillColor: _fill.withOpacity(0.18),
        strokeColor: _fill,
        strokeWidth: 2,
      ));
    }
    return polys;
  }

  /// Builds (and caches) a circular pin with [n] drawn on it in the group's
  /// color. Completed-shape pins are dimmed slightly so the active shape reads
  /// as the foreground one.
  Future<BitmapDescriptor> _numberedIcon(int n, {required bool active}) async {
    final color = active ? _fill : _fill.withOpacity(0.6);
    final key = '${n}_${color.value}';
    final cached = _iconCache[key];
    if (cached != null) return cached;
    const size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(size / 2, size / 2);
    const radius = size / 2 - 6;
    canvas.drawCircle(center, radius, Paint()..color = color);
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
    final desc = BitmapDescriptor.fromBytes(bytes, size: const Size(36, 36));
    _iconCache[key] = desc;
    return desc;
  }

  /// Rebuilds the draggable, numbered vertex pins for every shape plus the one
  /// in progress. Each shape numbers its own points 1..n.
  Future<void> _rebuildMarkers() async {
    final markers = <Marker>{};
    for (var s = 0; s < _shapes.length; s++) {
      final ring = _shapes[s];
      for (var i = 0; i < ring.length; i++) {
        markers.add(Marker(
          markerId: MarkerId('s${s}_$i'),
          position: ring[i],
          anchor: const Offset(0.5, 0.5),
          draggable: true,
          icon: await _numberedIcon(i + 1, active: false),
          onDragEnd: (pos) => _movePoint(shape: s, index: i, pos: pos),
        ));
      }
    }
    for (var i = 0; i < _current.length; i++) {
      markers.add(Marker(
        markerId: MarkerId('c_$i'),
        position: _current[i],
        anchor: const Offset(0.5, 0.5),
        draggable: true,
        zIndex: 1000,
        icon: await _numberedIcon(i + 1, active: true),
        onDragEnd: (pos) => _movePoint(index: i, pos: pos),
      ));
    }
    if (!mounted) return;
    setState(() => _markers = markers);
  }

  Future<void> _save() async {
    final l = AdminLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _toast(l.t('grpNameRequired'));
      return;
    }
    // Fold any in-progress shape into the saved set.
    final shapes = [..._shapes];
    if (_current.length >= 3) shapes.add(_current);
    if (shapes.isEmpty) {
      _toast(l.t('grpDrawRequired'));
      return;
    }

    setState(() => _saving = true);
    try {
      final model = RegionGroupModel(
        id: widget.existing?.id ?? '',
        name: name,
        colorValue: _color,
        polygons: shapes,
        createdAt: widget.existing?.createdAt,
      );
      await RegionGroupService.instance.save(model);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toast('$e');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.surfaceElevated),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AdminLocalizations.of(context);
    final isEdit = widget.existing != null;
    final camera = widget.existing?.center ?? _initial;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.t(isEdit ? 'grpEditTitle' : 'grpNewTitle')),
        actions: [
          IconButton(
            tooltip: l.t('grpUndo'),
            icon: const Icon(Icons.undo, color: AppColors.textPrimary),
            onPressed: (_current.isEmpty && _shapes.isEmpty) ? null : _undoPoint,
          ),
          IconButton(
            tooltip: l.t('grpClear'),
            icon: const Icon(Icons.delete_sweep_outlined,
                color: AppColors.error),
            onPressed: (_current.isEmpty && _shapes.isEmpty) ? null : _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: camera, zoom: 11),
                  onTap: _onTap,
                  polygons: _buildPolygons(),
                  markers: _markers,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: _hintBar(l),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _finishButton(l),
                ),
              ],
            ),
          ),
          _bottomPanel(l),
        ],
      ),
    );
  }

  Widget _hintBar(AdminLocalizations l) {
    final shapes = _shapes.length + (_current.length >= 3 ? 1 : 0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_outlined,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.t('grpTapHint'),
              style: AppTextStyles.caption,
            ),
          ),
          if (shapes > 0)
            Text('${l.t('grpZones')}: $shapes',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _finishButton(AdminLocalizations l) {
    final enabled = _current.length >= 3;
    return FloatingActionButton.extended(
      heroTag: 'finishShape',
      backgroundColor:
          enabled ? AppColors.primary : AppColors.surfaceElevated,
      foregroundColor: enabled ? Colors.black : AppColors.textMuted,
      onPressed: enabled ? _finishShape : null,
      icon: const Icon(Icons.check),
      label: Text(l.t('grpFinishShape')),
    );
  }

  Widget _bottomPanel(AdminLocalizations l) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInputField(
            controller: _nameController,
            label: l.t('grpName'),
            prefixIcon: Icons.label_outline,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          Text(l.t('grpColor'), style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _palette.map(_swatch).toList(),
          ),
          const SizedBox(height: 16),
          GoldenButton(
            label: l.t('save'),
            icon: Icons.save_outlined,
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _swatch(int value) {
    final sel = value == _color;
    return GestureDetector(
      onTap: () {
        setState(() => _color = value);
        _rebuildMarkers();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Color(value),
          shape: BoxShape.circle,
          border: Border.all(
            color: sel ? AppColors.textPrimary : Colors.transparent,
            width: 3,
          ),
        ),
        child: sel
            ? const Icon(Icons.check, size: 18, color: Colors.black)
            : null,
      ),
    );
  }
}
