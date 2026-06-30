import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/region_group_model.dart';
import '../services/region_group_service.dart';
import '../utils/constants.dart';

/// Holds the admin's currently selected operating group and the live list of
/// admin-drawn map groups (collection `regionGroups`). A group's identifier is
/// its name; [AppConstants.groupAll] is the "every region" pseudo-group.
class GroupProvider extends ChangeNotifier {
  static const _key = 'admin_group';

  String _group = AppConstants.groupAll;
  List<RegionGroupModel> _all = const [];
  StreamSubscription? _sub;

  String get group => _group;
  String get label => AppConstants.groupLabel(_group);
  bool get isAll => _group == AppConstants.groupAll;

  /// All admin-created groups, sorted by name.
  List<RegionGroupModel> get groups => _all;

  /// Group names only (no "all").
  List<String> get groupNames => _all.map((g) => g.name).toList();

  /// Names plus the "all" pseudo-group, for the region switcher.
  List<String> get groupsWithAll => [AppConstants.groupAll, ...groupNames];

  /// Loads the persisted selection and starts listening to Firestore. The
  /// stream is started at boot; if auth hasn't been restored yet the read is
  /// denied, so [_subscribe] retries until it succeeds.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final g = prefs.getString(_key);
      if (g != null) _group = g;
    } catch (_) {}
    _subscribe();
    notifyListeners();
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = RegionGroupService.instance.groupsStream().listen(
      (list) {
        _all = list;
        // If the selected group was deleted, fall back to "all".
        if (_group != AppConstants.groupAll && !groupNames.contains(_group)) {
          _group = AppConstants.groupAll;
        }
        notifyListeners();
      },
      onError: (_) {
        // Most likely auth not ready yet; retry shortly.
        _sub?.cancel();
        _sub = null;
        Future.delayed(const Duration(seconds: 2), _subscribe);
      },
    );
  }

  Future<void> setGroup(String group) async {
    if (group != AppConstants.groupAll && !groupNames.contains(group)) return;
    _group = group;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, group);
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
