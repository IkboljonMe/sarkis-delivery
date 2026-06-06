import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

/// Holds the admin's currently selected operating group (Berlin/Hamburg).
class GroupProvider extends ChangeNotifier {
  static const _key = 'admin_group';
  String _group = AppConstants.groupBerlin;
  String get group => _group;
  String get label => AppConstants.groupLabel(_group);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final g = prefs.getString(_key);
      if (g != null && AppConstants.groups.contains(g)) {
        _group = g;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setGroup(String group) async {
    if (!AppConstants.groups.contains(group)) return;
    _group = group;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, group);
    } catch (_) {}
  }
}
