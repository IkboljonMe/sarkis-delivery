import '../models/shift_model.dart';
import 'api_client.dart';

class ShiftService {
  ShiftService._();
  static final ShiftService instance = ShiftService._();

  final ApiClient _api = ApiClient.instance;

  List<ShiftModel> _parse(dynamic res) => (res as List)
      .map((e) => ShiftModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  /// Open shifts for a group (customer home).
  Stream<List<ShiftModel>> openShiftsStream(String group) =>
      ApiClient.poll(const Duration(seconds: 30), () async {
        return _parse(await _api
            .get('/v1/shifts?group=${Uri.encodeComponent(group)}&open=true'));
      });

  /// All shifts for a group.
  Stream<List<ShiftModel>> allShiftsStream(String group) =>
      ApiClient.poll(const Duration(seconds: 30), () async {
        return _parse(
            await _api.get('/v1/shifts?group=${Uri.encodeComponent(group)}'));
      });
}
