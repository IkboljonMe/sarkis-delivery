import 'package:drift/drift.dart' as drift;

import '../local_db/app_database.dart';
import '../models/shift_model.dart';
import '../sync/mutation_queue.dart';

class ShiftService {
  ShiftService._();
  static final ShiftService instance = ShiftService._();

  Stream<List<ShiftModel>> openShiftsStream(String group) {
    final db = AppDatabase.instance;
    return (db.select(db.shifts)
          ..where((t) => t.group.equals(group) & t.isOpen.equals(true))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.date)]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  Stream<List<ShiftModel>> allShiftsStream(String group) {
    final db = AppDatabase.instance;
    return (db.select(db.shifts)
          ..where((t) => t.group.equals(group))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.date)]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  Stream<List<ShiftModel>> allGroupsShiftsStream() {
    final db = AppDatabase.instance;
    return (db.select(db.shifts)
          ..orderBy([(t) => drift.OrderingTerm.asc(t.date)]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  Stream<List<ShiftModel>> shiftsStream(String group) =>
      group.isEmpty ? allGroupsShiftsStream() : allShiftsStream(group);

  ShiftModel _map(Shift r) {
    return ShiftModel(
      id: r.id,
      group: r.group,
      date: r.date,
      label: r.label,
      isOpen: r.isOpen,
      cancelDaysBefore: r.cancelDaysBefore,
      editDaysBefore: r.editDaysBefore,
    );
  }

  Future<void> addShift(ShiftModel shift) async {
    final body = {
      'group': shift.group,
      'date': shift.date.toIso8601String(),
      'label': shift.label,
      'isOpen': shift.isOpen,
      'cancelDaysBefore': shift.cancelDaysBefore,
      'editDaysBefore': shift.editDaysBefore,
    };
    final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
    
    final db = AppDatabase.instance;
    await db.into(db.shifts).insert(ShiftsCompanion.insert(
      id: id,
      group: shift.group,
      date: shift.date,
      label: drift.Value(shift.label),
      isOpen: drift.Value(shift.isOpen),
      cancelDaysBefore: drift.Value(shift.cancelDaysBefore),
      editDaysBefore: drift.Value(shift.editDaysBefore),
      createdAt: drift.Value(DateTime.now()),
      updatedAt: DateTime.now(),
    ));

    await MutationQueue.instance.run(
      entityType: 'shift',
      method: 'POST',
      path: '/v1/admin/shifts',
      body: body,
      localRefId: id,
    );
  }

  Future<void> setOpen(String id, bool isOpen) async {
    final db = AppDatabase.instance;
    await (db.update(db.shifts)..where((t) => t.id.equals(id))).write(ShiftsCompanion(isOpen: drift.Value(isOpen)));

    await MutationQueue.instance.run(
      entityType: 'shift',
      method: 'PATCH',
      path: '/v1/admin/shifts/$id',
      body: {'isOpen': isOpen},
    );
  }

  Future<void> deleteShift(String id) async {
    final db = AppDatabase.instance;
    await (db.delete(db.shifts)..where((t) => t.id.equals(id))).go();

    await MutationQueue.instance.run(
      entityType: 'shift',
      method: 'DELETE',
      path: '/v1/admin/shifts/$id',
    );
  }
}
