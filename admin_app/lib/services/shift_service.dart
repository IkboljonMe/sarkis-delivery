import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/shift_model.dart';

class ShiftService {
  ShiftService._();
  static final ShiftService instance = ShiftService._();

  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('shifts');

  /// Open shifts for a group (customer home).
  Stream<List<ShiftModel>> openShiftsStream(String group) {
    return _col
        .where('group', isEqualTo: group)
        .where('isOpen', isEqualTo: true)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => ShiftModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  /// All shifts for a group (admin).
  Stream<List<ShiftModel>> allShiftsStream(String group) {
    return _col.where('group', isEqualTo: group).snapshots().map((s) {
      final list = s.docs
          .map((d) => ShiftModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  Future<void> addShift(ShiftModel shift) async {
    try {
      final ref = _col.doc();
      final data = shift.copyWith(id: ref.id).toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(data);
    } catch (e) {
      throw Exception('Failed to add shift: $e');
    }
  }

  Future<void> setOpen(String id, bool isOpen) =>
      _col.doc(id).update({'isOpen': isOpen});

  Future<void> deleteShift(String id) => _col.doc(id).delete();
}
