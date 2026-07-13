import '../models/shift_model.dart';
import 'api_client.dart';

class ShiftService {
  ShiftService._();
  static final ShiftService instance = ShiftService._();

  final ApiClient _api = ApiClient.instance;

  static const _interval = Duration(seconds: 20);

  List<ShiftModel> _parse(dynamic res) => (res as List)
      .map((e) => ShiftModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  /// Open shifts for a group.
  Stream<List<ShiftModel>> openShiftsStream(String group) =>
      ApiClient.poll(_interval, () async {
        return _parse(await _api
            .get('/v1/shifts?group=${Uri.encodeComponent(group)}&open=true'));
      });

  /// All shifts for a group.
  Stream<List<ShiftModel>> allShiftsStream(String group) =>
      ApiClient.poll(_interval, () async {
        return _parse(
            await _api.get('/v1/shifts?group=${Uri.encodeComponent(group)}'));
      });

  /// Shifts of every group (admin overview).
  Stream<List<ShiftModel>> allGroupsShiftsStream() =>
      ApiClient.poll(_interval, () async => _parse(await _api.get('/v1/shifts')));

  Stream<List<ShiftModel>> shiftsStream(String group) =>
      group.isEmpty ? allGroupsShiftsStream() : allShiftsStream(group);

  Future<void> addShift(ShiftModel shift) async {
    await _api.post('/v1/admin/shifts', {
      'group': shift.group,
      'date': shift.date.toIso8601String(),
      'label': shift.label,
      'isOpen': shift.isOpen,
      'cancelDaysBefore': shift.cancelDaysBefore,
      'editDaysBefore': shift.editDaysBefore,
    });
  }

  Future<void> setOpen(String id, bool isOpen) =>
      _api.patch('/v1/admin/shifts/$id', {'isOpen': isOpen});

  Future<void> deleteShift(String id) async {
    await _api.delete('/v1/admin/shifts/$id');
  }
}
