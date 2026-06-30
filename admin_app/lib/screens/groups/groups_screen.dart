import 'package:flutter/material.dart';

import '../../l10n/admin_localizations.dart';
import '../../models/region_group_model.dart';
import '../../services/region_group_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/empty_state.dart';
import 'group_map_editor_screen.dart';

/// Lists admin-created map region groups; tapping the FAB opens the free-draw
/// map editor to create a new one.
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  Future<void> _openEditor(BuildContext context,
      [RegionGroupModel? existing]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupMapEditorScreen(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, RegionGroupModel g) async {
    final l = AdminLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text(l.t('grpDeleteTitle'), style: AppTextStyles.headingM),
        content: Text(l.t('grpDeleteBody'), style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.t('cancel'),
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.t('delete'),
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await RegionGroupService.instance.delete(g.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AdminLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text(l.t('grpCreate')),
      ),
      body: StreamBuilder<List<RegionGroupModel>>(
        stream: RegionGroupService.instance.groupsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final groups = snap.data ?? const [];
          if (groups.isEmpty) {
            return EmptyState(
              icon: Icons.map_outlined,
              title: l.t('grpEmptyTitle'),
              subtitle: l.t('grpEmptySub'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: groups.length,
            itemBuilder: (context, i) => _tile(context, l, groups[i]),
          );
        },
      ),
    );
  }

  Widget _tile(
      BuildContext context, AdminLocalizations l, RegionGroupModel g) {
    final color = Color(g.colorValue);
    final zones = g.polygons.where((p) => p.length >= 3).length;
    return DarkCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _openEditor(context, g),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(Icons.layers_outlined, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.name,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${l.t('grpZones')}: $zones',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context, g),
          ),
        ],
      ),
    );
  }
}
